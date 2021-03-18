import pandas as pd


def get_individual_figures(data):
    # Create df with latest data
    latest_data = data[data['date'] == data['date'].max()]
    # Compute individual figures
    vaccines_today = latest_data[(latest_data['location'] == 'United States') | (latest_data['location'] == 'Canada')][['daily_vaccinations_raw']].sum().iloc[0]
    last_updated = str(latest_data['date'].iloc[0]).split(' ')[0]
    data_start = str(data['date'].min()).split(' ')[0]
    return [vaccines_today,last_updated,data_start]
