class ChooseController < ApplicationController
  layout "choose-layout"

  # Choose from index of classrooms
  def index
    @classrooms = Classroom.list_real
  end

  # Choose from list of students
  def list
    @people = Person.find(:all, :order=>'name', :conditions=>['classroom_id=? and (select count(1) from requests where person_id=people.id)<?', params[:id], Person.default_max_choices])
  end

  def edit
    @person = Person.find(params[:id])
    @requested_projects = @person.requests.map{|x| x.project}
    if (@person.unit?)
      # Unit students get to see complete list of projects and choose role
      @projects = Project.list_real
    else
      @projects = Project.list_for_grade(@person.grade)
    end
  end

  def savenote
    person = Person.find(params[:id])
    person.update_attribute('notes', params[:notes])
    redirect_to :action=>'list', :id=>person.classroom
  end

  def addchoice
    person = Person.find(params[:id])
    project = Project.find(params[:project])
    flash[:notice] = "Added #{project.name}."
    # Only add if project isn't already in list of requests:
    if (person.requests.select { |x| x.project == project }.empty?)
      req = Request.new
      req.project = project
      req.person = person
      req.role = params[:role]
      req.rank = person.requests.length+1
      person.requests << req
      if (person.max_choices > req.rank)
        flash[:notice] += " Please choose #{person.max_choices-req.rank} more."
      end
    end
    redirect_to :action=>'edit', :id=>person.id
  end

  def removechoice
    person = Person.find(params[:id])
    request = Request.find(params[:request])
    ind = person.requests.index(request)
    flash[:notice] = "Removed #{request.project.name}"
    reqs = person.requests
    reqs.delete(request)
    for i in (ind...reqs.length)
      reqs[i].rank -= 1
      reqs[i].save!
    end
    redirect_to :action=>'edit', :id=>person
  end

  def reorder
    r = Request.find(params[:id])
    person = r.person
    requests = person.requests

    newindex = params[:req][:rank].to_i - 1  # arrays index from 0
    oldindex = requests.index(r)

    if (newindex != oldindex)
      flash[:notice] = "Moved #{r.project.name} to new position"
      if (newindex>=requests.length)
        requests.delete_at(oldindex) # del from old position
        requests.push(r) # add at end
      else
        insert_before = requests[newindex]
        requests.delete_at(oldindex) # del from old position
        newindex_after_deletion = requests.index(insert_before)
        requests[newindex_after_deletion,0] = r  # insert @ new
      end

      # now reset all ranks based on list position
      person.requests.each_index do |i|
        person.requests[i].rank = i+1
        person.requests[i].save!
      end
    else
      flash[:notice] = "Move requested to same position as before"
    end
    redirect_to :action=>'edit', :id=>person
  end

end

