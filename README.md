# Ideas for FT 

## UK poll tracker

The re-design of the UK poll tracker, shown below can be reproduced with the script `code/uk-polltracker.R`. The underlying data is from. [http://bertha.ig.ft.com/view/publish/dsv/1qDuVHfUgoWnPSUNUDeXLaHfV33RuAPsNC-S1S0tDeKI/data.csv][]. A few remarks about the code:  

- Instead of using "... the most recent poll from each pollster..." like the FT poll tracker, I use the last ten for simplicity.
- I don't know how exactly the 
- To create a weighted average, the FT is "...using an exponential decay formula...". 

## EP projections

To assess the accuracy of the FT projections, I scraped the country-level projections and results with the script `code/ep-scraping.py`. The resulting data is in `data/ft-ep-projections.csv` and `data/ft-ep-results.csv`
The total projections and results I extracted manually, as well as the polling data underlying German averages. These 

## US voter movements


 