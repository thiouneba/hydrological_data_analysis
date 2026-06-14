#----------------------------------------------------------------------------------------#
#-------------------------Installation des libraires-------------------------------------#
#----------------------------------------------------------------------------------------#
library(ggplot2)
library(dplyr)
library(lubridate)
library(GGally)
library(fastICA)
library(FactoMineR)
library(factoextra)

#----------------------------------------------------------------------------------------#
#-------------------------Préparation des données à traiter------------------------------#
#----------------------------------------------------------------------------------------#
# Lecture des données
Base <- read.table("base.csv", header = T, sep = ";", dec = ",")

# Conversion des variables date et t au format Date
Base$date <- ymd(Base$date)
Base$t <- ymd_hms(Base$t)

# Création d'une variable year et d'une variable month qui représentent l'année et le mois de chaque observation
Base$year = year(Base$date)
Base$month = month(Base$date)

Base$year = as.factor(Base$year)
Base$month = as.factor(Base$month)

# Création de 3 bases de données pour chacune des sondes 825, 827, 828
Od1a <- filter(Base, id_sonde=="825")
Od2a <- filter(Base, id_sonde=="827")
Od3a <- filter(Base, id_sonde=="828")
Od4a <- filter(Base, id_sonde=="830")

# Calcul de la moyenne Teau pour chaque jour
Od1aa <- aggregate(Teau~date, data=Od1a, FUN=mean, na.rm=T)
Od2aa <- aggregate(Teau~date, data=Od2a, FUN=mean, na.rm=T)
Od3aa <- aggregate(Teau~date, data=Od3a, FUN=mean, na.rm=T)
Od4aa <- aggregate(Teau~date, data=Od4a, FUN=mean, na.rm=T)

# Renommer la colonne Teau
colnames(Od1aa)[2] = "Teau825"
colnames(Od2aa)[2] = "Teau827"
colnames(Od3aa)[2] = "Teau828"
colnames(Od4aa)[2] = "Teau830"

# Regrouppement des températures des sondes pour chaque jour
base4<-merge(Od1aa,Od2aa, by="date") 
base5<-merge(base4, Od3aa, by="date")
base6<-select(base5, date,Teau825, Teau827, Teau828)
##la base6 regroupe la date et les 3 variables quantitatives pour l'ACI
base6

# Ne garder que les variables quantitatves
base7 <- select(base6, date)
base7
base8 <- select(base6, -date)
base8

#----------------------------------------------------------------------------------------#
#---------------------------Statistiques descriptives------------------------------------#
#----------------------------------------------------------------------------------------#
summary(Od1aa)
summary(Od2aa)
summary(Od3aa)
summary(Od4aa)

summary(base8)

# Représentation graphique adéquate qui permet pour chaque sonde de visualiser les quartiles
box <- ggplot(Base, aes(factor(Base$id_sonde), Base$Teau)) + geom_boxplot()
box

# Histogramme des valeurs de Teau, représentation de la moyenne par un trait
v <- geom_vline(aes(xintercept=mean(Base$Teau)), color="blue", linetype="dashed", size=1)
htgr <- ggplot(Base, aes(x=Base$Teau)) + geom_histogram() + v
htgr

# Représentation graphique de la température de l'eau des sondes
plot(Teau825~date, data=Od1aa, type="l", col="blue")
plot(Teau827~date, data=Od2aa, type="l", col="red")
plot(Teau828~date, data=Od3aa, type="l", col="green")

# Représentation des 3 courbes sur le même graphique
plot(Teau825~date, data=Od1aa, type="l", col="blue")
lines(Teau827~date, data=Od2aa, type="l", col="red")
lines(Teau828~date, data=Od3aa, type="l", col="green")
legend("topleft", legend=c("825", "827", "828"),
       col=c("blue", "red", "green"), lty=1:2, cex=0.5)

