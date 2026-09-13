---
date created: 2026-09-12T14:09
date modified: 2026-09-12T16:09
---

# Info

Features: 
tmax_apr, tmax_may, tmax_jun, tmax_jul, 
prcp_apr, prcp_may, prcp_jun, prcp_july
sm_ave, sm_95%, sm_5%, (percentiles cushion the dataset and show the effect of soil moisture differences at the dry and moist ends of seasonal soil conditions)
vod_std (early season change in biomass amount correlates with final yield, variance is independent of local flora differences)

Label: soybean crop yield (t/ha)

# Data processing

Monthly: tmax, prec
$\to$ first 4 columns (until july)

Daily: VOD, SM,
$\to$ first 122 columns (until end of july)

SM -> 

# Citations

**DATASET:**

> L. Martínez-Ferrer, M. Piles, G. Camps-Valls, Crop Yield Estimation and Interpretability With Gaussian Processes, IEEE Geoscience and Remote Sensing Letters, 2020, vol. 18, no 12, p. 2043-2047, DOI: [10.1109/LGRS.2020.3016140](https://doi.org/10.1109/LGRS.2020.3016140) 
> 
> A. Mateo-Sanchis, J. E. Adsuara, M. Piles, J. Muñoz-Marí, A. Pérez-Suay and G. Camps-Valls, "Interpretable Long-Short Term Memory Networks for Crop Yield Estimation," in IEEE Geoscience and Remote Sensing Letters, DOI: [10.1109/LGRS.2023.3244064](https://ieeexplore.ieee.org/document/10041987)
