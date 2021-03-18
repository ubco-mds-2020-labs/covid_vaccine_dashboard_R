source('src/get_data.R')
library(altair)
library(dplyr)

plot_upper_dash <- function() {
  # Get data
  data <- get_data()
  latest_geo_data <- get_geo_data()
  summary <- get_summary_stats()
  individual_figures <- get_individual_figures()
  latest_data <- get_latest_data()
  summary_tibble <- as_tibble(py_to_r(summary))
  
  # Create summary plots
  summary_text_size <- 20
  summary_width <- 400
  summary_height <- 35
  
  last_updated_plot <-
    alt$Chart(tibble(text = individual_figures[[2]]))$mark_text(size = summary_text_size)$encode(text =
                                                                                                   'text:N')$properties(width = summary_width,
                                                                                                                        height = summary_height,
                                                                                                                        title = 'Map Last Updated:')
  total_today_plot <-
    alt$Chart(tibble(vaccines_today = individual_figures[[1]]))$mark_text(size = summary_text_size)$encode(text =
                                                                                                             'vaccines_today:Q')$properties(width = summary_width,
                                                                                                                                            height = summary_height,
                                                                                                                                            title = 'Doses Administered Today in USA & Canada:')
  
  us_total_plot <-
    alt$Chart(summary_tibble[summary_tibble$country == 'usa',])$mark_text(size =
                                                                            summary_text_size)$encode(text = 'total_vaccinations_raw:Q')$properties(width =
                                                                                                                                                      summary_width,
                                                                                                                                                    height = summary_height,
                                                                                                                                                    title = 'Doses Administered in USA')
  us_hundred_plot <-
    alt$Chart(summary_tibble[summary_tibble$country == 'usa',])$mark_text(size =
                                                                            summary_text_size)$encode(text = 'total_vaccinations_per_hundred:Q')$properties(width =
                                                                                                                                                              summary_width,
                                                                                                                                                            height = summary_height,
                                                                                                                                                            title = 'Doses Administered per 100 in USA')
  ca_total_plot <-
    alt$Chart(summary_tibble[summary_tibble$country == 'canada',])$mark_text(size =
                                                                               summary_text_size)$encode(text = 'total_vaccinations_raw:Q')$properties(width =
                                                                                                                                                         summary_width,
                                                                                                                                                       height = summary_height,
                                                                                                                                                       title = 'Doses Administered in Canada')
  ca_hundred_plot <-
    alt$Chart(summary_tibble[summary_tibble$country == 'canada',])$mark_text(size =
                                                                               summary_text_size)$encode(text = 'total_vaccinations_per_hundred:Q')$properties(width =
                                                                                                                                                                 summary_width,
                                                                                                                                                               height = summary_height,
                                                                                                                                                               title = 'Doses Administered per 100 in Canada')
  
  summary_plot <-
    alt$hconcat(
      alt$vconcat(last_updated_plot, total_today_plot),
      alt$vconcat(us_total_plot, ca_total_plot),
      alt$vconcat(us_hundred_plot, ca_hundred_plot)
    )
  
  # Define chart elements
  choro_tooltip <-
    list(
      alt$Tooltip('location:N', title = 'State/Province'),
      alt$Tooltip(
        'total_vaccinations_per_hundred:Q',
        title = 'Total Doses Administered per 100',
        format = '.2f'
      ),
      alt$Tooltip(
        'total_vaccinations_raw:Q',
        title = 'Total Doses Administered',
        format = '.0f'
      ),
      alt$Tooltip('pop_est:Q', title = 'Estimated Population', format = '.0f')
    )
  click_location <-
    alt$selection_single(
      fields = list('country', 'location'),
      init = list(country = 'usa', location = 'California'),
      empty = 'none'
    )
  line_tooltip <- list(alt$Tooltip('location:N', title = 'Location'))
  
  line_height <- 265
  left_width <- 345
  
  # Create map
  base <-
    alt$Chart(latest_geo_data)$mark_geoshape(stroke = 'black', strokeWidth =
                                               0.5)$encode()$properties(width = 720,
                                                                        height = 700,
                                                                        title = 'Total COVID-19 Vaccinations Administered per 100 Residents')$project(type =
                                                                                                                                                        'albers')
  choro <-
    alt$Chart(latest_geo_data)$mark_geoshape(stroke = 'black', strokeWidth =
                                               0.5)$encode(
                                                 alt$Color(
                                                   'total_vaccinations_per_hundred',
                                                   type = 'quantitative',
                                                   scale = alt$Scale(scheme = 'blues'),
                                                   legend = alt$Legend(title = 'Doses per 100')
                                                 ),
                                                 tooltip = choro_tooltip
                                               )$add_selection(click_location)
  
  # Create line plots
  total_line <-
    alt$Chart(data)$mark_line()$encode(
      x = alt$X('date', type = 'temporal', title = 'Date'),
      y = alt$Y(
        'total_vaccinations_per_hundred',
        type = 'quantitative',
        title = 'Total Doses per 100 Residents'
      ),
      color = 'location',
      tooltip = line_tooltip
    )$properties(
      width = left_width,
      height = line_height,
      title = paste(
        'Total Doses Administered per 100 Residents since',
        individual_figures[[3]]
      )
    )$add_selection(click_location)$transform_filter(list(or = list(
      click_location,
      alt$FieldEqualPredicate(field = 'nat', equal = 1)
    )))
  rolling_line <-
    alt$Chart(data)$mark_line()$encode(
      x = alt$X('date', type = 'temporal', title = 'Date'),
      y = alt$Y(
        'daily_vaccinations_rolling_per_hundred',
        type = 'quantitative',
        title = 'Daily Doses per 100 Residents'
      ),
      color = 'location',
      tooltip = line_tooltip
    )$properties(
      width = left_width,
      height = line_height,
      title = paste(
        'Daily Doses Administered per 100 Residents since',
        individual_figures[[3]]
      )
    )$add_selection(click_location)$transform_filter(list(or = list(
      click_location,
      alt$FieldEqualPredicate(field = 'nat', equal = 1)
    )))
  
  # Create text label plot
  state_label <-
    alt$Chart(latest_data)$mark_text(align = 'center',
                                     size = 16,
                                     fontWeight = 'bold')$encode(text = 'location:N')$properties(width = left_width, height =
                                                                                                   20)$transform_filter(click_location)
  
  # Arrange plots
  upper_plot <-
    alt$vconcat(summary_plot, alt$hconcat(
      alt$vconcat(state_label, total_line, rolling_line),
      base + choro
    ))
  upper_plot$to_html()
  
}