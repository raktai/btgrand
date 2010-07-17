class CustomersController < ApplicationController
  layout "main"
  
  # GET /customers
  # GET /customers.xml
  def index
    @customers = Customer.find(:all)
    @title = "ลูกค้า"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
    end
  end

  # GET /customers/1
  # GET /customers/1.xml
  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.js # show.rjs
    end
  end

  # GET /customers/new
  # GET /customers/new.xml
  def new
    @customer = Customer.new

    respond_to do |format|
      format.js # new.rjs
    end
  end
  
  def search
    @customers = Customer.search(params[:search])
    respond_to do |format|
      format.js # search.rjs
    end
  end

  # POST /customers
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      format.html { redirect_to(:controller => 'customers') }
      if @customer.save        
        @customers = Customer.find(:all)
        format.js         
      else
        format.js { render :action => "new" }        
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html { redirect_to(:controller => 'customers') }
      if @customer.update_attributes(params[:customer])        
        @customers = Customer.find(:all)
        format.js  { render :action => "create" } 
      else
        format.js   
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:id])   

    respond_to do |format|
      format.html { redirect_to(:controller => 'customers') }
      if @customer.destroy                
        format.js  { redirect_to(:action => "search", :search => params[:search]) } 
      else
        format.js   
      end
    end
  end
end
