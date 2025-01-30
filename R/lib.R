#' LMPdata
#'
#' Easy import of the EU Labour Market Policy data
#'
#' @name LMPdata
#' @import magrittr data.table
NULL

. <- NULL # to pass CRAN check NOTE: no visible binding for global variable '.' or Undefined global functions or variables: .

BaseURL <-
  'https://webgate.ec.europa.eu/empl/redisstat/api/dissemination/sdmx/3.0/data/dataflow/EMPL/'

NumberOfStarsInInfixURL <-
  c(LMP_EXPSUMM=4,
    LMP_EXPME=4,
    LMP_PARTSUMM=6,
    LMP_PARTME=6,
    LMP_IND_ACTSUP=5,
    LMP_IND_ACTRU=6,
    LMP_IND_ACTIME=5,
    LMP_IND_EXP=4,
    LMP_RJRU=6)

infixURL <- function(dataset_code)
  paste0(dataset_code,'/1.0/A',
         rep.int('.*',NumberOfStarsInInfixURL[dataset_code]) %>%
           paste(collapse="")) %>%
  paste0('?')

URLfilters <- function(filters_list)
  if (identical(filters_list,list())) "" else
    filters_list %>%
  .[names(.) %>% setdiff('TIME_PERIOD')] %>%
  {paste0('c[',names(.),']=',
          sapply(., paste, collapse=","))} %>%
  paste(collapse="&") %>%
  `if`('TIME_PERIOD' %in% names(filters_list),
       paste0(.,'&c[TIME_PERIOD]=ge:',
              min(filters_list$TIME_PERIOD),
              '+le:',
              max(filters_list$TIME_PERIOD))
       ,.) %>%
  paste0('&')

suffixURL <-
  'compress=false&format=csvdata&formatVersion=2.0'

removeRedundantColumns <- function(dt)
  dt[, c("STRUCTURE","STRUCTURE_ID","FREQ") := NULL]

`%not in%` <- Negate(`%in%`)

verifiedLmp_dataset_code <- function(lmp_dataset_code) {
  LMP_DATASET_CODE <- toupper(lmp_dataset_code)
  if (LMP_DATASET_CODE %not in% names(NumberOfStarsInInfixURL))
    stop('`',lmp_dataset_code,'` is not recognised as an LMP datatset code!')
  LMP_DATASET_CODE
}

#' Import an LMP dataset
#'
#' The available datasets are:
#' \tabular{ll}{
#' \strong{lmp_dataset_code} \tab \strong{Description} \cr
#' LMP_EXPSUMM \tab LMP expenditure by type of action -- summary tables \cr
#' LMP_EXPME \tab Detailed expenditure by LMP intervention \cr
#' LMP_PARTSUMM \tab LMP participants by type of action -- summary tables \cr
#' LMP_PARTME \tab Detailed data on participants by LMP intervention \cr
#' LMP_IND_ACTSUP \tab Activation-Support -- LMP participants per 100 persons wanting to work \cr
#' LMP_IND_ACTRU \tab Activation of registered unemployed \cr
#' LMP_IND_ACTIME \tab Timely activation -- share of LMP entrants not previously long-term unemployed \cr
#' LMP_IND_EXP \tab LMP expenditure in convenient units (\% of GDP or purchasing power standard per person wanting to work) \cr
#' LMP_RJRU \tab Persons registered with Public Employment Services \cr
#' }
#'
#' @param lmp_dataset_code A dataset code name (string). Case insensitive.
#' @param filters A list of uniquely named atomic vectors or an empty list
#' for importing the full dataset (which can be slow).
#' @return A data.table with several columns: \code{value_} and \code{flags_} as well as
#' the columns for each dimension, \code{geo} i.e. country, \code{time_period}
#' i.e. year, and others.
#' @examples
#' \donttest{
#' importData('lmp_expsumm',
#'            list(geo=c('AT','BE','CZ'), unit='MIO_EUR',
#'                 lmp_type='TOT1_9', exptype=c('XIND','XEMP')))
#' }
#' @export
importData <- function(lmp_dataset_code, filters=list()) {
  stopifnot(is.character(lmp_dataset_code),
            length(lmp_dataset_code)==1,
            is.list(filters))
  LMP_DATASET_CODE <-
    verifiedLmp_dataset_code(lmp_dataset_code)
  FILTERS <-
    if (identical(filters,list())) filters else {
      names. <- names(filters)
      if ( is.null(names.) || any(names.=="") ||
           length(names.)>length(unique(names.)) )
        stop('`filters` must be a list with each element uniquely named!')
      filters %>% set_names(toupper(names(.)))
    }
  paste0(BaseURL,infixURL(LMP_DATASET_CODE),URLfilters(FILTERS),suffixURL) %>%
    fread(sep=',') %>%
    removeRedundantColumns() %>%
    setnames(colnames(.),tolower(colnames(.))) %>%
    setnames(c("obs_value","obs_flag"),
             c('value_','flags_'))
}

#' Import the labels for a dimension code (a code list)
#'
#' The available datasets are:
#' \tabular{ll}{
#' \strong{dimension_code} \tab \strong{Description} \cr
#' AGE \tab Age class \cr
#' EXPTYPE \tab Type of expenditure \cr
#' GEO \tab Geopolitical entity (reporting) i.e. a country \cr
#' LMP_TYPE \tab Labour market policy interventions by type of action \cr
#' flags_ \tab Flags for each statistical observation \cr
#' REGIS_ES \tab Registration with employment services \cr
#' SEX \tab Sex / gender \cr
#' STK_FLOW \tab Stock or flow \cr
#' UNIT \tab Unit of measure \cr
#' }
#'
#' @param dimension_code A dimension code name (string). Case insensitive.
#' @return A data.table with 2 columns: codes in the first, labels in the second.
#' If e.g. \code{dimension_code="geo"}, the first column is named \code{geo} and
#' the second column is named \code{geo__label}.
#' @examples
#' \donttest{
#' importLabels("geo")
#' importLabels("exptype")
#' }
#' @export
importLabels <- function(dimension_code) {
  stopifnot(is.character(dimension_code),
            length(dimension_code)==1)
  paste0('https://webgate.ec.europa.eu/empl/redisstat/api/dissemination/sdmx/2.1/codelist/EMPL/CL_',
         toupper(dimension_code) %>% ifelse(.=='FLAGS_','OBS_FLAG',.),
         '/latest?compressed=false&format=TSV&lang=en') %>%
    fread(header=FALSE, sep='\t') %>%
    setnames(colnames(.),
             c(tolower(dimension_code),
               tolower(dimension_code) %>% paste0('__label')))
}
