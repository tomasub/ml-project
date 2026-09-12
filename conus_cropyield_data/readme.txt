Readme file for the study of crop yields using remote sensing data
Laura Martínez-Ferrer, Anna Mateo-Sanchis, María Piles, Jordi Muñoz-Marí
v2.0 23/01/2023
--

The files are in CSV to be able to read them easily from any program.

In each directory (corn, soybean and wheat) we have files corresponding to 5 input variables and one output variable (yield).
The county identifier (corn_id, wheat_id, soy_id), and the year (yyyy) are also provided.

In the "Shapefiles" directory are the data necessary for the geospatial representation of the data.
Polygons are provided for the counties that have produced corn (CONUS_corn.shp), soy (CONUS_soy.shp), and wheat (CONUS_wheat.shp).

Input variables 
--------------------
The time series of the 5 input variables have been obtained for one county/year (rows) and range from April to October (columns): 
- EVI (enhanced vegetation index): data every 16 days.
- PRCP: precipitation, monthly.
- SM (soil moisture): daily data.
- TMAX (maximum temperature): monthly data.
- VOD (vegetation optical depth): daily data.

Crop variable
---------------------
A value of yield per county and year has been obtained:
- yield_corn, yield_wheat, yield_soy: crop yield, the variable we want to predict/model. 

Temporal and spatial representation of the data
------------------------------------------------
To identify the year of the input and output data, the variable "yyyy" is provided for each crop:
- yyyy: vector indicating the year of the data/crop (2015, 2016, 2017 or 2018). 

To identify the crop areas we have two files in each directory:
- polygons_XXX.csv, with variables X, Y and IDEN that delimit the area (X,Y) and identify the crop identifier.
- corn_id.csv, wheat_id.csv, soybean_id.csv, with the corresponding crop ID for each row of data. These are repeated 4 times corresponding to each of the 4 years available. The ID can be related to the corresponding county Shapefiles provided. 

* Reference article using this data: 
L. Martínez-Ferrer, M. Piles, G. Camps-Valls, Crop Yield Estimation and Interpretability With Gaussian Processes, IEEE Geoscience and Remote Sensing Letters, 2020, vol. 18, no 12, p. 2043-2047, DOI: 10.1109/LGRS.2020.3016140
A. Mateo-Sanchis, J.E. Adsuara, M. Piles, J. Muñoz-Marí, A. Pérez-Suay, G. Camps-Valls, Interpretable Long-Short Term Memory Networks for Crop Yield Estimation, IEEE Geoscience and Remote Sensing Letters, 2023, under review

Doubts? 

laura.martinez-ferrer@uv.es, anna.mateo@uv.es
