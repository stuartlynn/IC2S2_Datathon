import geopandas as gpd 

PARK_GEO_FILES ={
    "NYC" : "https://data.cityofnewyork.us/api/geospatial/4j29-i5ry?method=export&format=GeoJSON",
    "CHICAGO" : "https://data.cityofchicago.org/api/geospatial/ej32-qgdr?method=export&format=GeoJSON" 
}
def download_parks():
    for name, url in PARK_GEO_FILES.items():
        data = gpd.read_file(url)
        data.to_file(f"data/raw/parks_{name}.geojson")
        
        
if __name__ == "__main__":
    download_parks()
        