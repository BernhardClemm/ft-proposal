# Ideas for FT 

## UK poll tracker re-design

The re-design of the UK poll tracker, shown below, can be reproduced with the script `code/uk-polltracker.R`. The underlying data is from the [FT page](http://bertha.ig.ft.com/view/publish/dsv/1qDuVHfUgoWnPSUNUDeXLaHfV33RuAPsNC-S1S0tDeKI/data.csv). A few remarks about the code:  

- Instead of using "... the most recent poll from each pollster..." like the FT poll tracker, I use the last ten for simplicity.
- The FT's exact recency weighting for this poll tracker is unknow. On the EP projection page, the methodology mentions "...using an exponential decay formula...", so I create recency weights with a daily decay of 10%. 
- To create the confidence band around the average trend line, I rely on the function `wtd.var` from the `HMisc` package. Note that the computation of variances for weighted average is complex, so this piece of could be reviewed and improved.

<img src="https://github.com/BernhardClemm/ft-proposal/blob/main/output/uk-polltracker.png?raw=true" width="75%">

## EP projections
### Testing projection accuracy

To assess the accuracy of the FT projections, I scraped, first, the total projections with the script `code/ep-scraping-totals.py` and second, the country-level projections and results with the script `code/ep-scraping.py`. The resulting data sets are `data/ft-ep-totals-projections.csv`, `data/ft-ep-totals-results.csv`, `data/ft-ep-countries-projections.csv` and `data/ft-ep-countries-results.csv`. 

### Totals

To get the mean absolute error of projected seats across party groups, run `code/ep-projections-acc.R`, specifically line under section "Mean absolute error on group level". The code also produces the following plot of error by party group

![](https://github.com/BernhardClemm/ft-proposal/blob/main/output/ep-totals-accuracy.png?raw=true)

### Country level

The same script also produces a plot of projection error at the country-party level:

![](https://github.com/BernhardClemm/ft-proposal/blob/main/output/ep-countries-accuracy.png?raw=true)

## Country-level poll tracker re-design



## US voter movements


 
