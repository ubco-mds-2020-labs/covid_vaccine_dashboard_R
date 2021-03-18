library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
source('src/plot_upper_dash.R')

app <- Dash$new()

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
  )
)))

app$run_server(host = '0.0.0.0')