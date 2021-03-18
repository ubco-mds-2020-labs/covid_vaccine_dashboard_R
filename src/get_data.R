library(reticulate)

# Define paths
virtualenv_path <- '/users/ericphillips/PycharmProjects/RosettaJupyter/venv'
csv_path <- 'data/processed/processed_vaccination_data.csv'

# Download vaccine CSV
processed_vax_url <- 'https://github.com/ubco-mds-2020-labs/covid_vaccine_dashboard/raw/main/data/processed/processed_vaccination_data.csv'
download.file(processed_vax_url,csv_path)

# Set up reticulate
# use_virtualenv(virtualenv_path,required=TRUE)

# Import Python scripts
get_data_python <- import_from_path('get_data', path='src/python',convert=FALSE)
get_data_div_python <- import_from_path('get_data_div', path='src/python',convert=FALSE)
get_geo_data_python <- import_from_path('get_geo_data', path='src/python',convert=FALSE)
get_summary_stats_python <- import_from_path('get_summary_stats', path='src/python',convert=FALSE)
get_individual_figures_python <- import_from_path('get_individual_figures', path='src/python',convert=TRUE)
get_latest_data_python <- import_from_path('get_latest_data',path='src/python',convert=FALSE)

get_data <- function() {
  # Get processed data
  data <- get_data_python$get_data()
  data
}

get_data_div <- function() {
  # Get processed data
  data_div <- get_data_div_python$get_data_div()
  data_div
}

get_geo_data <- function() {
  # Get geo data
  geo_data <- get_geo_data_python$get_geo_data(get_data_python$get_data())
  geo_data
}

get_summary_stats <- function() {
  summary_stats <- get_summary_stats_python$get_summary_stats(get_data_python$get_data())
  summary_stats
}

get_individual_figures <- function() {
  individual_figures <- get_individual_figures_python$get_individual_figures(get_data_python$get_data())
  individual_figures
}

get_latest_data <- function() {
  latest_data <- get_latest_data_python$get_latest_data(get_data_python$get_data())
}
