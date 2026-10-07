
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

Year after year, climate change renders acres of farmland unsuitable for agricultural use @youclimatedrivenglobalcropland2025. At the same time, global food demand is increasing with rising amounts of food waste and a growing population @oecdoecdfaoagriculturaloutlook2025. Maintaining a liveable planet and secured food supplies for the foreseeable future will necessitate a shift from animal-based foods to more plant and crop-based options. Even barring this shift, with massive animal agriculture occurring worldwide, the need for crops for animal feed is at an all time high. Future food production chains require rigorous optimisation and modelling systems to ensure food security, and with drastic weather events occurring year after year and conditions changing rapidly, being able to model end-of-season harvest based on early-season conditions enables food producers to plan ahead and optimise their logistics, storage spaces, and pricing or marketing systems to account for the amount of grain.

This report presents a dataset for soybean crop yields and weather conditions as well as the feature selection process and problem formulation (@formulation), and attempts to apply two different models, ridge regression and logistic regression, to predict soybean yields (@methods). It outlines the results and the limitations of the data (@results) and discusses possible improvements to create a more functional model (@conclusion).

= Problem formulation <formulation>

A model can be trained to predict the crop yield of a specific crop based on early-season (Apr-Jul) conditions. This could be done using a regression  model to predict the absolute yield, or by using a classification model to predict yield anomalies for given seasonal conditions. 

A dataset on CONUS (contiguous United States) agricultural details was utilised, found on Zenodo @martinez-ferrerremotesensingdata2023, @martinez-ferrercropyieldestimation2021, @mateo-sanchisinterpretablelongshortterm2023. This dataset includes measurements on corn, wheat, and soy yields, as well as corresponding values for precipitation (monthly), soil moisture (daily), maximum temperature (monthly), VOD (vegetation optical depth, daily), and EVI (enhanced vegetation index, daily). All measurements are continuous in value. Soybean was chosen as the crop of interest for this model as it is a widely grown crop for both human consumption and animal feed. 

From this dataset, data point labels were individual yields for a specific county and a specific year. These were used for a supervised learning application. The years measured were 2015-2018, and there was a data point for each of the counties measured for each year. 
For the regression model the label to predict is the crop yield for the season in #unit("t/ha"). The classification model predicts a binary label based on whether the crop yield for the year was larger (1) or smaller (0) than the mean between 2015-2017 for a given county.  12 features were chosen for the model, with dates ranging from April to end of July:
+ Maximum temperature for each month [#sym.degree$"C"$]
+ Total precipitation for each month [mm]
+ Arithmetic average of soil moisture measurements [#unit($m^3 dot m^(-3)$)] 
+ The 95th percentile and 5th percentile of soil moisture measurements [#unit($m^3 dot m^(-3)$)]
+ Standard deviation of VOD

= Methods <methods>

The dataset contains 2060 data points, split into 515 data points per year, one per each county. Given the even spread of 4 data points per county, all data points were treated equally. First the data was cropped to include values only for the time period from start of April to end of July. Maximum temperature measurements and precipitation measurements were combined into one CSV file with the label vector. Soil moisture and VOD were processed as separate CSV files due to the large number of measurements.


From the features, a dataframe containing values for all precipitation and maximum temperature values for the months April-July, and several different statistical values of the SM and VOD datasets was constructed. A Pearson cross-correlation matrix was created for this dataframe, shown in @correlation.

#figure(
  image("assets/corr_1.jpg"),
  caption: [Pearson cross-correlation matrix of measurement values for feature selection.]
) <correlation>

The matrix in @correlation shows weak linear correlations for many of the potential features with the label 'yield'. 

VOD values were selected to be represented by the standard deviation over the four months. This was done as the change in VOD was considered to represent the change in crop biomass most accurately. Mean values for VOD could be misleading since existing permanent vegetation in the measurement area could skew the values, and most other VOD metrics had high correlation with each other as well as low correlation with the label. EVI was dropped as a feature as it overlaps with VOD as a vegetation indicator. Maximum temperature values were chosen to be kept as-is despite their high collinearity. The response of soybean growth to temperature fluctuations is highly different in different stages of the crop's growth cycle @hatfieldtemperatureextremeseffect2015. All temperature values also show a rather high correlation with the label compared to other features. 
Precipitation values were all kept. They have a low collinearity and acceptably low values for cross-correlation with other features. 
Soil moisture was chosen to be represented by three values: the arithmetic mean, the 5th percentile, and the 95th percentile. The mean represents overall differences in average soil moisture. The 5th and 95th percentiles take into account exceptionally dry and humid conditions, while being slightly less susceptible to extreme outliers. For the classification model yield anomaly was calculated by subtracting the mean yield between 2015 and 2017 from the year's yield for a county and was used to construct the binary labels. The selected features and their cross-correlations are shown in @correlation2.


#figure(
  image("assets/corr_2.png", width: 50%),
  caption: [Pearson cross-correlation matrix of chosen features with both labels, yield and yield anomaly (from which the classifier is to be derived).],
)<correlation2>

== Ridge regression

A linear regression model was chosen as a first-order approximation of an otherwise more complex yield response, as the 4-year dataset cannot support more complex models. The collinearity of some features prompted the consideration of a model with regularisation. The features for maximum temperature values and for soil moisture values have strong cross-correlation, but they all still affect crop yields in different ways. Ridge regression was chosen to account for this problem specifically. 

Ridge uses a linear map from the 12 chosen features to the predicted yield: $h(bold(x)) = bold(w)^top bold(x) + b$, $bold(w) in RR^12$. Each feature contributes its weight times its value to the prediction and each weight vector acts as one hypothesis. Fitting weights based on a squared error loss function can lead to a blow-up of coefficients: in cases where some features exhibit collinearity, they may be assigned extremely large coefficients correcting for each other, leading to overfitting and high sensitivity. Ridge adds an L2 penalty term $alpha norm(bold(w))_2^2$ to the loss function. It shrinks weights toward zero while still keeping all 12 features in the model (L1 regularisation could remove some), effectively controlling the scale of the coefficients. 

All features were normalised using StandardScaler, because some are on vastly different scales. For the ridge regression's regularisation to treat all features equally, they must have 0 mean and unit variance.

Data was split into four sections by year to ensure that the counties would be distributed as evenly as possible. The latest year was chosen as the testing set (515 datapoints). The remaining three years of data from 2015 to 2017 were used as data in a k-fold cross validation method with $k=3$, each fold being one year, to find the optimal ridge parameter $alpha$ (1545 total datapoints). Values for this hyperparameter were tested over a logarithmic range of 20 values from 0.01 to 100 000. The folds were split by year, to avoid the issue of one county being overrepresented in a fold. After the optimal $alpha$ is determined, the whole training set of data from 2015 to 2017 was used to train the ridge regression model.

== Logistic regression

A classification model was also tested, as planning decisions are often binary, #emph("e.g.") increase or decrease capacity. The model used the same normalised features as the regression model with a binary label of whether the yield of a year is 'better than usual' or 'worse than usual' (see @formulation).

Logistic regression uses the same linear map as ridge, setting the class by the output sign: $hat(y) = 1$ if $h(bold(x))>=0$, else $0$. Using the same hypothesis space makes differences in results arise from the problem formulation and loss instead of model capacity. A sigmoid function maps $h(bold(x))$ to $P(y=1|bold(x))$. Its non-linearity makes squared error non-convex and minimising the loss function sensitive to local minima. Logistic loss is convex for this hypothesis space and is used as the loss function, with an added L2 regularisation with strength $1 slash C$. @jungmachinelearningbasics2022

The same year-wise 3-fold cross validation was used to find the optimal regularisation weight $1 slash C$, chosen from 10 values in a logarithmic scale, $[10^(-4), 10^4]$. Each value was scored by balanced accuracy, the mean recall of both classes, independent of class proportions. The optimal value was used to refit the model on all 2015-2017 data. 

= Results <results>

The training RMSE for ridge regression was $1.83$ and the validation RMSE was $2.00$, suggesting that the model is not overfitting. The test RMSE was $2.13$, $"R"^2≈0.086$. The model settled on an $alpha$ value of around $264$, #emph("i.e.") a regularisation term within the tested grid. The low $"R"^2$ value, however, shows that this model is barely better than a mean constant prediction (RMSE $2.23$) and hardly of any practical use. 

For the logistic model, balanced accuracy for the training set was $0.502$ and for the validation set $0.490$. The training process of the logistic regression resulted in a $1 slash C$ value of $10^4$, the strongest regularisation available. All cross-validation scores fell below the 'random-chance' $0.5$ threshold, so no regularisation was found to give better-than-chance performance. The weights were shrunk to $|w|< 0.02$, and thus every 2018 probability lies between $0.505$ and $0.553$. All counties were classified to a positive yield anomaly for the testing year, as the training data contained more positive anomalies than negative anomalies. This resulted in a test accuracy score of $59%$ and a balanced accuracy of $0.5$, equaling the majority-class baseline. The ROC-AUC score was around $0.637$, so the model ranks counties somewhat better than chance for this specific season. The confusion matrix for the test set can be found in @confmat. 

#figure(
  image("assets/confmat.png", width: 80%),
  caption: [Confusion matrix showcasing the predictions made by the logistic regression model.],
)<confmat>


