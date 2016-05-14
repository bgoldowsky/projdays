class StaffController < ApplicationController
  layout "staff-layout"

  before_filter :authorize_adult
  before_filter {|c|
    c.tab = 'Projects'
    c.can_edit = staff_edit_projects()
    c.can_edit_people = staff_edit_people()
    c.can_review = staff_review_projects()
    c.can_see_sched = staff_view_schedule()
    true
  }

  attr_accessor :tab, :can_edit, :can_edit_people, :can_review, :can_see_sched

  def index
    if (can_review)
      redirect_to :action => 'reviews'
    elsif (can_see_sched)
      redirect_to :action => 'schedule'
    elsif (can_edit)
      redirect_to :action => 'projects'
    else
      redirect_to :action => 'projects'
    end
  end

  def faq
    @tab = 'FAQ'
  end

  def projects
    @projects = Project.list_real_by_name
    user = Person.find(session[:user_id])
    @assignments = user.assignments
  end

  def history
    @oldprojects = Project.list_recommended
  end

  def add_me
    check_editing && return
    project=Project.find(params[:id])
    if project
      user = Person.find(session[:user_id])
      existing = Request.find(:first, :conditions=>['project_id=? and person_id=?',
                                                    project.id, user.id])
      if (not existing)
        req = Request.new
        req.project = project
        req.person = user
        req.rank = 2
        req.role = 'L'
        req.save!
      else
        flash[:notice] = 'You are already listed as a leader or owner of that project'
      end
    end
    redirect_to :action=>'projects'
  end

  # Set up new project, empty timeslot list & Request for leader.
  def new
    check_editing && return
    @project = Project.new
    @project.maxgrade = 8
    @project.notes = Project.default_note
    @ownreq = Request.new     # owner
    @ownreq.person = Person.find(session[:user_id])
    @req = Request.new        # co-owner
    # submission of this form goes to "create" action below
  end

  def create
    check_editing && return
    @project = Project.new(params[:project])
    @project.shortname = @project.name if (@project.shortname == nil)

    @sess = Sess.new
    @sess.project = @project
    @sess.timeslots = Timeslot.list

    @ownreq = Request.new
    @ownreq.person = Person.find(session[:user_id])
    @ownreq.project = @project
    @ownreq.rank = 1
    @ownreq.role = 'L'

    @req = Request.new(params[:req])
    @req.project = @project
    @req.rank = 1
    @req.role = 'L'

    # save all in a db transaction
    Project.transaction do
      @project.save!
      @sess.save!
      @ownreq.save!
      if @req.valid?
        @req.save!
      end
      flash[:notice] = 'New project created'
      redirect_to :action=>'projects'
    end
    rescue ActiveRecord::RecordInvalid => e
    flash[:notice] = "Error in saving: #{e.message}"
    @timeslots = Timeslot.find(:all)
    render :action => 'new'
  end

  # Set this project to be offered this year, then edit.
  def repeat
    check_editing && return
    @project = Project.find(params[:id])
    # Set up current user as leader
    @ownreq = Request.new
    @ownreq.project = @project
    @ownreq.person = Person.find(session[:user_id])
    @ownreq.rank = 1
    @ownreq.role = 'L'
    # Co-owner
    @req = Request.new(params[:req])
    @req.project = @project
    @req.rank = 1
    @req.role = 'L'
    if request.post?
      # Set up default sessions
      @sess = Sess.new
      @sess.project = @project
      @sess.timeslots = Timeslot.list
      # save all in a db transaction
      Project.transaction do
        @project.update_attributes!(params[:project])
        @project.update_attributes!('thisyear'=>true)
        @sess.save!
        @ownreq.save!
        if @req.valid?
          @req.save!
        end
        flash[:notice] = 'Project successfully updated'
        redirect_to :action=>'projects'
        return
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:notice] = "Error in saving: #{e.message}"
    render
  end

  # Set up screen for editing an existing project
  def edit
    check_editing && return
    @project = Project.find(params[:id])
    if request.post?
      @project.shortname = @project.name if (@project.shortname == nil)
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project successfully updated'
        redirect_to :action => 'projects'
      else
        flash[:notice] = 'Failed to update project'
        render
      end
    else
      # request was a GET
      render
    end
  end

  def show_proj
    @project = Project.find(params[:id], :include=>['sesses'])
    @project.sesses.sort! {|a, b| a.timeslots.first.id <=> b.timeslots.first.id}
  end

  def schedule
    if (!can_see_sched)
      redirect_to :action=>'available'
    end
    @tab = 'My Schedule'
    @person = Person.find(session[:user_id], :include=>'assignments')
    @timeslots = Timeslot.list
  end    

  def printable
    @grade = params[:id].to_i
    if (@grade >= 0)
      @projects = Project.list_for_grade(@grade)
    else
      @projects = Project.list_by_grade(true, true)
    end
    render :layout=>'popup-layout'
  end

  def available
    @tab = 'My Schedule'
    @user = Person.find(session[:user_id], :include=>'assignments')
    @unavail_sesses = unavailable_proj().sesses
    if (request.post?)
      @user.notes = params[:notes]
      @user.save!
      avail = Timeslot.find(params[:time_ids])
      for ses in @unavail_sesses
        if (@user.is_assigned?(ses))
          if (avail.include? ses.timeslots.first)
            # no longer unavailable
            @user.is_assigned?(ses).destroy
          end
        else
          if (!avail.include? ses.timeslots.first)
            # newly unavailable
            a = Assignment.new
            a.person = @user
            a.role = 'P'
            a.sess = ses
            a.save!
          end
        end
      end
      if (can_see_sched)
        redirect_to :action=>'schedule'
      else
        redirect_to :action=>'thanks'
      end
    end
  end

  def thanks
    @tab = 'My Schedule'
  end

  def reviews
    @tab = 'Reviews'
    @person = Person.find(session[:user_id], :include=>'assignments')
    @projects = @person.assignments.map {|a| a.sess.project}.uniq
    @notes = Note.previous_years
    @thisyear = Date.today.year
  end

  def edit_review
    @tab = 'Reviews'
    @project = Project.find(params[:id])
    if request.post?
      @project.update_attributes(params[:project])
      if @project.save
        redirect_to :action=>'reviews'
      end
    end
  end

  def view_notes
    @tab = 'Reviews'
    @note = Note.find(params[:id])
  end

  def edit_notes
    @tab = 'Reviews'
    @note = Note.for_this_year
    if request.post?
      @note.update_attributes(params[:note])
      if @note.save
        redirect_to :action=>'reviews'
      end
    end
  end

  def classroom
    @tab='Class Lists'
    @classroom = Classroom.find(params[:id])
    @classrooms = Classroom.list
    @timeslots = Timeslot.find(:all)
  end

  def create_class
    check_editing_person && return
    @tab = 'Class Lists'
    @classroom = Classroom.find(params[:id])
    @max = 30
    @people = []
    (1..@max).each do |i|
      p = Person.new
      p.classroom = @classroom
      @people.push p
    end
    if request.post?
      errors = false
      flash[:notice] = ""
      @people.each_with_index do |p, i|
        istr = i.to_s
        if params[:p][i]
          if !params[:p][i][:name].empty?
            p.attributes = params[:p][i]
            if !p.valid?
              errors = true
              p.errors.each_full {
                |msg| flash[:notice] = (flash[:notice] || "") + "<br/>" + p.name + ": " + msg }
            end
          end
        end
      end
      if errors
        flash[:notice] = 'Errors detected: ' + flash[:notice]
      else
        Classroom.transaction do
          @people.each do |p|
            p.save
          end
        end
        flash[:notice] = 'Class list entered'
        redirect_to :action=>'classroom', :id=>@classroom
      end
    end
  end

  def edit_person
    @tab = 'Class Lists'
    @person = Person.find(params[:id])
    if request.post?
      if @person.update_attributes(params[:person])
        flash[:notice] = 'Person was successfully updated.'
        redirect_to :action => 'classroom', :id => @person.classroom
      end
    end
  end

  private

  def check_editing
    if !ApplicationController.staff_edit_projects
      flash[:notice] = 'Editing currently turned off'
      redirect_to :action=>'projects'
      true
    end
  end

  def check_editing_person
    if !ApplicationController.staff_edit_people
      flash[:notice] = 'Editing currently turned off'
      redirect_to :action=>'projects'
      true
    end
  end

end
