library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(ggplot2)
library(plotly)
library(altair)
library(dplyr)
library(reticulate)

#Source data functions
#Reticulate is called here, so no need to call it above.
#This has all necessary functions including get_data_div
source('src/get_data.R')


#data %>% 
#    rename(
#        total_vaccinations_per_hundred = Total_Vaccinations_Per_100,
#        daily_vaccinations_rolling_per_hundred = Daily_Vaccinations_Per_100,
#        total_distributed_raw_per_hundred = Total Distributed Per 100,
#        daily_vaccinations_distributed_rolling_per_hundred = Daily Distributed Per 100,
#        total_vaccinations_raw = Total Vaccinations,
#        daily_vaccinations_rolling = Daily Vaccinations,
#        total_distributed_raw = Total Distributed,
#        daily_distributed_rolling = Daily Distributed
#        )

plot_lower_dash <- function(location_choice, my_dropdown, metric_choice, metric_dropdown) {
    # Fetch data
    data = get_data()

#    data = data.rename(columns={'total_vaccinations_per_hundred': 'Total Vaccinations Per 100',
#                                'daily_vaccinations_rolling_per_hundred': 'Daily Vaccinations Per 100',
#                                'total_distributed_raw_per_hundred': 'Total Distributed Per 100',
#                                'daily_vaccinations_distributed_rolling_per_hundred': 'Daily Distributed Per 100',
#                                'total_vaccinations_raw': 'Total Vaccinations',
#                                'daily_vaccinations_rolling': 'Daily Vaccinations',
#                                'total_distributed_raw': 'Total Distributed',
#                                'daily_distributed_rolling': 'Daily Distributed'})
   
     # Fetch regionally grouped data
    data_div = get_data_div()
    
    if (location_choice == 'States and Provinces'){
        chart <-
        alt$Chart(data, title='State and Provincial Vaccine Data Over Time')$mark_line()$encode(
            x='date:T',
            y=metric_dropdown,
            color=alt$Color('location', legend=alt$Legend(title="Location")),
            strokeDash='country:N', )$transform_filter(
            alt$FieldOneOfPredicate(field='location', oneOf=my_dropdown))$properties(width=800, height=400)

        chart$to_html()
    }
    
    else if (location_choice == 'Regions'){
        region_chart <-
        alt$Chart(data_div, title='Regional Vaccine Data Over Time')$mark_line()$encode(
            alt$X('date:T', axis=alt$Axis(title='Date')),
            y=metric_dropdown,
            color=alt$Color('division', legend=alt$Legend(title="Region")),
            strokeDash='country:N', )$transform_filter(
            alt$FieldOneOfPredicate(field='division', oneOf=my_dropdown))$properties(width=800, height=400)

        region_chart$to_html()
        
    }
}
    
