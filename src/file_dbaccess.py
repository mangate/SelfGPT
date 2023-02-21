import dbaccess
import os
import pandas as pd

class LocalFileDbAccess(dbaccess.DbAccess):
  def __init__(self, dbPath):
    self.dbPath = dbPath

  def get(self):
    df = pd.read_csv(self.dbPath)
    return df

  def save(self, df):
    df.to_csv(self.dbPath,index=False)

  def ensureExists(self):
    if not os.path.isfile(self.dbPath):
        #Create the dataframe with columns for time and message
        df = pd.DataFrame(columns=["time","message", "ada_search"])
        # Save the dataframe to a csv file
        df.to_csv(self.dbPath,index=False)
