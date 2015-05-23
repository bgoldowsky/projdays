class UnitController < ApplicationController
  layout "staff-layout"

  before_filter :authorize_unit
  before_filter {|c|
    c.tab = 'Projects'
  }

  attr_accessor :tab

  def index
    redirect_to :action => 'projects'
  end

  def projects
    @user = current_user
    if (@user.email==nil or @user.email=="")
      redirect_to :action => 'edit_email'
    end
    @projects = @user.requests.find(:all, 'rank=1').map{|r| r.project}
  end

  def faq
    @tab = 'FAQ'
  end

  def edit_email
    @user = current_user
    if request.post?
      @user.update_attributes(params[:user])
      flash[:notice] = 'Email address set.'
      redirect_to :action => 'index'
    end
  end

  def new
    check_editing && return
    @project = Project.new
    @project.maxgrade = 8
    @project.notes = Project.default_unit_note
    # form submits to "create" action below
  end

  # Set up new project, empty timeslot list & Request for leader.
  def create
    check_editing && return
    @project = Project.new(params[:project])
    @project.isreal = false
    @project.shortname = @project.name if (@project.shortname == nil)
    @req = Request.new(:person => current_user,
                       :project => @project,
                       :role => 'L',
                       :rank => 1)
    Project.transaction do
      @project.save!
      @req.save!
      flash[:notice] = 'New project created'
      redirect_to :action=>'index'
    end
    rescue ActiveRecord::RecordInvalid => e
    render :action => 'new'
  end

  def edit
    check_editing && return
    @project = Project.find(params[:id])
    if request.post?
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        redirect_to :action => 'index'
        return
      end
    end
    render
  end
  
  private

  def check_editing
    if !ApplicationController.unit_edit_projects
      flash[:notice] = 'Editing currently turned off'
      redirect_to :action=>'index'
      true
    end
  end

end
