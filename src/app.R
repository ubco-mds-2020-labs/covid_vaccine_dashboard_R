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
  htmlH1(
    'State-level/Provincial & Regional Comparisons',
    style = list(
      family = 'sans-serif',
      marginTop = 0
      )
  ),
  html.P(
    'Select a set of states/regions and a metric to see time series data. Selecting "Per 100" will display the chosen metric per 100 residents.',
    style = list(family = 'sans-serif')
  ),
  dbcContainer(
    dbcRow(
      dbcCol(list(
        dccDropdown(
          id='my_dropdown',
          placeholder='Select locations...', multi=True,
          style=list(family = 'sans-serif')
        ),
        
        dccRadioItems(
          id='location_choice',
          options = list(list(label = "Regions", value = all_options$Regions),
                         list(label = "States and Provinces", value = all_options$States_and_Provinces)),
          style= list(family= 'sans-serif'),
          value='States and Provinces'
        ),
        
        dccDropdown(
          id='metric_dropdown',
          placeholder='Select metrics...', multi=False,
          style=list(
            height='40px',
            width= '300px',
            display = 'inline-block',
            family = 'sans-serif')
        ),
        
        dccRadioItems(
          id='metric_choice',
          options = list(list(label = "Per 100", value = all_metrics$Per_100),
                         list(label = "Total", value = all_metrics$Total)),
          value='Per 100',
          style=list(
            family = 'sans-serif'),
        )), md=4),
      
      dbcCol(
        htmlIframe(
          id='scatter',
          style=list(
            width = '1200px',
            height = '600px',
            family = 'sans-serif')
        )
      )))
) # list_paren_close
) # html_div_paren_close
) # layout_paren_close
  
#-------------------------------------------------
# Thomson stopped here
# Maybe helpful example, easy to deploy locally:
# https://canvas.ubc.ca/courses/64329/external_tools/20931
# Scroll down to "Multiple input/outputs"


# Set up callbacks/backend
app$callback(
  dash.dependencies.Output('my_dropdown', 'options'),
  dash.dependencies.Input('location_choice', 'value'))
def update_my_output(location_choice):
  return [{'label': i, 'value': i} for i in all_options[location_choice]]

app$callback(
  Output('my_dropdown', 'value'),
  Input('my_dropdown', 'options'))
def set_states_value(available_options):
  return available_options[0]['value']


app$callback(
  dash.dependencies.Output('metric_dropdown', 'options'),
  dash.dependencies.Input('metric_choice', 'value'))
def update_output(metric_choice):
  return [{'label': i, 'value': i} for i in all_metrics[metric_choice]]


app$callback(
  Output('metric_dropdown', 'value'),
  Input('metric_dropdown', 'options'))
def set_metrics_value(available_options):
  return available_options[0]['value']


app$callback(
  dash.dependencies.Output('scatter', 'srcDoc'),
  dash.dependencies.Input('location_choice', 'value'),
  dash.dependencies.Input('my_dropdown', 'value'),
  dash.dependencies.Input('metric_choice', 'value'),
  dash.dependencies.Input('metric_dropdown', 'value')
)
def set_display_children(location_choice, my_dropdown, metric_choice, metric_dropdown):
  return plot_lower_dash(location_choice, my_dropdown, metric_choice, metric_dropdown)


app$run_server(host = '0.0.0.0')