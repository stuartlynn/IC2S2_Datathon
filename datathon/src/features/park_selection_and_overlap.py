import geopandas as gpd 

CITIES = ["CHICAGO","NYC"]

GEOID_COL = {
  "NYC":"GEOID",
  "CHICAGO": "geoid10"
}
def calc_park_overlap_for_all_cities():
    for city in CITIES:
        park_tract_overlap(city)
    
def park_tract_overlap(city):
    tracts = gpd.read_file(f"data/raw/tracts_{city}.geojson")
    tracts.rename(columns={GEOID_COL[city]: "tract_id"},inplace=True)
    parks = gpd.read_file(f"data/raw/parks_{city}.geojson")
    join  = gpd.sjoin(parks, tracts, predicate='intersects', how="inner", lsuffix="park", rsuffix="tract")
    join.to_file(f"data/processed/park_tract_join_{city}.geojson")
        
if __name__ == "__main__":
    calc_park_overlap_for_all_cities()