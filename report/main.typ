
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

#show figure: it => align(left)[
  #it.body  
  #v(10pt, weak: true)
   #it.caption 
]

#pagebreak(weak: true)

= Introduction

Year after year, climate change renders acres of farmland unsuitable for agricultural use @youclimatedrivenglobalcropland2025. At the same time, global food demand is increasing with rising food waste amounts and the global population count @oecdoecdfaoagriculturaloutlook2025. Maintaining a livable planet and secured food supplies for the forseeable future will necessitate a shift from animal-based foods to more plant- and crop-based options. Even barring this shift, with massive animal agriculture occurring worldwide, the need for crops for animal feed is at an all time high. Future food production chains require rigorous optimisation and modelling systems to ensure food security, and with drastic weather events occurring year after year and conditions chanigng rapidly, being able to model end-of-season harvest based on early-season conditions enables food producers to plan ahead and optimise their logistics, storage spaces, and pricing or marketing systems to account for the amount of grain.

This report presents a dataset for soybean crop yields and weather conditions as well as the feature selection process and problem formulation (@formulation), and attempts to apply two different models, a Ridge regression and a logistic regression, to solve this issue (@methods). It outlines the results and the limitations of the data (@results).

= Problem formulation <formulation>

A model can be trained to predict the crop yield of a specific crop based on early-season (Apr-Jul) conditions. While a regression model is best for this task, the question whether to regularise the model arises. 

A dataset on CONUS (contiguous Unites States) agricultural details was utilised @martinez-ferrercropyieldestimation2021, @mateo-sanchisinterpretablelongshortterm2023. This dataset includes measurements on corn, wheat, and soy yields, as well as corresponding values for precipitation (monthly), soil moisture (daily), maximum temperature (monthly), VOD (vegetative optical depth, daily), and EVI (enhanced vegetation index, daily). All measurements are continuous in value. Soybean was chosen as the crop of interest for this model as it is a widely grown crop for both human consumption and animal feed. 

From this dataset, datapoint labels were individual yields for a specific county and a specific year. These were used for a supervised learning application. The years measured were 2015-2018, and there was a datapoint for each of the counties measured for each year. 
Each datapoint used the soybean crop yield in#unit("t/ha") as a label. 12 features were chosen for the model, with dates ranging from April to end of July:
+ Maximum temperature for each month [#sym.degree$"C"$]
+ Total precipitation for each month [mm]
+ Arithmetic average of soil moisture measurements #unit($[m^3 dot m^(-3)]$) 
+ The 95th percentile and 5th percentile of soil moisture measurements #unit($[m^3 dot m^(-3)]$)
+ Standard deviation of VOD

= Methods <methods>

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
  image("assets/corr_2.png", width: 60%),
  caption: [Pearson cross-correlation matrix of chosen features.],
)<correlation2>

== Ridge regression

As the label is continuous in value, a regression model was thought to be most suitable for this problem. The co-linearity of some features prompted the the consideration of a model with regularisation. The featured for maximum temperature values and for soil moisture values have strong cross-correlation, but they all still affect crop yields in different ways. A Ridge regression was chosen to account for this problem specifically. Linear regression is used to predict continuous values based on the chosen features. It outputs a continuous variable calculated on the features, with each feature having a specific weight coefficient. A common method to determine the coefficients is the squared error. The issue with an ordinary squared error loss function is the blow-up of coefficients: especially in cases, where some features exhibit co-linearity, they may be assigned extremely large coefficients correcting for each other, which leads to overfitting and high sensitivity. Ridge regression adds a penalty term to the squared error loss function based on the square of the coefficients, unlike L1 style regularisation methods such as LASSO. This ensures that no features are regularised to zero coeffients and thus maintains all feature data, while also effectively controlling the scale of the coefficients. The result is an L2 regularised mean squared error loss function. 

All features were normalised using StandardScaler, because some are on vastly different scales. For the Ridge regression's regularisation to treat all features equally, they must have 0 mean and unit variance. 

