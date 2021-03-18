import pandas as pd

def get_latest_data(data):
  latest_data = data[data['date'] == data['date'].max()]
  return latest_data