#----------------------------------------------------------------------------------------#
#--------------------------Première ACI sur Teau-----------------------------------------#
#----------------------------------------------------------------------------------------#
# Initialisation du proessus itératif
set.seed(800)
# Analyse sur 3 composantes indépendantes des températures des 3 sondes
a <- fastICA(base8, 4, alg.typ = "parallel", fun = "logcosh", alpha = 1,
             method = "R", row.norm = FALSE, maxit = 200,
             tol = 0.0001, verbose = TRUE)

# Matrice passage A 
a$A
# Matrice des composantes, c'est elle que l'on va représenter
a$S
# Création d'une dataframe à partir de la matrice des sources
A<-data.frame(a$S)
A

# Création d'une matrice B avec les dates
B<-cbind(base7, A)
B

# Calcul des 3 composantes du Signal 825
B$comp1=a$A[1,1]*a$S[,1]
B$comp2=a$A[2,1]*a$S[,2]
B$comp3=a$A[3,1]*a$S[,3]

# Calcul des 3 composantes du Signal 827
B$comp1a=a$A[1,2]*a$S[,1]
B$comp2a=a$A[2,2]*a$S[,2]
B$comp3a=a$A[3,2]*a$S[,3]


# Calcul des 3 composantes du Signal 828
B$comp1aa=a$A[1,3]*a$S[,1]
B$comp2aa=a$A[2,3]*a$S[,2]
B$comp3aa=a$A[3,3]*a$S[,3]

# Représentation des composantes :
# Composantes 1 Signal 825
plot(comp1~date, type="l", data=B, col="blue", ylim=c(-6,6), main="Les trois composantes")
# Composantes 2 Signal 825
lines(comp2~date, type="l", data=B, col="red")
# Composantes3 Signal 825
lines(comp3~date, type="l", data=B, col="black")
legend("topleft", legend=c("Composante 1", "Composante 2", "Composante 3"),
       col=c("blue", "red", "black"), lty=1, cex=0.3)

# Composantes 1-2-3 Signal
par(mfrow=c(2,2))
plot(comp1~date, type="l", data=B, col="blue", main="Signal de la composante 1")
plot(comp2~date, type="l", data=B, col="red", main="Signal de la composante 2")
plot(comp3~date, type="l", data=B, col="black", main="Signal de la composante 3")
par(mfrow=c(1,1))

# Reconstitution des séries à partir des composantes :
# En différenciant les valeurs initiales et les valeurs estimées et en montrant que cette
# différence est nulle, on justifie que l'on a bien recomposé la série.
# Série de la sonde 825
# fastICA centre les données, il faut donc rajouter la moyenne de la série
B$Z=B$comp1+B$comp2+B$comp3+mean(base6$Teau825)
# Vérification
B$diff=B$Z-base6$Teau825
summary(B$diff)#0

# Série de la sonde 827
# fastICA centre les données, il faut donc rajouter la moyenne de la série
B$Za=B$comp1a+B$comp2a+B$comp3a+mean(base6$Teau827)
# Vérification
B$diffa=B$Za-base6$Teau827
summary(B$diffa)#0

# Série de la sonde 828
# fastICA centre les données, il faut donc rajouter la moyenne de la série
B$Zaa=B$comp1aa+B$comp2aa+B$comp3aa+mean(base6$Teau828)
# Vérification
B$diffaa=B$Zaa-base6$Teau828
summary(B$diffaa)#0

#----------------------------------------------------------------------------------------#
#--------------------------Deuxième ACI sur Teau-Tair------------------------------------#
#----------------------------------------------------------------------------------------#
# 825
base1<-aggregate(Teau~date+id_sonde, data=Od1a,FUN=mean, na.rm=TRUE)
base2<-aggregate(Tair.EOBS~date+id_sonde, data=Od1a,FUN=mean, na.rm=TRUE)
base3<-merge(base1,base2, by=c("date", "id_sonde"))
base3<-mutate(base3, diff825=Teau-Tair.EOBS)
base3

