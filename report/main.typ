
#import "./lib.typ": *
#let unit(it) = $thick upright(it)$ 

//COMMA FOR DECIMALS?
#let comma = false

#show math.equation: it => {
    show regex("\d+\.\d+"): it => if comma {
      {show ".": {(","+h(0pt))}
        it}} else {
            {show ".": {("."+h(0pt))}
        it}
        }
    it
}

#set bibliography(
    style: "ieee",
    title: "Bibliography"
  )

#show bibliography: set heading(numbering: "1.")

//SET OTHER PARAMS
#show: it => lab-report(
  doc-context: "CS-C3240 Machine Learning",
  doc-title: "Modelling crop yields based on early season weather, soil, and growth data",
  author: "",
  affiliation: "Aalto University",
  logo: image("assets/logo-question.png", width: 4cm),
  language: "en",
  compact-mode: false,
  it
)


#pagebreak(weak: true)

// = Introduction

/*Year after year, climate change renders acres of farmland unsuitable for agricultural use @youclimatedrivenglobalcropland2025. At the same time, global food demand is increasing with rising food waste amounts and the global population count @oecdoecdfaoagriculturaloutlook2025. Maintaining a livable planet and secured food supplies for the forseeable future will necessitate a shift from animal-based foods to more plant- and crop-based options. Even barring this shift, with massive animal agriculture occurring worldwide, the need for crops for animal feed is at an all time high. Future food production chains require rigorous optimisation and modelling systems to enable food security, and with drastic weather events year by year and changing conditions, being able to model end-of-season harvest based on early-season conditions enables food producers to plan ahead and optimise their logistics, storage spaces, and pricing/marketing systems to account for the amount of grain. */

= Problem formulation

A model can be trained to predict the crop yield of a specific crop based on early-season (Apr-Jul) conditions. While a regression model is best for this task, the question whether to regularise the model arises. 

A dataset on CONUS (contiguous Unites States) agricultural details was utilised @martinez-ferrercropyieldestimation2021, @mateo-sanchisinterpretablelongshortterm2023. This dataset includes measurements on corn, wheat, and soy yields, as well as corresponding values for precipitation (monthly), soil moisture (daily), maximum temperature (monthly), VOD (vegetative optical depth, daily), and EVI (enhanced vegetation index, daily). All measurements are continuous in value. Soybean was chosen as the crop of interest for this model as it is a widely grown crop for both human consumption and animal feed. 

From this dataset, datapoints were individual yields for a specific county and a specific year. The years measured were 2015-2018, and there was a datapoint for each of the counties measured for each year. 
Each datapoint used the soybean crop yield in#unit("t/ha") as a label. 12 features were chosen for the model, with dates ranging from April to end of July:
+ Maximum temperature for each month [#sym.degree$"C"$]
+ Total precipitation for each month [mm]
+ Arithmetic average of soil moisture measurements #unit($[m^3 dot m^(-3)]$) 
+ The 95th percentile and 5th percentile of soil moisture measurements #unit($[m^3 dot m^(-3)]$)
+ Standard deviation of VOD

= Methods

The dataset contains 2060 datapoints, split into 515 datapoints per year, one per each county. Given the even spread of 4 datapoints per county, all datapoints were treated equally. First the data was cropped to include values only for the time period from start of April to end of July. Maximum temperature measurements and precipitation measurements were combined into one csv file with the label vector. Soil moisture and VOD were processed as separate csv files due to the large number of measurements.


From the features, a dataframe containing values for all precipitation and maximum temperature values for the months April-July, different statistical values thereof, and several different statistical values of the SM and VOD datasets was constructed. A pearson cross-correlation matrix was created for this dataframe, shown in @correlation.

#figure(
  image("assets/corr_1.jpg"),
  caption: [Pearson cross-correlation matrix of measurement values for feature selection.]
) <correlation>

The matrix in @correlation shows low correlations for many of the potential features with the label 'yield'. 

VOD values were selected to be represented by the standard deviation over the four months. This was done due to their high correlation with each other as well as low correlation with the label. In addition, mean values for VOD could be misleading since existing permanent vegetation in the measurement area could skew the values. The change in VOD was considered to represent the change in crop biomass most accurately.
Maximum temperature values were chosen to be kept as-is despite their high co-linearity. The response of soybean growth to temperature fluctuations is highly different in different stages of the crop's growth cycle @hatfieldtemperatureextremeseffect2015. All temperature values also show a rather high correlation with the label compared to other features. 
Precipitation values were all kept. They have a low co-linearity and acceptably low values for cross-correlation with other features. 
Soil moisture was chosen to be represented by three values: the arithmetic mean, the 5th percentile, and the 95th percentile. The mean represents overall differences in average soil moisture. The 5th and 95th percentiles take into account exceptionally dry and humid conditions, respectively, while being slightly less susceptible to extreme outliers. The selected features and their cross-correlations are shown in @correlation2.

#figure(
  image("assets/corr_2.jpg", width: 80%),
  caption: [Pearson cross-correlation matrix of chosen features.]
)<correlation2>

As the label is continuous in value, a regression model was thought to be most suitable for this problem. The co-linearity of some features prompted the the consideration of a model with regularisation. The featured for maximum temperature values and for soil moisture values have strong cross-correlation, but they all still affect crop yields in different ways. A Ridge regression was chosen to account for this problem specifically. 

#emph([Linear regression is used to predict the yield values based on the chosen features. It outputs a continuous variable calculated on the features, with each feature having a specific weight coefficient. A common method to determine the coefficients is the squared error. The issue with an ordinary squared error loss function is the blow-up of coefficients: especially in cases, where some features exhibit co-linearity, they may be assigned extremely large coefficients correcting for each other, which leads to overfitting and high sensitivity.])

Ridge regression adds a penalty term to the squared error loss function based on the square of the coefficients, unlike L1 style regularisation methods such as LASSO. This ensures that no features are regularised to zero coeffients and thus maintains all feature data, while also effectively controlling the scale of the coefficients. The result is an L2 regularised mean squared error loss function. 

K-fold cross-validation ... because the data is in a 4-year split for certain counties ... the random selection of a singular data split could skew training values to favor certain counties or years. The data was also shuffled to randomise years and counties, since by default the data frame regularly cycles thorugh counties and years. 

Data was split into four sections as it is grouped by year. The latest year was chosen as the tesing set. The remaining three years of data from 2015 to 2017 were used as data in a leave-one-year-out validation method to find the optimal Ridge parameter $alpha$. Values for this hyperparameter were tested over a logarithmic range of 50 values from 0.001 to 100 000.


// = Results
// = Conclusion
= Use of AI

Several large language models by Anthropic (Claude) were utilised in the making of this project for assistance and automation in the following tasks:
+ Comparing different data from the original datasets to determine which would show valuable information as features, including but not limited to explanations of concepts such as VOD (vegetation optical depth) and EVI (enhanced vegetative index).
+ Finding methods for different taks to be completed on the data set from the PANDAS and NUMPY documentations.
+ Error checking and code validation.


#bibliography("assets/2026-09-ml-project.bib")

= Appendices

#show link: underline

The code for this model can be found on Github by following this #link("link.com", "link").