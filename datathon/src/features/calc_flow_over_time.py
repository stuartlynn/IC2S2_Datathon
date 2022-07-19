import geopandas as gp 
import pandas as pd 
import os 
from od_data_extractor import DataExtractor

SG_DATA={
   "CHICAGO":"data/raw/sg_chicago",
   "NYC": "data/raw/sg_new_york"
}

def produce_park_stats(city):
    overlaps = gp.read_file(f"data/processed/park_tract_join_{city}.geojson")
    chi = DataExtractor(SG_DATA[city])
    all_trips = pd.DataFrame()
    os.makedirs(f"data/features/{city}",exist_ok=True)
    for park, data in overlaps.groupby('park_id'):
        print(f"Doing park {park} with {data.shape[0]} tracts")
        tracts = list(data.tract_id)
        chi.set_destinations(tracts)
        time_series = chi.get_timeseries_df_multi()
        time_series.to_csv(f"data/features/{city}/{park}.csv",index=False)
        

if __name__ == "__main__":
    # produce_park_stats("CHICAGO")
    produce_park_stats("NYC")