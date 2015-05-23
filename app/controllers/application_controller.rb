# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '4d2e5d51c1b3d64e070a750d5983b340'

  private

  def current_user
    Person.find(session[:user_id])
  end

  def unavailable_proj
    Project.find_by_shortname("xxx")
  end

  ### CONFIGURATION VALUES

  # Does front page allow for everyone to view projects?
  def self.public_view_projects
    Configuration.get_cached("public_view_projects", "true") == "true"
  end

  # Can people be edited (by staff)?  Usually true at beginning
  def self.staff_edit_people
    Configuration.get_cached("staff_edit_people", "true") == "true"
  end

  # Can projects be edited by staff?  Usually true at beginning
  def self.staff_edit_projects
    Configuration.get_cached("staff_edit_projects", "true") == "true"
  end

  # Can staff and volunteers see their own schedules?
  # Set to true once scheduling is mostly done
  def self.staff_view_schedule
    Configuration.get_cached("staff_view_schedule", "false") == "true"
  end

  # Can staff review projects?  Set to true after PDdays are over
  def self.staff_review_projects
    Configuration.get_cached("staff_review_projects", "false") == "true"
  end

  # Can projects be edited by unit students?  Currently same as staff.
  def self.unit_edit_projects
    Configuration.get_cached("staff_edit_projects", "true") == "true"
  end

  ### AUTHORIZATION

  def authorize_adult
    unless(u=Person.find_by_id(session[:user_id]) and u.adult?)
      flash[:notice] = 'Please log in'
      redirect_to(:controller=>'welcome', :action=>'staff_login')
    end
    @group = 'Staff'
    @current_user = current_user()
  end

  def authorize_unit
    unless(u=Person.find_by_id(session[:user_id]) and u.unit?)
      flash[:notice] = 'Please log in'
      redirect_to(:controller=>'welcome', :action=>'unit_login')
    end
    @group = 'Unit'
    @current_user = current_user()
  end

  def authorize_admin
    unless(session[:admin])
      flash[:notice] = 'Please log in'
      redirect_to(:controller=>'welcome', :action=>'admin_login')
    end
    @group = 'Admin'
  end
    

end
