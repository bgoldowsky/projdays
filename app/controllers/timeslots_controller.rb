class TimeslotsController < ApplicationController
  layout "main-layout"

  before_filter :authorize_admin
  before_filter {|c| c.tab = 'Timeslots' }
  attr_accessor :tab

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @timeslots = Timeslot.list
  end

  def new
    @timeslot = Timeslot.new
  end

  def create
    @timeslot = Timeslot.new(params[:timeslot])
    if @timeslot.save
      flash[:notice] = 'Timeslot was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @timeslot = Timeslot.find(params[:id])
  end

  def update
    @timeslot = Timeslot.find(params[:id])
    if @timeslot.update_attributes(params[:timeslot])
      flash[:notice] = 'Timeslot was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Timeslot.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
