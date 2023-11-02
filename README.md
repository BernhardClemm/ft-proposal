# Ideas for FT 

## UK poll tracker

The re-design of the UK poll tracker, shown below, can be reproduced with the script `code/uk-polltracker.R`. The underlying data is from the [FT page](http://bertha.ig.ft.com/view/publish/dsv/1qDuVHfUgoWnPSUNUDeXLaHfV33RuAPsNC-S1S0tDeKI/data.csv). A few remarks about the code:  

- Instead of using "... the most recent poll from each pollster..." like the FT poll tracker, I use the last ten for simplicity.
- The FT's exact recency weighting for this poll tracker is unknow. On the EP projection page, the methodology mentions "...using an exponential decay formula...", so I create recency weights with a daily decay of 10%. 
- To create the confidence band around the average trend line, I rely on the function `wtd.var` from the `HMisc` package. Note that the computation of variances for weighted average is complex, so this piece of could be reviewed and improved. 

![](https://github.com/BernhardClemm/ft-proposal/blob/main/output/uk-polltracker.png?raw=true)

## EP projections

To assess the accuracy of the FT projections, I scraped the country-level projections and results with the script `code/ep-scraping.py`. The resulting data is in `data/ft-ep-projections.csv` and `data/ft-ep-results.csv`
The total projections and results I extracted manually, as well as the polling data underlying German averages. These 

## US voter movements


 
