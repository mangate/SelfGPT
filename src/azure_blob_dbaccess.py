import dbaccess
from azure.core.exceptions import ResourceExistsError
import azure.storage.blob as ab
import os
import pandas as pd

class AzureBlobDbAccess(dbaccess.DbAccess):
  def __init__(self, azureConfig):
    self.CONNECTIONSTRING = azureConfig["CONNECTIONSTRING"]
    self.LOCALFILENAME = 'user/data/tmp_database.csv'
    self.CONTAINERNAME = azureConfig["CONTAINERNAME"]
    self.BLOBNAME = azureConfig["BLOBNAME"]

  def get(self):
    blob_service_client = ab.BlobServiceClient.from_connection_string(self.CONNECTIONSTRING)
    container_client = blob_service_client.get_container_client(container=self.CONTAINERNAME)

    with open(file=self.LOCALFILENAME, mode="wb") as download_file:
      download_file.write(container_client.download_blob(self.BLOBNAME).readall())

    df = pd.read_csv(self.LOCALFILENAME)

    print("success",df)

    return df

  def save(self, df):
    df.to_csv(self.LOCALFILENAME,index=False)
    blob_service_client = ab.BlobServiceClient.from_connection_string(self.CONNECTIONSTRING)
    blob_client = blob_service_client.get_blob_client(container=self.CONTAINERNAME, blob=self.BLOBNAME)
    with open(file=self.LOCALFILENAME, mode="rb") as data:
        blob_client.upload_blob(data, overwrite=True)

  def ensureExists(self):
    blob_service_client = ab.BlobServiceClient.from_connection_string(self.CONNECTIONSTRING)
    try:
      new_container = blob_service_client.create_container(self.CONTAINERNAME)
    except ResourceExistsError:
      print("Container already exists.")

    blob_client = blob_service_client.get_blob_client(container=self.CONTAINERNAME, blob=self.BLOBNAME)
    if(blob_client.exists()):
      print("Blob already exists.")
      return

    #Create the dataframe with columns for time and message
    df = pd.DataFrame(columns=["time","message", "ada_search"])
    # Save the dataframe to a csv file
    df.to_csv(self.LOCALFILENAME,index=False)
    # Upload the created file
    with open(file=self.LOCALFILENAME, mode="rb") as data:
        blob_client.upload_blob(data)    
