class WelcomeController < ApplicationController
  layout "choose-layout"

  before_filter {|c|
    c.project_list_public = public_view_projects()
    c.can_edit = staff_edit_projects()
    true
  }

  attr_accessor :project_list_public, :can_edit

  # The splash page - choose how to log in.
  def index
  end

  def logout
    session[:user_id] = nil
    session[:admin] = nil
    redirect_to :action=>'index'
  end

  # create a parental account
  def new_account
    @person = Person.new(params[:person])
    if request.post?
      @person.grade = Person.parent_grade
      @person.classroom = Classroom.parent_classroom
      if @person.save 
        flash[:notice] = 'Account created; now you can log in'
        redirect_to :action=>'parent_login'
      else
        render
      end
    end
  end

  # staff
  def staff_login
    session[:user_id] = nil
    @users = Person.find_teachers
    if params and params[:user]
      person_id = params[:user][:id]
    end
    if person_id and person_id != ''
      @user = Person.find_by_id(person_id)
    end
    if request.post?
      if @user
        auth_user = Person.authenticate(@user, params[:password])
        if auth_user
          session[:user_id] = auth_user.id
          redirect_to(:controller=>'staff', :action=>'index')
        else
          flash[:notice] = 'Invalid password'
        end
      else
        flash[:notice] = 'Please select your name'
      end
    end
  end

  # staff
  def parent_login
    session[:user_id] = nil
    @users = Person.find_parents
    if params and params[:user]
      person_id = params[:user][:id]
    end
    if person_id and person_id != ''
      @user = Person.find_by_id(person_id)
    end
    if request.post?
      if @user
        auth_user = Person.authenticate(@user, params[:password])
        if auth_user
          session[:user_id] = auth_user.id
          redirect_to(:controller=>'staff', :action=>'index')
        else
          flash[:notice] = 'Invalid password'
        end
      else
        flash[:notice] = 'Please select your name'
      end
    end
  end

  def unit_login
    session[:user_id] = nil
    @users = Person.find(:all, :conditions=>['grade=7 or grade=8'], :order=>'name')
    if params and params[:user]
      person_id = params[:user][:id]
    end
    if person_id and person_id != ''
      @user = Person.find_by_id(person_id)
    end
    if request.post?
      if @user
        auth_user = Person.authenticate(@user, params[:password])
        if auth_user
          session[:user_id] = auth_user.id
          redirect_to(:controller=>'unit', :action=>'index')
          return
        else
          flash[:notice] = 'Invalid password'
        end
      else
        flash[:notice] = 'Please select your name'
      end
    end
    render :action=>'staff_login'
  end

  def admin_login
    session[:user_id] = nil
    session[:admin] = nil
    if request.post?
      if params[:password] == get_admin_password
        session[:admin] = true
        redirect_to(:controller=>'projects', :action=>'fullness')
      else
        flash[:notice] = 'Password incorrect'
      end
    end
  end

private

  def get_admin_password
    'pd1456'
  end

end
