import pandas as pd

def get_summary_stats(data):
    # Create df with latest data
    latest_data = data[data['date'] == data['date'].max()]
    # Compute summary stats
    us_sum = latest_data[latest_data['location'] == 'United States'][['total_vaccinations_raw', 'pop_est']]
    us_sum['country'] = 'usa'
    ca_sum = latest_data[latest_data['location'] == 'Canada'][['total_vaccinations_raw', 'pop_est']]
    ca_sum['country'] = 'canada'
    summary = pd.concat([us_sum, ca_sum]).reset_index(drop=True)
    summary['total_vaccinations_per_hundred'] = summary[['total_vaccinations_raw', 'pop_est']].apply(
        lambda x: (x[0] / x[1]) * 100, axis=1)
    summary = summary.round(2)
    return summary
