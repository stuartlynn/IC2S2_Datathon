
import pandas as pd
import geopandas as gpd

transit_urls = {
    'driving':'https://uchicago.box.com/shared/static/hkipez75z2p7zivtjdgsfzut4rhm6t6h.parquet',
    'biking':'https://uchicago.box.com/shared/static/cvkq3dytr6rswzrxlgzeejmieq3n5aal.parquet',
    'walking':'https://dl2.boxcloud.com/d/1/b1!wTq-kPEs9JHClABvi70oQY4j7hXVG-hmLklStQj6OR5gGcdfHlSSHW9ZYxowe513PwtxiDclS1L8Ru3n7U_Z9inEyKZVZ2CErLz54l_HSdW7jeuRwE_Y20uIHxo85tpZa6Q9nXs4KMkFS-EY8CLF2uhJZW-7UJQKyHMvFRaMsUgp-rMI-bLm8AE82r2kXlh-WcBda0emkhtrXt7MJPsGjV9i80wBbkPL1Qr7Jzlju4GgHpdBpUTPwIYTFveCAt-ts0BVbUWDvNXmOSGH_37wTgRY8_7cccLKqZ_wEHnZI8kbAVHoMu85evLkG9E9SXaUYOgF7kk5if-VqIMb5f3-C3sy2zCPbcJri49X1J_-vBjPVQh_MfW7hCfhKmUfgfFQwBg9RJu3sCa_1tsIHDi8D2it3qZ4RM_FoTZ5YLV6VAxPKgakNaFY8IRnuQW5CqS2aKACpBkk9-_mn5_j2MAEQfFOhRv--x_RSJ_dSf5WTfV8Qv42n1xmg6_YxMoTo7YBpQa6SVjhdipd-uc9mXwKy-1vQcms3XKwZlhDJcv9vDVjEl0duudFm459IAEOIB3fBbXPX-D0FkWMIWoreJ-3zfrqUYAremPSt4-nFS_VfODr6elZE171WXEbgORh_0V7UvbMe2koXaV0wiQwyLQnBj81lTgK789EtgaJnI7GtiaPhJF6Cobn1dM53xNtbxl21DDJysnaFnI0WEhqi3IYjvBbA8vMUHPyVnSLrjZFkFrVlQBVVHZPUmezxPgnnTdp_NC3OKgtnSGMOOEAREkw-n57I1f8sqQ-4tG-nYrKmehcwffQLVEMkXD4Z9ljNo0tnZoyxUxI857tKgQYPYGDw5X-hYG7JVu8jJmGcoWLsQDZ_5TDVW5ImU_LBQOxx5VsaD4tCQFubt4RerepLyouCAQEGslS3TXdjYGL_J5ys8dR2sAiYIy2QSN-_lKgFOEkBLb8gTpz0VBzJ1y1MZy3ixpNwk9KsAzijJkvkKLzrmbk-mygI560v7251Gr8e-ezGQe3fbsQ6ipxiBoqZSkujn-TEhxPmZO1X65Ty92OREb_mYm4Hp0aS5CMc38aZJ-2ane1s-dRuHpTHVDdk5dxeJ9wfT_DQu79YCEXZJ0V2qTznkpYq8x88jmYdcK6uGLV5gjjaBE7X0YmGAwqsnkf-c-SzoaUCT09GlsSZHCkSeYCJVuJY8SFADbOaZtYYkvBB7vwaflfWHC0l5XLaHNcKTYmn1ikNpxTXp6872sYWUe5V98_v8kWnT46WMI3OouWnHCsnfElbkluR17cgqJbf4Q./download'
}

def filter_matrices(city, data, tracts):
    tracts['tract_id'] = pd.to_numeric(tracts['tract_id'])
    data = data[data['origin'].isin(tracts['tract_id'])]
    data = data[data['destination'].isin(tracts['tract_id'])]
    return data
    

def download_matrices():
    chi_tracts = gpd.read_file("../data/processed/park_tract_join_CHICAGO.geojson")
    nyc_tracts = gpd.read_file("../data/processed/park_tract_join_NYC.geojson")
    for name, url in transit_urls.items():
        data = pd.read_parquet(url)
        chi_od = filter_matrices("CHICAGO", data, chi_tracts)
        nyc_od = filter_matrices("NYC", data, nyc_tracts)
        print(chi_od.head())
        print(chi_od.shape)
        print(nyc_od.head())
        print(nyc_od.shape)
        chi_od.to_csv(f".../mobility/data/transit matrices/CHI_{name}.csv")
        nyc_od.to_csv(f".../mobility/data/transit matrices/NYC_{name}.csv")



            
if __name__ == "__main__":
    download_matrices()