Data was split into four sections by year to ensure that the counties would be distributed as evenly as possible. The latest year was chosen as the tesing set. The remaining three years of data from 2015 to 2017 will be used as data in a k-fold cross validation method with $k=3$, each fold being one year, to find the optimal Ridge parameter $alpha$. Values for this hyperparameter were chosen tested over a logarithmic range of 20 values from 0.01 to 100 000.

After the optimal $alpha$ is determined, the whole training set of data from 2015 to 2017 will be used to train the Ridge regression model.

== Logistic regression

The problem was also attempted to be solved using a classification model. The model used the same features as the regression model, however, as a label, a measure of whether the yield of a year is 'better than usual' or 'worse than usual' was chosen. This label was calculated by determining the mean yield for each county in the years 2015-2017, and subtracting it from the real yield for each applicable datapoint. The resulting values, 'yield_anomaly', were used then to classify the year as 'good' or 'bad' (1 or 0) based on whether the anomaly was positive or negative, respectively.

Logistic regression uses the log loss function to fit coefficents. MSE loss is not suitable for a categorical label. 

The same four-year data split was used for the logistic regression for reasons discussed above. The logistic regression was trained with a k-fold cross validation with $k=3$ to find the optimal parameter $C$. To score each parameter choice, balanced accuracy was used as it ranks the parameter choices based on their scoring accuracy, and functions in an environment where the classes are imbalanced. The optimal choice of $C$ was used to train the model.

= Results <results>

The predicted labels for the ridge regression were compared to the real labels of the testing set, and were found to correlate at $"R"^2≈0.086$ and with a negative root mean squared error of approximately $2.13$. The model settled on an $alpha$ value of around $264$, i.e. a regularisation term within the tested grid, not pushing the coefficients to either extreme. Regularisation resulted in moderate shrinkage, mainly because of the cross-correlated soil moisture and temperature features. The low correlation value, however, shows that this model is barely better than a constant prediction and hardly of any use in predicting crop yields, and it reflects mostly between-county differences rather than season-to-season variation.

The training process of the logistic regression resulted in a $C$ value of $0.0001$. As this is the smalles value available for the model, no regularisation strength was found to give the logistic model better-than-chance performance on a held-out season, and all CV scores fall below the 'random-chance' $0.5$ threshold. The model defaulted to the class prior, and decided to rank all counties to a positive yield anomaly for the testing year, as the training data contained more positive anomalies than negative anomalies. This resulted in an accuracy score of around 59%, given that around 59% of the labels in the testing set were of positive nature.   

= Conclusion

The results strongly highlight the limitations of our dataset. While over 2000 individual datapoints is a good amount for model training, there is a dire need for data over a longer time period and different seasonal conditions. Training models on only three seasons to predict a fourth resulted in the weather differences being practically negligible in yield prediction. A dataset from fewer counties but a longer time period would yield more applicable models. 

The label choice for the regression model keeps locational variances in crop yields, as it predicts yield for a datapoint directly. This worsens the models generalisability due to inherent differneces between counties not accounted for in the model, such as soil quality, nutrient density, farming practices, #emph("et cetera").

Given that only one datapoint can be collected per season in each location, the data collection period would need to be extemely long, over a decade at least. Thus creating a functional model for this application would be very time-consuming. Perchance.

= Use of AI

Several large language models by Anthropic (Claude) were utilised in the making of this project for assistance and automation in the following tasks:
+ Comparing different data from the original datasets to determine which would show valuable information as features, including but not limited to explanations of concepts such as VOD (vegetation optical depth) and EVI (enhanced vegetative index).
+ Finding methods for different taks to be completed on the data set from the PANDAS and NUMPY documentations.
+ Error checking and code validation.

#bibliography("assets/2026-09-ml-project.bib")

#pagebreak(weak:true)
= Appendices

#show link: underline

The code for this model can be found on Github in the file 'regression_3.ipynb' by following this #link("https://github.com/tomasub/ml-project", "link").