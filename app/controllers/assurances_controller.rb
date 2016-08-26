class AssurancesController < ApplicationController

	require 'open-uri'
  	require 'open_uri_redirections'
  	require 'json'
  	require 'pp'
  	require 'nokogiri'
  	require 'tzinfo'
  	require 'net/https'

	def index
        
        @datel = ['PLK','PBU','SAI',"MTW",'???']
        query_cust = "type_cust like ? OR type_cust like ? OR type_cust like ? OR type_cust like ?", "%SILVER%","%GOLD%","%TITANIUM%","%PLATINUM%"
        
        @ggn = Nonatero.where(witel: 'KALTENG').where(query_cust)

	end

	def download

	    sto = params[:datel]
	    query_gpon = "clid like ? OR clid like ? OR node_id like ? OR node_id like ? OR headline like ? OR headline like ? OR headline like ?", "09%","GP%","09%","GP%","09%","GP%","%ODP%"
	    query_cooper = "clid like ? OR clid like ? OR clid like ? OR node_id like ? OR node_id like ? OR node_id like ? OR headline like ? OR headline like ? OR headline like ?", "COO%","MSA%","DSLA%","COO%","MSA%","DSLA%","COO%","MSA%","DSLA%"
	    query_cust = "type_cust like ? OR type_cust like ? OR type_cust like ? OR type_cust like ?", "%SILVER%","%GOLD%","%TITANIUM%","%PLATINUM%"
	    query_sto = "sto like ?", "%#{sto}%"
	    today = Date.today
	    if Nonatero.exists?
        	case params[:query]
        	when "GPON < 1"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_gpon).where(query_cust).where(hari: 0..1).order('hari DESC')
		    when "GPON 2 - 3"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_gpon).where(query_cust).where(hari: 1..3).order('hari DESC')
		    when "GPON 4 - 7"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_gpon).where(query_cust).where(hari: 3..7).order('hari DESC')
		    when "GPON 8 - 15"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_gpon).where(query_cust).where(hari: 7..15).order('hari DESC')
		    when "GPON 16 - 30"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_gpon).where(query_cust).where(hari: 15..30).order('hari DESC')
		    when "GPON 30 >"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_gpon).where(query_cust).where.not(hari: 0..30).order('hari DESC')   
		    when "GPON"
		      	@rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_gpon).where(query_cust).order('hari DESC')
		    when "COOPER < 1"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cooper).where(query_cust).where(hari: 0..1).order('hari DESC')
		    when "COOPER 2 - 3"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cooper).where(query_cust).where(hari: 1..3).order('hari DESC')
		    when "COOPER 4 - 7"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cooper).where(query_cust).where(hari: 3..7).order('hari DESC')
		    when "COOPER 8 - 15"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cooper).where(query_cust).where(hari: 7..15).order('hari DESC')
		    when "COOPER 16 - 30"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cooper).where(query_cust).where(hari: 15..30).order('hari DESC')
		    when "COOPER 30 >"
		        @rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cooper).where(query_cust).where.not(hari: 0..30).order('hari DESC')   
		    when "COOPER"
		      	@rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cooper).where(query_cust).order('hari DESC')  	
		    else
		    	@rocks = Nonatero.where(witel: 'KALTENG').where(query_sto).where(query_cust).order('hari DESC')
	      	end
		    respond_to do |format|
			    format.html
			    format.csv { send_data @rocks.to_csv }
			    format.xls { send_data @rocks.to_csv(col_sep: "\t") }
		    end
	    end
	end
end
