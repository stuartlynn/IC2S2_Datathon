from cenpy import products
import geopandas as gpd

TRACTS = {
    "NYC": "New York",
    "CHICAGO": "Chicago"
}

TRACTS_URLS ={
    "NYC": "https://services5.arcgis.com/GfwWNkhOj9bNBqoJ/arcgis/rest/services/NYC_Census_Tracts_for_2020_US_Census/FeatureServer/0/query?where=1=1&outFields=*&outSR=4326&f=pgeojson",
    "CHICAGO":"https://data.cityofchicago.org/api/geospatial/5jrd-6zik?method=export&format=GeoJSON"
}
VARIABLES = ['B00002*', 'B01002H_001E']

def get_tracts_cenpy():
    for name,ident in TRACTS.items():
        data =products.ACS().from_place(ident, level='tract')
        data.to_file(f"data/raw/tracts_{name}.geojson")

def get_tracts_direct():
    for name, url in TRACTS_URLS.items():
        data = gpd.read_file(url)
        data.to_file(f"data/raw/tracts_{name}.geojson")
        
if __name__ == "__main__":
    get_tracts_direct()