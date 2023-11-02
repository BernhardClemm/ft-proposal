# Ideas for FT election data coverage

## UK poll tracker re-design (Figure 1a)

The re-design of the UK poll tracker, shown below, can be reproduced with the script `code/uk-polltracker.R`. The underlying data is from the [FT page](http://bertha.ig.ft.com/view/publish/dsv/1qDuVHfUgoWnPSUNUDeXLaHfV33RuAPsNC-S1S0tDeKI/data.csv). A few remarks about the methodology:  

- Instead of using "... the most recent poll from each pollster..." like the FT, I use the last 10 for simplicity.
- The FT's exact recency weighting for the UK poll tracker is unknown. On the EP poll page, the methodology mentions "...using an exponential decay formula...", so I create recency weights with a daily exponential decay of an arbitrary 10%. 
- To create the confidence band around the average trend line, I rely on the function `wtd.var` from the `HMisc` package. Note that the computation of variances for weighted average is complex, so this step could be reviewed and improved.

<img src="https://github.com/BernhardClemm/ft-proposal/blob/main/output/uk-polltracker.png?raw=true" width="75%">

## European elections

### Testing projection accuracy

To assess the accuracy of the FT projections, I scraped the total projections from the [FT polling page](https://ig.ft.com/european-parliament-election-polls/) and the [results page](https://ig.ft.com/european-elections-2019-results/) with the script `code/ep-scraping-totals.py`. I scraped the country-level projections from the same pages with the script `code/ep-scraping.py`. The resulting data sets are `data/ft-ep-totals-projections.csv` and `data/ft-ep-totals-results.csv` for the totals, and `data/ft-ep-countries-projections.csv` and `data/ft-ep-countries-results.csv` for the country level. 

#### Totals

To get the mean absolute error of projected seats across party groups, run `code/ep-projections-acc.R`, until and include section "Mean absolute error on group level". The code also produces the following plot of projection error by party group:

<img src="https://github.com/BernhardClemm/ft-proposal/blob/main/output/ep-totals-accuracy.png?raw=true" width="60%">

#### Country level

The same script also produces a plot of projection error at the country-group level:

<img src="https://github.com/BernhardClemm/ft-proposal/blob/main/output/ep-country-accuracy.png?raw=true" width="75%">

### EP country-level poll tracker re-design (Figure 1b)

The Germany polling data was collected manually from the [FT polling page](https://ig.ft.com/european-parliament-election-polls/) and stored as `data/ft-ep-projections-GER.csv`. The graph below can be reproduced with `code/ep-germany-plot.R`. A few remarks about the code:  

- Again, I create recency weights with a daily exponential decay of 10%.
- For the SE of the weighted average, I here use the `survey` package, although that is again a choice to be reviewed.

<img src="https://github.com/BernhardClemm/ft-proposal/blob/main/output/ep-projections-ger.png?raw=true" width="60%">

## US voter movements (Figure 2)

The AP VoteCast can be downloaded [here](https://apnorc.org/projects/ap-votecast-2020-general-elections/) and is not included in the repository because of size. The script `code/us-voter-movements.R` summarizes the data and creates the Sankey plot below.

<img src="https://github.com/BernhardClemm/ft-proposal/blob/main/output/us-voter-movements.png?raw=true" width="75%">
