class ClassroomsController < ApplicationController
  layout "main-layout"

  before_filter :authorize_admin
  before_filter {|c| c.tab = 'People/Groups' }

  attr_accessor :tab

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @main_title = "Classrooms"
    @classrooms = Classroom.find(:all, :order => 'mingrade, name')
  end

  def show
    @classroom = Classroom.find(params[:id], :include => [{:people => {:assignments => {:sess => [:project, :timeslots]}}}])
    @classrooms = Classroom.list
    @timeslots = Timeslot.find(:all)
  end

  def show_printable
    @classroom = Classroom.find(params[:id])
    @timeslots = Timeslot.find(:all)
    render :layout => 'popup-layout'

  end

  def show_requests
    @classroom = Classroom.find(params[:id])
    @classrooms = Classroom.list
    @timeslots = Timeslot.find(:all)
    @maxrank = @classroom.max_choices
    if @classroom.adult?
      @showprefs = true
    else
      @showprefs = false
    end
  end

  def new
    @classroom = Classroom.new
  end

  def create
    @classroom = Classroom.new(params[:classroom])
    if @classroom.save
      flash[:notice] = 'Classroom was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @classroom = Classroom.find(params[:id])
  end

  def update
    @classroom = Classroom.find(params[:id])
    if @classroom.update_attributes(params[:classroom])
      flash[:notice] = 'Classroom was successfully updated.'
      redirect_to :action => 'show', :id => @classroom
    else
      render :action => 'edit'
    end
  end

  def destroy
    Classroom.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

end
