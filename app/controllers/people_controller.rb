class PeopleController < ApplicationController
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
         :redirect_to => { :action => :index }

# Not currently using this
#  def list
#    @person_pages, @people = paginate :people, :per_page => 30, :order => 'name';
#  end

  def show
    @person = Person.find(params[:id], :include=>'catprefs')
    @timeslots = Timeslot.list
  end

  def new
    @person = Person.new(params[:person])
    @classrooms = Classroom.list
    if request.post?
      if @person.save
        flash[:notice] = 'Person was successfully created.'
        redirect_to :controller=>'classrooms', :action => 'show', :id=>@person.classroom
      end
    else
      if (params[:id])
        @person.classroom = Classroom.find(params[:id])
        @person.grade = @person.classroom.mingrade
      end
      if @person.adult?
        @person.password = 'pdstaff'
      end
    end
  end

  def available
    @user = Person.find(params[:id], :include=>'assignments')
    @unavail_sesses = unavailable_proj().sesses
    if (request.post?)
      avail = (params[:time_ids] ? Timeslot.find(params[:time_ids]) : [])
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
      redirect_to :action=> 'show', :id => @user
    end
  end

  ## Table format in which all a person's requests can be shown and set
  def edit_requests
    @person = Person.find(params[:id])
    @requests = @person.requests
    @maxrank = @person.max_choices
    @grade = @person.grade
    @projects = Project.list_for_grade(@grade)

    if request.post?
      params[:req].each do |key, value|
        req = @requests.detect {|r| r.project_id==key.to_i}
logger.info req.inspect
        newrank = value.min.to_i
        if (req)
          if (req.rank != newrank)
            logger.info "Rank for #{key} was #{req.rank}, now #{newrank}"
            req.rank = newrank
            req.save!
          end
        else
          logger.info "New request: #{key}, #{newrank}"
          req = Request.new
          req.person = @person
          req.project = Project.find(key.to_i)
          req.rank = newrank
          req.role = 'P'
          req.save!
        end
      end
      redirect_to :controller=>'people', :action=>'show', :id=>@person
    end

  end

  def edit
    @person = Person.find(params[:id])
    @classrooms = Classroom.list
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      flash[:notice] = 'Person was successfully updated.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end

  def destroy
    pers = Person.find(params[:id])
    flash[:notice] = "#{pers.name} deleted"
    c = pers.classroom
    pers.destroy
    redirect_to :controller=>'classrooms', :action => 'show', :id=>c
  end

  def delete_request
    req = Request.find(params[:id])
    p = req.person
    req.destroy
    redirect_to :action=>'show', :id=>p
  end

end
