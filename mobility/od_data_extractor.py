import pandas as pd
from glob import glob

def fix_geoid(geoid):
    if len(geoid) == 11:
        return geoid
    else:
        return '0' + geoid
class DataExtractor:
    def __init__(self, data_path: str) -> None:
        self.data = pd.DataFrame([])
        self.df = pd.DataFrame([])
        self.data_path = data_path
        vals = pd.read_csv(f'{data_path}/TractID_List.csv', header=None, dtype={'0': str}).values
        self.tract_ids = [fix_geoid(str(value[0])) for value in vals]
        self.destination = ''
        self.destinations = []
        dates = []
        for file in glob(f'{data_path}/*.csv'):
            if 'TractID_List' in file:
                continue
            else:
                dates.append(file.split('/')[-1].split('.')[0])
        dates.sort()
        self.dates = dates
    
    def set_destination(self, geoid: str) -> None:
        self.destination = geoid
        
    def set_destinations(self, geoids) -> None: #geoids list of string wtf python typing 
        self.destinations = geoids
        
    def set_date(self, date: str) -> None:
        self.date = date
        
    def set_data(self, data: pd.core.frame.DataFrame) -> None:
        self.data = data

    def set_df(self, df: pd.core.frame.DataFrame) -> None:
        self.df = df
        
    def load_data(self, date) -> None:
        self.set_date(date)
        self.set_data(pd.read_csv(f"{self.data_path}/{self.date}.csv", header=None))
        
    def get_trips_to_d(self) -> pd.core.series:
        d_index = self.tract_ids.index(self.destination)
        return self.data[d_index]
    
    def get_trips_df(self) -> pd.core.frame.DataFrame:
        trips_data = self.get_trips_to_d()
        df = pd.DataFrame(
            zip(
                self.tract_ids, 
                [self.destination for i in trips_data],
                trips_data, 
                [self.date for i in trips_data]
            )
        )
        df.columns = ['origin', 'destination', 'trips', 'date']
        df = df[df.trips > 0]
        return df
    
    def get_timeseries_df(self, single_d=True) -> pd.core.frame.DataFrame:
        for idx, date in enumerate(self.dates):
            self.load_data(date)
            if idx == 0:
                df = self.get_trips_df()
            else:
                df = pd.concat([df, self.get_trips_df()])
        if (single_d):
            self.set_df(df)
        return df
    
    def get_timeseries_df_multi(self) -> pd.core.frame.DataFrame:
        for idx, date in enumerate(self.dates):
            self.load_data(date)
            for nested_idx, geoid in enumerate(self.destinations):
                self.set_destination(geoid)
                if idx+nested_idx == 0:
                    df = self.get_trips_df()
                else:
                    df = pd.concat([df, self.get_trips_df()])
        self.set_df(df)
        return df
        
    def export_csv(self, path: str) -> None:
        self.df.to_csv(path, index=False)
        
    def export_parquet(self, path: str) -> None:
        self.df.to_parquet(path)