May 2018, included in the testing set, happened to be the hottest May on record in the contiguous United States @contiguousushad2018, which likely led to the poor performance. Maximum temperature for that month was 1.95 standard deviations above the training mean. This suggests the model is very sensitive to anomalous years.

Despite ridge regression's poor performance, it was chosen for this problem as the logistic regression model had no better than chance performance for validation sets while ridge still barely beat its baseline.

= Conclusion <conclusion>

The report outlines the data pre-processing, feature selection, and the training and testing of the models. Both models resulted in poor performance, and would not be of use in practice. For both models the training and validation errors were rather similar and suggest neither model overfit. The logistic model underfit and predicted a constant class, while ridge barely beat its constant baseline. For this reason ridge regression was determined to be the better model for this dataset.

The results strongly highlight the limitations of the dataset. A longer time period of more varied seasons is needed. Training models on only three seasons to predict a fourth resulted in the models not being able to differentiate weather effects from location effects. A dataset from fewer counties but a longer time period would yield better models. 

The label choice for the regression model keeps location differences in crop yields, as it predicts yield for a data point directly. This worsens the model's generalisability due to inherent differences between counties not accounted for, such as soil quality, nutrient content, and farming practices. Engineering both the features and label to be county-relative, as the logistic label already was, could help mitigate these issues. Non-linear models could also produce more accurate predictions as yield responses to weather effects often have an optimum point @hatfieldtemperatureextremeseffect2015. 

= Use of AI

Large language models by Anthropic (Claude) were used in the making of this project for assistance in the following tasks:
+ Comparing data from the original datasets to determine which would show valuable information as features.
+ Searching the pandas and NumPy documentations.
+ Error checking and code validation.
+ Text checking on clarity, typos, structure.

#bibliography("assets/2026-09-ml-project.bib")

#pagebreak(weak:true)
= Appendices

#show link: underline

The code for this model can be found in the file 'code_final.ipynb' by following this #link("https://anonymous.4open.science/r/ml-project-6407/code_final.ipynb", "link").