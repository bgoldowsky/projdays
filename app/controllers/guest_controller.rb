class GuestController < ApplicationController

  layout "choose-layout"

  def index
    redirect_to :action=>:index, :controller=>:welcome
  end

  def projects
    @year = Date.today.year
    @projects = Project.list_by_grade(true, true)
  end

end
