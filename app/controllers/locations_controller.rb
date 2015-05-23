class LocationsController < ApplicationController
  layout "main-layout"

  before_filter :authorize_admin
  before_filter {|c| c.tab = 'Locations' }

  attr_accessor :tab

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tab = 'Locations'
    @locations = Location.list
    @timeslots = Timeslot.list
    @no_loc = Array.new
    for s in Sess.find(:all, :conditions=>'location_id is null')
      if (s.project.isreal and s.project.thisyear)
        for t in s.timeslots
          @no_loc[t.id] ||= Array.new
          @no_loc[t.id] << s
        end
      end
    end
    for t in @timeslots
      if @no_loc[t.id]
        @no_loc[t.id].sort! {|a,b| a.project.sort_name <=> b.project.sort_name}
      end
    end
  end

  def list_printable
    @locations = Location.list
    @timeslots = Timeslot.list
    render :layout=>'popup-layout'
  end

  def assign
    @s = Sess.find(params[:id])
    p = @s.project
    @multi = (p.sesses.length > 1)
    if request.post?
      @all = (!!params[:all])
      session[:all_locs] = @all
      if (params[:loc]!="0")
        new_loc = Location.find(params[:loc])
      else
        new_loc = nil
      end
      if (@all)
        Project.transaction do
          p.sesses.each {|s|
            s.location = new_loc
            s.save!
          }
        end
        flash[:notice] = "Moved location of #{p.sesses.length} sessions"
        redirect_to :action=>'assigned'
      else
        @s.location = new_loc
        if (@s.save)
          flash[:notice] = "Session moved"
          redirect_to :action=>'assigned'
        else
          render :action=>'assign', :layout=>'popup-layout'
        end
      end
    else
      @all = session[:all_locs]
      render :action=>'assign', :layout=>'popup-layout'
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:notice] = "Error in saving: #{e.message}"
    render :action=>'assign', :layout=>'popup-layout'
  end

  def assigned
    render :layout=>'popup-layout'
  end

  def new
    @location = Location.new(params[:location])
    if request.post?
      if @location.save
        flash[:notice] = 'Location ' + @location.name + ' was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = 'Location was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Location.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
