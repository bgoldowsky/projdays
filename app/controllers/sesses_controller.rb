class SessesController < ApplicationController
  layout "main-layout"

  before_filter :authorize_admin
  before_filter {|c| c.tab = 'Projects' }

  attr_accessor :tab

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @sess = Sess.find(:all)
  end

  def show
    @sess = Sess.find(params[:id])
    @timeslots = Timeslot.list
  end

  # Doesn't work?:
  def validate
     if timeslots.blank?
        errors.add_to_base("You must choose a timeslot for this session")
     end
  end

  def new
    @sess = Sess.new
    @sess.project = Project.find(params[:id])
    @timeslots = Timeslot.list
  end

  def create
    @sess = Sess.new(params[:sess])
    @sess.timeslots = Timeslot.find(@params[:time_ids]) if @params[:time_ids]

    if @sess.save
      flash[:notice] = 'Session was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @sess = Sess.find(params[:id])
    @timeslots = Timeslot.list
  end

  def update
    @sess = Sess.find(params[:id])
    @sess.timeslots = Timeslot.find(params[:time_ids]) if params[:time_ids]
    if @sess.update_attributes(params[:sess])
      flash[:notice] = 'Sess was successfully updated.'
      redirect_to :controller=>'projects', :action => 'show', :id => @sess.project
    else
      render :action => 'edit'
    end
  end

  def destroy
    Sess.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  # Scheduling popup window - show possible sessions for person @ time
  def assign
    if (params[:person])
      @person = Person.find(params[:person])
    elsif (params[:assg][:person_id])
      @person = Person.find(params[:assg][:person_id])
    end

    if (params[:id])
      # When first called to edit existing assignment:
      @assg = Assignment.find(params[:id])
    elsif (params[:assg] && params[:assg][:id] != '')
      # When new info is posted:
      @assg = Assignment.find(params[:assg][:id])
    else
      # When called to create new assignment:
      @assg = Assignment.new
      @assg.person = @person
      @assg.role = @person.adult? ? 'L' : 'P'
    end

    if request.post?
      if @assg.update_attributes(params[:assg])
        render :action=>'assigned', :layout=>'popup-layout'
      end
    else
      @timeslot = Timeslot.find(params[:timeslot], :include=>[{:sesses => :project}])
      @sesses = @timeslot.sesses
      # Sort by display name
      @sesses.sort! {|a,b|  a.project.display_name.downcase <=> b.project.display_name.downcase }
      # Override alphabetical sort by moving requested projects to the top of the list.
      # Start with the lowest-ranked, so highest-ranked ends up at the top
      i = @person.requests.length-1
      while (i >= 0)
        proj = @person.requests[i].project
        index = @sesses.find_index {|s| s.project == proj}
        if (index)
          @sesses.unshift(@sesses.delete_at(index))
        end
        i -= 1
      end
      render :action=>'assign', :layout=>'popup-layout'
    end
  end

  def destroy_assignment
    Assignment.find(params[:id]).destroy
    flash[:notice] = 'Assignment deleted'
    render :action=>'assigned', :layout=>'popup-layout'
  end

end
