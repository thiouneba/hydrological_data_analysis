# Water Temperature Study — La Touques River (Normandy, France)

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)

> **Academic context:** This project was completed in 2022 as part of an MSc in Computer Science.

---

## Project Overview

This project investigates the **thermal dynamics of La Touques**, a river in Lower Normandy, France, using time-series data collected by four submerged sensors deployed at different points along the river (upstream to downstream).

The sensors were anchored to tree roots along the riverbank and kept submerged at a depth sufficient to record water temperature year-round, regardless of seasonal water level fluctuations. Water temperature naturally exhibits seasonal variability: it tends to be cooler at depth (due to groundwater inflow) and warmer near the surface (driven by air temperature).

The core objective of this study is to understand and explain the **variability in water temperature** (the dependent variable) as a function of three independent explanatory variables:

- Air temperature
- Rainfall volume
- Sensor type / sensor location

The dataset contains **93,832 observations** recorded between **2013 and 2018**, across **6 variables**.

![Dataset overview](https://github.com/thiouneEtu/etude_temperature_eau/blob/main/temp_eau1.PNG)

---

## Methodology

### 1. Descriptive Statistics

A preliminary descriptive analysis was conducted to characterize the distribution of water temperature across all four sensors (825, 827, 828, and 830).

Key findings:

- **Overall range:** The minimum recorded temperature across all sensors was **1.897°C** and the maximum was **21.135°C**, both measured by sensor 830.
- **Sensor 825** recorded the highest minimum temperature (3.799°C) and the lowest maximum temperature (17.809°C), suggesting a more thermally stable environment — consistent with an upstream location where groundwater influence is stronger.
- **Average temperature gradient (upstream → downstream):**
  - Sensor 825 recorded temperatures **2.14% lower** than sensor 827 on average.
  - Sensor 827 recorded temperatures **1.61% lower** than sensor 828 on average.
  - Sensor 828 recorded temperatures **4.05% lower** than sensor 830 on average.

These results suggest a consistent downstream warming trend along the river corridor.

![Descriptive statistics table](https://github.com/thiouneEtu/etude_temperature_eau/blob/main/temp_eau2.PNG)

---

### 2. Independent Component Analysis (ICA)

Independent Component Analysis (ICA) is a statistical method for identifying latent factors within a multivariate dataset (Stone, 2002). It decomposes a mixed multivariate signal into a linear combination of statistically independent source signals.

ICA was applied here to separate the underlying temporal components driving water temperature variation.

![ICA — Component time series](https://github.com/thiouneEtu/etude_temperature_eau/blob/main/temp_eau3.PNG)

![ICA — Phase shift between components](https://github.com/thiouneEtu/etude_temperature_eau/blob/main/temp_eau4.PNG)

Key observations:

- **Seasonality** is clearly visible in both extracted components (C1 and C2). Component C2 shows a sharper decline relative to C1, reaching extreme values around 2015 — possibly reflecting abrupt meteorological events during that period.
- **Phase shift analysis** (Figure 2) suggests that air temperature (blue curve) leads water temperature (red curve), which aligns with the physical expectation that air warms and cools more rapidly than water.

---

### 3. Principal Component Analysis (PCA)

Principal Component Analysis (PCA) is a multivariate dimensionality reduction technique that projects correlated variables into a new set of orthogonal, uncorrelated components (Abdi & Williams, 2010). PCA was used here to validate the ICA results and to explore the correlation structure among variables.

![PCA biplot](https://github.com/thiouneEtu/etude_temperature_eau/blob/main/temp_eau5.PNG)

Key findings:

- The PCA retains **92% of total variance**: Dimension 1 (Dim1) accounts for **71%** and Dimension 2 (Dim2) for **21%**.
- **Seven variables** were included: 5 active (C1, C2, Tw, Ta, D) and 2 supplementary (PE, P). Active variables define the axes; supplementary variables are projected onto the factorial plane for interpretation purposes.
- **Dim1** is primarily driven by water temperature (Tw), air temperature (Ta), and their difference (D = Tw − Ta), together contributing **74%** to that axis.
- **Dim2** is almost entirely defined by the two ICA components C1 and C2, contributing **95%** to that axis.
- **Ta and Tw are strongly correlated** (r = 0.91), which is confirmed by their proximity in the biplot.
- **C1 and C2 are orthogonal** by construction (ICA output), confirmed by their perpendicular projection in the (Dim1, Dim2) plane. Their quality of representation (cos²) reaches 0.90 for C1 and 0.99 for C2.
- **Ta and C1 are negatively correlated** (r = −0.78): when air temperature increases, C1 decreases — a finding that likely reflects the ICA's decomposition of the thermal inertia of water.
- **Rainfall (P) and potential evapotranspiration (PE)** are located near the center of the biplot, suggesting they are weakly represented in the first two principal components and may require additional axes for meaningful interpretation.

---

## Results & Conclusion

This study analyzed nearly 94,000 temperature records from the Touques river over a five-year period (2013–2018). Using a combination of ICA and PCA, we showed that:

1. **Air temperature is the dominant driver** of water temperature variability, with a strong positive correlation (r = 0.91) and a measurable phase lag consistent with the thermal inertia of water.
2. **Sensor location (upstream vs. downstream)** has a systematic effect on recorded temperatures, with downstream sensors consistently recording higher average temperatures.
3. **Seasonal patterns** are clearly captured by ICA, with Component 2 highlighting anomalous behavior around 2015 — possibly linked to unusual weather events.
4. **Rainfall** shows a weaker relationship with water temperature in this dataset, though it may play a stronger role at finer temporal scales or in interaction with other variables.

---

## Dataset

| Variable | Description |
|----------|-------------|
| `Tw` | Water temperature (°C) — dependent variable |
| `Ta` | Air temperature (°C) |
| `P` | Rainfall volume (mm) |
| `PE` | Potential evapotranspiration |
| `D` | Temperature differential (Tw − Ta) |
| `Sensor` | Sensor ID (825, 827, 828, 830) |

- **Period:** 2013–2018
- **Observations:** 93,832
- **Sampling:** Sub-daily / continuous

---

## References

- Abdi, H., & Williams, L.J. (2010). Principal component analysis. *WIREs Computational Statistics*, 2(4), 433–459.
- Stone, J.V. (2002). Independent component analysis: An introduction. *Trends in Cognitive Sciences*, 6(2), 59–64.
