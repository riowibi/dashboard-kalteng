class Nonatero < Rock
  	
  	self.table_name = "nonatero_view"

  	require 'csv'
	require 'roo'
	require 'open-uri'
	require 'json'
	require 'pp'

  	def self.to_csv(options = {})
	  	CSV.generate(options) do |csv|
	    	csv << ['Datel','STO','No Tiket','NDVoip','NDInet','Hari','Jam','Emosi Pelanggan','Keluhan Pelanggan','Layanan','Paket Internet','Tipe Pelanggan','Detail Pelanggan','Channel Gangguan','Loker','ODP','Status ONU']
	    	all.each do |product|
	      		csv << product.attributes.values_at('kandatel','sto','trouble_no','nd_telp','nd_int','hari','jam','emosi_plg','keluhan_desc','produk_ggn','paket_int','type_cust','headline','channel_ggn','loker','clid','status_onu')
	    	end
	  	end
	end

end