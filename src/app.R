library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(reticulate)
library(dplyr)
library(purrr)
source('src/get_data.R')
source('src/plot_lower_dash.R')
source('src/plot_upper_dash.R')

app <- Dash$new()

data <-  get_data()
data_tibble <- as_tibble(py_to_r(data))
data_div <-  get_data_div()
data_div_tibble <- as_tibble(py_to_r(data_div))

all_options <-  list(
  Regions = data_div$division$unique(),
  States_and_Provinces = data$location$unique()
)

all_metrics = list(
  Per_100 = list('Total Vaccinations Per 100', 'Daily Vaccinations Per 100', 'Total Distributed Per 100',
                 'Daily Distributed Per 100'),
  Total = list('Total Vaccinations', 'Daily Vaccinations', 'Total Distributed', 'Daily Distributed')
)

convert_named_list <- function(list_in){
  named_list <- py_to_r(list_in) %>%
    purrr::map(function(col) list(label = col, value = col))
  named_list <- append(named_list,list(list(label="All",value="all")))
  return(named_list)
}

#-------------------------------------------------------------------------------
# Layout Section

app$layout(htmlDiv(list(
  htmlDiv(
    'USA & Canada COVID-19 Vaccination Rollout Dashboard',
    style = list(
      color = 'blue',
      family = 'sans-serif',
      size = 44,
      marginTop = 50
    )
  ),
  htmlP(
    'Hover over a state/province for more information on its current vaccination progress, or click to examine its vaccination rollout over time via the plots on the left.',
    style = list(family = 'sans-serif')
  ),
  htmlIframe(
    srcDoc = plot_upper_dash(),
    style = list(
      width = '100%',
      height = '1100px',
      border = '0px'
    )
  ),
  dccDropdown(
    id='my_dropdown',
    options = convert_named_list(all_options$States_and_Provinces),
    placeholder='Select locations...',
    multi=TRUE,
    value=list('Alabama','Alaska'),
    style=list(family = 'sans-serif')
  ),
  htmlIframe(
    id='scatter',
    style=list(
      width = '1200px',
      height = '600px',
      family = 'sans-serif')
  )
)))


#----------------------------
# Callbacks Section

# combine all selections together and return plot to first element of the iframe
app$callback(
  list(output('scatter', 'srcDoc')),
  list(input('my_dropdown', 'value')),
  function(my_dropdown){
    # cat("my_dropdown in callbacks is:", my_dropdown)
    return(list(plot_lower_dash(my_dropdown)))
  })

app$run_server(host = '0.0.0.0')