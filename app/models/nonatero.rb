class Nonatero < Rock
  self.table_name = "nonatero_view"


  	def self.to_csv(options = {})
	  	CSV.generate(options) do |csv|
	    	csv << ["Regional"]
	    	all.each do |product|
	      		csv << product.attributes.values_at("regional")
	    	end
	  	end
	end

end