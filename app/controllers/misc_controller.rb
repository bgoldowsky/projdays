class MiscController < ApplicationController
  layout "main-layout"

  before_filter :authorize_admin
  before_filter {|c| c.tab = 'Etc' }
  attr_accessor :tab

  def list
  end

  def notes
    @classrooms = Classroom.list
    @people = Person.find(:all, :order=>'name', :conditions=>["notes != ''"])
  end

  def leader_schedules
    if request.post?
      @people = Person.find(params[:person_ids], :include=>'assignments')
      @timeslots = Timeslot.list
      render :layout=>'popup-layout'
    else
      all = Person.find(:all, :order=>'grade DESC, name', :include=>'assignments')
      # Ignore people who are never leaders
      @people = all.reject {|p| ! p.assignments.detect {|a| a.role=='L'}}
      render :action=>'leader_list', :layout=>'main-layout'
    end
  end

  def owners
    @people = Person.find(:all, :conditions=>['grade>=7'], :order=>'grade desc, name', :include=>[:classroom, :requests])
  end

  def real_fakes
    @fake_projects = Project.list_fake
    @old_projects = Project.list_old(true)
  end

  def project_schedulenotes
    @projects = Project.find(:all, :order=>'shortname', :conditions=>["schedulenotes != '' AND thisyear=true"])
  end

  def session_summaries
    @sessions = Sess.find(:all, :include=>[:project, :assignments]).sort {|a,b|
      a.project.name <=> b.project.name }
    @timeslots = Timeslot.list
  end

  def session_schedules
    @sessions = Sess.find(:all, :include=>[:project, :assignments]).sort {|a,b|
      a.project.name <=> b.project.name }
    @timeslots = Timeslot.list
  end

  def same_thing_twice
    @dups = []
    for person in Person.find_students
      alist = person.assignments
      ## Look for duplicates
      0.upto(alist.length-2) {|i| # -2 since no need to check last item
        (i+1).upto(alist.length-1) { |j|
          if alist[i].sess.project.real and alist[i].sess.project == alist[j].sess.project
            @dups << [ alist[i], alist[j] ]
          end
        }
      }
    end
  end

  def conflicts
    @confs = []
    for person in Person.list
      alist = person.assignments
      0.upto(alist.length-2) {|i| # -2 since no need to check last item
        (i+1).upto(alist.length-1) { |j|
          if !((alist[i].sess.timeslots & alist[j].sess.timeslots).empty?)
            @confs << [ alist[i], alist[j] ]
          end
        }
      }
    end
  end

  def poster
    @timeslots = Timeslot.find(:all,  :include=>['sesses']);
    render :layout=>'popup-layout'
  end

  def general_notes
    @note = Note.for_this_year
    if request.post?
      @note.update_attributes(params[:note])
      if @note.save
        redirect_to :action=>'list'
      end
    end
  end
    

  def settings
    if request.post?
      Configuration.set("public_view_projects", params[:public_view_projects])
      Configuration.set("staff_edit_people", params[:staff_edit_people])
      Configuration.set("staff_edit_projects", params[:staff_edit_projects])
      Configuration.set("adult_signup", params[:adult_signup])
      Configuration.set("staff_view_schedule", params[:staff_view_schedule])
      Configuration.set("staff_review_projects", params[:staff_review_projects])
      redirect_to :action=>'list'
    end

    @public_view_projects = ApplicationController.public_view_projects()
    @staff_edit_people = ApplicationController.staff_edit_people()
    @staff_edit_projects = ApplicationController.staff_edit_projects()
    @adult_signup = ApplicationController.adult_signup()
    @staff_view_schedule = ApplicationController.staff_view_schedule()
    @staff_review_projects = ApplicationController.staff_review_projects()
  end

  def annual
  end

  def clear_db
    last_year = Date.today.year-1
    Project.transaction do 
      # History records
      Assignment.find(:all).each do |a|
        h = History.create_from(a, last_year)
      end

      # Expire projects, reset shortname to limit conflicts next year
      unavail = unavailable_proj()
      Project.find(:all).each do |p|
        if (p != unavail)
          p.update_attributes(:thisyear => false, :shortname => p.name)
        end
      end

      # Clear tables
      Assignment.delete_all()
      Request.delete_all()

      # Clear all sessions except "unavailable"
      unavailable = unavailable_proj()
      Sess.find(:all).each do |s|
        if (s.project != unavailable)
          s.destroy
        end
      end

      # Update people
      Person.find(:all).each do |p|
        p.notes = nil
        if (p.student?)
          p.destroy
          # p.grade = p.grade + 1
          # if (!(p.classroom.grades.include? p.grade))
          #   p.destroy
          # end
          # p.save
        end
        if (p.parent?)
          p.destroy
        end
        if (p.teacher?)
          p.update_attributes(:notes=>'')
        end
      end

      flash[:notice] = "Cleared database"
    end
    redirect_to :action=>'list'
  end

end
