import geopandas as gpd 
import pandas as pd 
CITIES = ["CHICAGO","NYC"]

GEOID_COL = {
  "NYC":"GEOID",
  "CHICAGO": "geoid10"
}

ID_COL = {
  "NYC":"objectid",
  "CHICAGO":"park_no"
}
    
def calc_park_overlap_for_all_cities():
    for city in CITIES:
        park_tract_overlap(city)
    
def park_tract_overlap(city):
    tracts = gpd.read_file(f"data/raw/tracts_{city}.geojson")
    tracts.rename(columns={GEOID_COL[city]: "tract_id"},inplace=True)
                           
    parks = gpd.read_file(f"data/raw/parks_{city}.geojson")
    parks.rename(columns={ID_COL[city]: "park_id"},inplace=True)

    join  = gpd.sjoin(parks, tracts, predicate='intersects', how="inner", lsuffix="park", rsuffix="tract")
    
    join_with_geom = pd.merge(join, tracts.rename(columns={'geometry':'tract_geometry'}), on='tract_id')
    
    frac_of_tract_is_park=join_with_geom.geometry.intersection(join_with_geom.tract_geometry).area/join_with_geom.tract_geometry.area
    
    frac_of_park_in_tract = join_with_geom.geometry.intersection(join_with_geom.tract_geometry).area/join_with_geom.geometry.area
    
    join['frac_of_tract_is_park'] = frac_of_tract_is_park
    join['frac_of_park_in_tract'] = frac_of_park_in_tract
    
    join.to_file(f"data/processed/park_tract_join_{city}.geojson")
    return join
        
if __name__ == "__main__":
    calc_park_overlap_for_all_cities()