# 827
base1a<-aggregate(Teau~date+id_sonde, data=Od2a,FUN=mean, na.rm=TRUE)
base2a<-aggregate(Tair.EOBS~date+id_sonde, data=Od2a,FUN=mean, na.rm=TRUE)
base3a<-merge(base1a,base2a, by=c("date", "id_sonde"))
base3a<-mutate(base3a, diff827=Teau-Tair.EOBS)
base3a

#828
base1aa<-aggregate(Teau~date+id_sonde, data=Od3a,FUN=mean, na.rm=TRUE)
base2aa<-aggregate(Tair.EOBS~date+id_sonde, data=Od3a,FUN=mean, na.rm=TRUE)
base3aa<-merge(base1aa,base2aa, by=c("date", "id_sonde"))
base3aa<-mutate(base3aa, diff828=Teau-Tair.EOBS)
base3aa

# Regroupement des bases
base9<-merge(base3, base3a, by="date") 
base10<-merge(base9, base3aa, by="date")
base11<-select(base10, date, diff825, diff827,diff828)
summary(base11)

# Table numérique utilisée pour l'ACI
base12 <- select(base11, -date)
base13 <- select(base11, date)

# ACI
set.seed(360)
b <- fastICA(base12, 2, alg.typ = "parallel", fun = "logcosh", alpha = 1,
             method = "R", row.norm = FALSE, 
             tol = 0.0001, verbose = TRUE)
b$A
b$S
# Création d'une dataframe
C<-data.frame(b$S) 
C
# Création d'une matrice B avec les dates
D<-cbind(base13, C) 
D

# Représentation des signaux
plot(X1~date, type="l", col="red", data=D, main="composantes")
lines(X2~date, type="l", col="blue", data=D)

# Décomposition de la série 825
D$comp1=b$A[1,1]*b$S[,1]
D$comp2=b$A[2,1]*b$S[,2]

plot(comp2~date, type="l", data=D, col="blue", ylim=c(-5,5))
#noter la composante 2 très faible
lines(comp1~date, type="l", data=B, col="red")

#----------------------------------------------------------------------------------------#
#----------------------------------------ACP---------------------------------------------#
# On va esasayer d'expliquer les composantes trouvées dans l'ACI en intégrant dans l'ACP #
# des variables météorologiques supplémentaires provenant du site EOBS.                  #
# L'exercice n'est mené pour la station 825                                              #
#----------------------------------------------------------------------------------------#
# Données de la pièzométrie
piezo<-read.csv2("PiezoLaFerriereHarang.csv", header=TRUE, dec=",", sep=";")
piezo$date=ymd(piezo$date)

base14<-select(base3, Teau, diff825, Tair.EOBS)
base15<-cbind(D, base14)
PE<-aggregate(Rainf.EOBS~date, data=Od1a, FUN=sum, na.rm=TRUE)#pluie (somme) d'EOBS
base16<-merge(base15, PE, by="date")

base17<-merge(base16,piezo, by="date")
base17<-select(base17, -date)

base17<-mutate(base17,C2=comp2, Ta=Tair.EOBS, C1=comp1,
               Tw=Teau, D=diff825, PE=Rainf.EOBS)
base17<-select(base17, C1,C2, Tw,Ta,D,PE,P)
base17

# PCA permet de lancer ACP
res.pca=PCA(base17, quanti.sup=6:7)

# Valeurs propres
res.pca$eig

# Les variables supplémentaires PE et P ne rentrent pas en compte dans la formation des axes.
# Ils vont nous aider à mieux interpréter les différentes corrélations.
fviz_pca_var(res.pca, col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)

#------------------------------------------------------------------------------------------#
#---------------------Calcul de coefficient de corrélation---------------------------------#
#------------------------------------------------------------------------------------------#
baseCor <- cor(base17)
baseCor

corTaTw = cor.test(Base$Teau, Base$Tair.EOBS)

fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 50))

# Résultats des variables
res.var <- res.pca$var
res.var$coord          # Coordonnées
res.var$contrib        # Contributions aux axes
res.var$cos2           # Qualité de représentation
