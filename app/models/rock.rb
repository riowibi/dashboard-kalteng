class Rock < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:db_roc)
end