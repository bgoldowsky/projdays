class RequestsController < ApplicationController
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
    @request_pages, @requests = paginate :requests, :per_page => 10
  end

  def show
    @request = Request.find(params[:id])
  end

  def new
    @req = Request.new(params[:req])
    if (!@req.person)
      @req.person = Person.find(params[:id])
    end
    if request.post?
      if @req.save
        flash[:notice] = 'Request was successfully created.'
        redirect_to :controller=>'people', :action => 'show', :id=>@req.person
      else
        render :action => 'new'
      end
    end
  end

  ## This goes with show_requests screen, which is deprecated
  def new_for_proj
    @tab = 'Projects'
    @req = Request.new(params[:req])
    ## Placeholders for "person" pulldown menus
    @teacher = Person.new
    @parent = Person.new
    @unit = Person.new
    if params[:id]
      @req.project = Project.find(params[:id])
    end
    if request.post?
      pers_id = params[:teacher][:id]!='' ? params[:teacher][:id] : (params[:parent][:id]!='' ? params[:parent][:id] : (params[:unit][:id]!='' ? params[:unit][:id] : nil))
      if pers_id
        @req.person = Person.find(pers_id)
      end
      if @req.save
        flash[:notice] = 'Request was successfully created.'
        redirect_to :controller=>'projects', :action => 'show_requests', :id=>@req.project
      else
        render :action => 'new_for_proj'
      end
    end
  end

  def edit
    @req = Request.find(params[:id])
    if request.post?
      if @req.update_attributes(params[:req])
        flash[:notice] = 'Request was successfully updated.'
        redirect_to :controller=>'people', :action=>'show', :id=>@req.person
      else
        render :action => 'edit'
      end
    end
  end

  ## This goes with edit_requests screen, which is deprecated
  def edit_for_proj
    @tab = 'Projects'
    @req = Request.find(params[:id], :include=>[:person, :project])
    @person_selection = Person.find(:all, :conditions=>['grade=?', @req.person.grade], :order=>:name).collect {|p| [p.name, p.id]}
    if request.post?
      if @req.update_attributes(params[:req])
        flash[:notice] = 'Request was successfully updated.'
        redirect_to :controller=>'projects', :action=>'show_requests', :id=>@req.project
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    Request.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
