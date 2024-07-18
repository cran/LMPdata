LMPdata – R package for the EU Labour Market Policy database
================
2024-07-10

# Installation

``` r
# Either
install.packages('LMPdata') # once available on CRAN
# or
remotes::install_github('alekrutkowski/LMPdata')
```

# Explanations

The package provides an easy access to the “Labour Market Policy”
statistics database managed by the European Commission
(Directorate-General for Employment, Social Affairs & Inclusion). The
data can be accessed also via
<https://webgate.ec.europa.eu/empl/redisstat/databrowser/explore/all/lmp?lang=en&display=card&sort=category>.

The package offers only two functions:

- `importData`
- `importLabels`

Usage examples:

``` r
library(LMPdata)

d <- importData(lmp_dataset_code = 'lmp_expsumm',
                filters = list(geo=c('AT','BE','CZ'), unit='MIO_EUR',
                               lmp_type='TOT1_9', exptype=c('XIND','XEMP')))
str(d)
```

    ## Classes 'data.table' and 'data.frame':   134 obs. of  7 variables:
    ##  $ geo        : chr  "AT" "AT" "AT" "AT" ...
    ##  $ unit       : chr  "MIO_EUR" "MIO_EUR" "MIO_EUR" "MIO_EUR" ...
    ##  $ lmp_type   : chr  "TOT1_9" "TOT1_9" "TOT1_9" "TOT1_9" ...
    ##  $ exptype    : chr  "XEMP" "XEMP" "XEMP" "XEMP" ...
    ##  $ time_period: int  1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 ...
    ##  $ value_     : num  334 361 363 464 601 ...
    ##  $ flags_     : chr  "" "" "" "" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>

``` r
g <- importLabels(dimension_code = "geo")
l <- importLabels(dimension_code = "exptype")
str(g)
```

    ## Classes 'data.table' and 'data.frame':   3707 obs. of  2 variables:
    ##  $ geo       : chr  "EUR" "EU" "EU_V" "EU28" ...
    ##  $ geo__label: chr  "Europe" "European Union (EU6-1972, EU9-1980, EU10-1985, EU12-1994, EU15-2004, EU25-2006, EU27-2013, EU28)" "European Union (aggregate changing according to the context)" "European Union (28 countries)" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>

``` r
str(l)
```

    ## Classes 'data.table' and 'data.frame':   15 obs. of  2 variables:
    ##  $ exptype       : chr  "XTOT" "XIND" "XINDPER" "XINDLUMP" ...
    ##  $ exptype__label: chr  "Total" "Transfers to individuals" "Transfers to individuals - periodic cash payments" "Transfers to individuals - lump-sum payments" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>

The following datasets are available:

| lmp_dataset_code | Description                                                                                            |
|------------------|--------------------------------------------------------------------------------------------------------|
| LMP_EXPSUMM      | LMP expenditure by type of action – summary tables                                                     |
| LMP_EXPME        | Detailed expenditure by LMP intervention                                                               |
| LMP_PARTSUMM     | LMP participants by type of action – summary tables                                                    |
| LMP_PARTME       | Detailed data on participants by LMP intervention                                                      |
| LMP_IND_ACTSUP   | Activation-Support – LMP participants per 100 persons wanting to work                                  |
| LMP_IND_ACTRU    | Activation of registered unemployed                                                                    |
| LMP_IND_ACTIME   | Timely activation – share of LMP entrants not previously long-term unemployed                          |
| LMP_IND_EXP      | LMP expenditure in convenient units (% of GDP or purchasing power standard per person wanting to work) |
| LMP_RJRU         | Persons registered with Public Employment Services                                                     |

The following dimensions are available:

| dimension_code | Description                                          |
|----------------|------------------------------------------------------|
| AGE            | Age class                                            |
| EXPTYPE        | Type of expenditure                                  |
| GEO            | Geopolitical entity (reporting) i.e. a country       |
| LMP_TYPE       | Labour market policy interventions by type of action |
| flags\_        | Flags for each statistical observation               |
| REGIS_ES       | Registration with employment services                |
| SEX            | Sex / gender                                         |
| STK_FLOW       | Stock or flow                                        |
| UNIT           | Unit of measure                                      |
