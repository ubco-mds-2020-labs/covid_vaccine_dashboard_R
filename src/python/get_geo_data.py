import altair as alt
import geopandas as gpd
import numpy as np
import shapely


def get_geo_data(data):
    # Define file paths
    path_to_geojson = 'data/processed/us_canada.geojson'
    us_can_geojson = gpd.read_file(path_to_geojson)

    # Create df with latest data
    latest_data = data[data['date'] == data['date'].max()]
    
    # Merge geospatial and latest data
    latest_geo_data = us_can_geojson[['name', 'geometry']].merge(latest_data, left_on='name', right_on='location',how='outer').drop(columns='name')
                                                                 
    # Move Hawaii to the right
    latest_geo_data.loc[latest_geo_data['location'] == 'Hawaii', 'geometry'] = latest_geo_data.loc[latest_geo_data['location'] == 'Hawaii', 'geometry'].apply(lambda x: shapely.affinity.translate(x, xoff=20, yoff=0))
        
    return latest_geo_data
    
