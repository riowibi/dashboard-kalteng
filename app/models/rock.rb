class Rock < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:db_roc)

  	def self.to_csv(options = {})
	  	CSV.generate(options) do |csv|
	    	csv << ["Regional"]
	    	all.each do |product|
	      		csv << product.attributes.values_at("regional")
	    	end
	  	end
	end

end