class OrdersController < ApplicationController

	require 'open-uri'
  require 'open_uri_redirections'
  require 'json'
  require 'pp'
  require 'nokogiri'
  require 'tzinfo'
  require 'net/https'
    

  def index
      
      @datel = ['PLK','PBU','SAI',"MTW",'???']
      
      # @gangguanGpon = Nonatero.where(witel: 'KALTENG').where("sto like ?", "%#{sto}%").where("clid like ? OR clid like ? OR node_id like ? OR node_id like ? OR headline like ? OR headline like ?", "09%","GP%","09%","GP%","09%","GP%").count

      # @gangguanCooper = Nonatero.where(witel: 'KALTENG').where("sto like ?", "%#{sto}%").where("clid like ? OR clid like ? OR clid like ? OR node_id like ? OR node_id like ? OR node_id like ? OR headline like ? OR headline like ? OR headline like ?", "COO%","MSA%","DSLA%","COO%","MSA%","DSLA%","COO%","MSA%","DSLA%").count
      today = Date.today.strftime("%d/%m/%Y")
      encode_url = URI.encode("http://mydashboard.telkom.co.id/ms2/detil_progres_useetv2_.php?sub_chanel=%&chanel=%&p_kawasan=DIVRE_6&witel=KALTENG&indihome=&kode=1&c_witel=43&p_cseg=%&p_etat=5&start_date=#{today}&end_date=#{today}&indihome=&migrasi=&starclick=&plblcl=&inden=&status_order=PS")
      @psb = Nokogiri::HTML(open(encode_url))
      
      if Order.exists?
          @orders = Order.order(:sc)
          plk = ['KKN','KKP','PLK','PPS','PYM']
          pbu = ['KMI','SUA','PBU']
          sai = ['KPB','SAI']
          mtw = ['AMP','PRC','BNT','TML','MTW']
          @sto = [plk,'KKN','KKP','PLK','PPS','PYM',pbu,'KMI','SUA','PBU',sai,'KPB','SAI',mtw,'AMP','PRC','BNT','TML','MTW',plk+pbu+sai+mtw]
          @statuses = ['UN-SCC','CANCEL COMPLETED','Process SC (Pre Registered)','Process SOA (Registered)','Process ISISKA (VA)','Process ISISKA','Process OSS (Created)','Process OSS (Cancel)','Process OSS (Provision Designed)','Fallout (Data)','Process OSS (Provision Issued)','Fallout (WFM)','Process OSS (Activation Completed)','Fallout (Activation)','Process OSS (Provision Completed)','Process ISISKA (RWOS)','Completed (PS)']
          respond_to do |format|
            format.html
            format.csv { send_data @orders.to_csv }
            format.xls { send_data @orders.to_csv(col_sep: "\t") }
          end
      end

  end

  def download
    sto = params[:datel]
    today = Date.today
    if Order.exists?
      case params[:query]
      when "totalInputHI" 
        @orders = Order.where("orderdate like ?", "%#{today}%").where(sto: params[:datel]).where.not("status in ('CANCEL COMPLETED','Cancel Order')")
      when "totalInputMS2NHI"
          @orders = Order.where("orderdate like ?", "%#{today}%").where(sto: params[:datel]).where(status_va: "VA")
      when "PI>HI"
          @orders = Order.where.not("orderdate like ?", "%#{today}%").where(sto: params[:datel]).where(status_va: "VA").where(status: "Process OSS (Provision Issued)")
      when "PIHI"
          @orders = Order.where("orderdate like ?", "%#{today}%").where(sto: params[:datel]).where(status_va: "VA").where(status: "Process OSS (Provision Issued)")
      when "grandTotal"
          @orders = Order.where(sto: params[:datel]).where(status_va: "VA").where(status: "Process OSS (Provision Issued)")
      when "AC"
          @orders = Order.where(sto: params[:datel]).where(status_va: "VA").where(status: "Process OSS (Activation Completed)")        
      else
      @orders = Order.order(:orderdate)
      end
      respond_to do |format|
        format.html
        format.csv { send_data @orders.to_csv }
        format.xls { send_data @orders.to_csv(col_sep: "\t") }
      end
    end
  end

  def starclick

    request_uri = "https://starclick.telkom.co.id/noss_prod/data/get_order.php?_dc=1471594704134&SearchText=kalteng&Field=ORG&Fieldstatus=&Fieldwitel=&StartDate=&EndDate=&page=1&start=0&limit=8000"
    request_query = ''
    url = "#{request_uri}#{request_query}"

    buffer = open(url.to_s, :read_timeout => 600).read
  
    result = JSON.parse(buffer)

    data = result["order"]
    #
    out = 0
    update = 0
    baru = 0

    data.each do |row|  

    if row
      product = Order.new

      product.sc = row["orderId"]
      product.orderdate = row["orderDate"].to_date
      product.ncli = row["orderNcli"]
      product.customer = row["orderName"]
      product.address = row["orderAddr"]
      product.nd_internet = row["ndemSpeedy"]
      product.nd_voice = row["ndemPots"]
      product.status = row["orderStatus"]
      product.status_message = row["orderPaket"]
      product.odp = row["alproName"]
      product.witel = row["orderPlasa"]
      product.k_contact = row["kcontact"]
      product.inputer = row["username"]
      product.transaction_type = row["jenisPsb"]
      product.sto = row["sto"]

      if Order.find_by(sc: product.sc)
      id = Order.where(sc: product.sc).first.id
        if Order.where(id: id).first.status == product.status 
          next
        else                
          Order.update(id, status: product.status)
          Order.update(id, status_message: product.status_message)
          update += 1   
        end
      else
        baru += 1
        product.save
      end
      else
        out += 1
        next
      end
    end

  ms2n
  redirect_to root_url, notice: "Data Update : #{update}, Baru : #{baru} & Out : #{out}" 

  end

  def ms2n
    
    encode_url = URI.encode("http://mydashboard.telkom.co.id/ms2/detil_progres_useetv2_.php?sub_chanel=%&chanel=%&p_kawasan=DIVRE_6&witel=KALTENG&indihome=&kode=1&c_witel=43&p_cseg=%&p_etat=4&start_date=01/01/2016&end_date=31/12/2016&indihome=&migrasi=&starclick=&plblcl=&inden=&status_order=VA")

    @page = Nokogiri::HTML(open(encode_url))
      #puts page.class   # => Nokogiri::HTML::Document

    update = 0

    @page.css("table tr[bgcolor='']").each do |el|

    	ncli_ms2n = el.css("td")[4].text
    	status_ms2n = el.css("td")[6].text

    	if Order.find_by(ncli: ncli_ms2n)
    		id = Order.where(ncli: ncli_ms2n).first.id

    		if Order.where(id: id).first.status_va == "VA"
          #Order.update(id, statusVA: nil)
          #update += 1
          next
        else                 
        	Order.update(id, status_va: status_ms2n)
        	update += 1   
        end
      else
      	next
      end
    end

  end

  def import
	  
    Order.import(params[:file])
  		# after the import, redirect and let us know the method worked!
  		redirect_to root_url, notice: "Activity Data Imported!"
  	end

  end
