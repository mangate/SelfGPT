from abc import ABC, abstractmethod

class DbAccess:
  @abstractmethod
  def get(self):
    pass

  @abstractmethod
  def save(self, df):
    pass

  @abstractmethod
  def ensureExists(self):
    pass
