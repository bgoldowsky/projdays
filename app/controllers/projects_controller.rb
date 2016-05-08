class ProjectsController < ApplicationController
  layout "main-layout"

  before_filter :authorize_admin
  before_filter {|c|
    c.tab = 'Projects'
  }

  attr_accessor :tab

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  ## Not currently used - main screen is "fullness"
  def index
    list
    render :action => 'list'
  end

  def list
    @projects = Project.list_by_shortname(true, true, [:requests, :sesses])
    @oldprojects = Project.list_old_by_year
    @fakeprojects = Project.list_fake
  end

  def historylist
    @oldprojects = Project.list_old
  end

  def toggle_recommended
    @project = Project.find(params[:id])
    @project.recommended = ! @project.recommended;
    @project.save!
    render :partial=>'historylist_row'
  end

  def revive
    @project = Project.find(params[:id])
    # Set up default sessions
    @sess = Sess.new
    @sess.project = @project
    @sess.timeslots = Timeslot.list
    Project.transaction do
      @project.update_attributes!('thisyear'=>true)
      @sess.save!
      flash[:notice] = 'Project successfully updated'
    end
    redirect_to :action=>'list'
  end

  def fullness
    @projects = Project.list_by_shortname(false, true, [{:sesses => {:assignments => :person}}, :requesters])
    @students = Person.find_students
    @timeslots = Timeslot.list
    @col_tot = Array.new
    @col_cap = Array.new
    @col_count = Array.new
    for t in @timeslots
      @col_tot[t.id] = 0
      @col_cap[t.id] = 0
      @col_count[t.id] = 0
    end
  end

  def unscheduled
    @t = Timeslot.find(params[:id])
    @people = Person.find_students.reject{|p| p.has_assignment_for(@t)}
    @maxrank = Person.unit_max_choices
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

  def by_grade
    @projects = Project.list_real
  end

  ## Not currently used
  def list_by_grade
    @grades = Person.studentgrades
    @proj = {}
    @grades.each {|g| @proj[g]=Project.list_for_grade(g)}
  end

  def show
    @project = Project.find(params[:id], :include=>['sesses'])
    @project.sesses
    @sesslist = @project.sesses_sorted
  end

  ## This screen is no longer used
  def show_requests
    @project = Project.find(params[:id], :include=>['sesses'])
    @project.sesses.sort! {|a, b| a.timeslots.first.id <=> b.timeslots.first.id}
  end

  def history
    @project = Project.find(params[:id])
    @histories = History.of_project_id(params[:id])
    @years = @histories.map{|h|h.year}.sort{|a,b|b<=>a}.uniq
  end

  def schedule
    @timeslots = Timeslot.list
    @project = Project.find(params[:id], :include=>[{:requests => {:person => :assignments}}, :sesses])
    @project.sesses.sort! {|a, b| a.timeslots.first.id <=> b.timeslots.first.id}
  end

  def sched_refresh
    @trid = params[:trid]
    @r = Request.find(params[:req])
    @project = @r.project
    @timeslots = Timeslot.list
    @project.sesses.sort! {|a, b| a.timeslots.first.id <=> b.timeslots.first.id}
    render :partial=>'schedule_row'
  end

  def sched_unassign
    @trid = params[:trid]
    assg = Assignment.find(params[:id])
    assg.destroy
    @timeslots = Timeslot.list
    @project = Project.find(params[:proj])
    @project.sesses.sort! {|a, b| a.timeslots.first.id <=> b.timeslots.first.id}
    @r = Request.find(:first, :conditions=>['person_id=? and project_id=?', assg.person.id, @project.id])
    render :partial=>'schedule_row'
  end

  def sched_assign
    @trid = params[:trid]
    @r = Request.find(params[:req])
    @timeslots = Timeslot.list
    @sess = Sess.find(params[:sess])
    @project = @sess.project
    @project.sesses.sort! {|a, b| a.timeslots.first.id <=> b.timeslots.first.id}
    # If an assignment ID is listed, it is to be removed and replaced.
    if (params[:id])
      assg = Assignment.find(params[:id])
      assg.destroy
    end

    assg = Assignment.new
    assg.person = @r.person
    assg.role = @r.role
    assg.sess = @sess
    assg.save!
    render :partial=>'schedule_row'
  end    

  def new
    @project = Project.new(params[:project])
    if request.post?
      if (!@project.shortname or @project.shortname == '')
        @project.shortname = @project.name
      end
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    else
      @project.mingrade = 0
      @project.maxgrade = 8
    end
  end

  def edit
    @project = Project.find(params[:id])
    if request.post?
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        redirect_to :action => 'show', :id => @project
      else
        render :action => 'edit'
      end
    end
  end

  def merge
    @project = Project.find(params[:id])
    if request.post?
      other = Project.find(params[:merge][:project])
      if (other == nil)
        flash[:notice] = "Can't find that project"
      elsif (other == @project)
        flash[:notice] = "Cannot merge project with itself"
      else
        Project.transaction do
          for r in @project.requests
            new = r.clone
            new.project = other
            new.save!
          end
        end
        flash[:notice] = "Merged #{@project.requests.size} requests"
      end
    end
  end

  def historymerge
    @project = Project.find(params[:id])
    if request.post?
      other = Project.find(params[:merge][:project])
      if (other == nil)
        flash[:notice] = "Can't find that project"
      elsif (other == @project)
        flash[:notice] = "Cannot history-merge project with itself"
      elsif @project.sesses.size>0 or other.sesses.size>0
        flash[:notice] = "Cannot history-merge a project with sessions"
      elsif @project.requests.size>0 or other.requests.size>0
        flash[:notice] = "Cannot history-merge a project with requests"
      else
        Project.transaction do
          # Merge name, description, etc.
          other.name = other.name + " / " + @project.name;
          other.description = other.description + "\n\n" + @project.description;
          other.notes = other.notes + "\n\n" + @project.notes
          other.schedulenotes = other.schedulenotes + "\n\n" + @project.schedulenotes
          other.review = other.review + "\n\n" + @project.review
          other.save!
          # Merge histories
          for h in @project.histories
            h.project = other
            h.save!
          end
        end
        @project.destroy
        flash[:notice] = "Merged projects and histories"
        # Drop off on edit page
        redirect_to :action=>'edit', :id=>other
      end
    end
  end

  def destroy
    proj = Project.find(params[:id])
    if (proj.sesses.size>0)
      flash[:notice] = 'You have to delete existing sessions before deleting this project.'
      redirect_to :action => 'show', :id=>proj
    else
      Sess.delete_all(['project_id = ?' , params[:id]])
      Request.delete_all(['project_id = ?', params[:id]])
      History.delete_all(['project_id = ?', params[:id]])
      proj.destroy
      redirect_to :action => 'historylist'
    end
  end

  def new_sess
    @sess = Sess.new
    @sess.project = Project.find(params[:id])
    @timeslots = Timeslot.list
    if request.post?
      if params[:time_ids]
        @sess = Sess.new(params[:sess])
        @sess.timeslots = Timeslot.find(params[:time_ids]) 
        if @sess.save
          flash[:notice] = 'Session was successfully created.'
          redirect_to :action => 'show', :id => @sess.project
          return
        end
      else
        flash[:notice] = 'Choose a timeslot for the new session'
      end
    end
    render :action => 'new_sess'
  end

  def confirm_sess
    s = Sess.find(params[:id])
    s.confirmed = true
    s.save
    redirect_to :action=> 'show', :id => s.project
  end

  def unconfirm_sess
    s = Sess.find(params[:id])
    s.confirmed = false
    s.save
    redirect_to :action=> 'show', :id => s.project
  end


  ## Split up an N-timeslot sess into N individual sesses
  def split_sess
    @orig = Sess.find(params[:id])
    for t in @orig.timeslots[1..-1]  # all elements but first
      s = Sess.new
      s.project = @orig.project
      s.location = @orig.location
      s.timeslots = [t];
      s.save!
    end
    @orig.timeslots = [ @orig.timeslots.first ]
    @orig.save!
    redirect_to :action => 'show', :id => @orig.project
  end

  def destroy_sess
    s = Sess.find(params[:id])
    proj = s.project
    Project.transaction do
      s.assignments.each { |a| a.destroy }
      s.destroy
    end
    flash[:notice] = "Session deleted"
    redirect_to :action => 'show', :id => proj
  end

  def assign_requester
    req = Request.find(params[:id], :include=>['project', 'person'])
    sess = Sess.find(params[:sess])
    role = params[:role]
    assg = Assignment.get(req.person, sess, role)
    assg.save!
    redirect_to :action => 'show_requests', :id => req.project, :anchor=>'sessions'
  end

  def assign_requester_all
    req = Request.find(params[:id], :include=>['project', 'person'])
    for s in req.project.sesses
      assg = Assignment.get(req.person, s, req.role)
      assg.save!
    end
    redirect_to :action => 'show_requests', :id => req.project, :anchor=>'sessions'
  end

  def unassign_requester_all
    req = Request.find(params[:id], :include=>['project', 'person'])
    for assg in req.person.assignments
      if (assg.sess.project == req.project)
        assg.destroy
      end
    end
    redirect_to :action => 'show_requests', :id => req.project, :anchor=>'sessions'
  end

  def unassign
    a = Assignment.find(params[:id])
    a.destroy
    proj = a.sess.project
    redirect_to :action => 'show_requests', :id => proj, :anchor=>'sessions'
  end

end
