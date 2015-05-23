# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def this_year
    Date.today.year
  end

  ### Generate top navigation tabs
  def tab (name, dispname, options)
    class_att = (@tab && @tab == name) ? 'current' : 'other'
    "<li class=\"#{class_att}\">" + link_to(dispname, options) + "</li>"
  end

  ### Popup window properties
  def pop_opts
    {:onclick=>"return(popwin(this))"}
  end

  ### Timeslot helpers

  def checkbox_for_timeslot (timeslot, checked)
    "<input type=\"checkbox\" name=\"time_ids[]\" id=\"#{timeslot.id}\" value=\"#{timeslot.id}\" #{checked ? 'checked=\"checked\"' : ''}/><label for=\"#{timeslot.id}\">#{timeslot.meddesc}</label>"
  end

  ### Grade helpers

  # Display a grade (integer) appropriately
  def grade (g)
    if (g == nil)
      "NONE"
    elsif (g == 0)
      "K"
    elsif (g == -1)
      "preK"
    elsif (g == 98)
      "Parent"
    elsif (g == 99)
      "Teacher"
    elsif (g < -1)
      "ERROR"
    else
      g
    end
  end    

  ## Display the range of grades allowed for project
  def grade_range (proj) 
    "#{grade(proj.mingrade)} - #{grade(proj.maxgrade)}"
  end

  ## Selector for grades
  def grade_select (obj, attribute)
    select(obj, attribute, Person.studentgrades.collect {|g| [grade(g), g]})
  end

  ## Selector for grades, including adult pseudo-grades
  def grade_select_all (obj, attribute)
    select(obj, attribute, (Person.allgrades).collect {|g| [grade(g), g]})
  end

  ## Selector for grades in a classroom
  def grade_select_classroom (obj, attribute, croom)
    select(obj, attribute, croom.grades.collect {|g| [grade(g), g]})
  end

  def staff_select (obj, attribute)
    select obj, attribute, Person.find_adults.collect {|p| [p.name, p.id]}, :prompt => 'Choose...'
  end

  def teacher_select (obj, attribute)
    select obj, attribute, Person.find_teachers.collect {|p| [p.name, p.id]}, :prompt => 'Choose...'
  end
    
  def parent_select (obj, attribute)
    select obj, attribute, Person.find_parents.collect {|p| [p.name, p.id]}, :prompt => 'Choose...'
  end
    
  def unit_select (obj, attribute)
    select obj, attribute, Person.find_unit.collect {|p| [p.name, p.id]}, :prompt => 'Choose...'
  end

  def project_select (obj, attribute)
    select obj, attribute, Project.list_real.collect {|p| [p.display_name, p.id]}, :prompt => 'Choose...'
  end

  def role_select (obj, att)
    select obj, att, [['Leader', 'L'], ['Helper', 'H'], ['Participant', 'P']]
  end

  def rank_select (obj, att)
    select obj, att, (1..Person.unit_max_choices).to_a.collect {|r| [r, r]}
  end

  def location_select_list
    Location.list.map{|loc| [loc.name, loc.id]}
  end

  # Generate HTML for a link to a project
  def projlink (p)
     link_to p.display_name, :controller=>'projects', :action=>'show', :id=>p
  end

  # Generate HTML with links for a list of projects
  def projlinks (arr)
    arr.map {|p| projlink(p)}.join(', ')
  end

  # Generate HTML for a rank with special formatting
  def showrank (r)
    r ? "<span class=\"rank\">#{r}</span>" : ""
  end

  # Generate HTML for a list of requests
  def showrequests (list)
    list.map {|r| "<span class=\"rank\">#{r.rank}</span> #{r.person.name}" }.join(', ')
  end

  ## Format number as to whether it is under, at, or over a limit
  def numcomp(num, limit)
    if (num == nil)
      return ""
    end
    if (num > limit)
      cls = "over"
    elsif (num < limit)
      cls = "under"
    else
      cls = "equal"
    end
    "<span class=\"#{cls}\">#{num}</span>"
  end

  def classroom_links(act='show')
    @classrooms.map { |c| link_to(c.shortname, :action=>act, :id=>c) }.join(' | ')
  end

  def pref_select(cp)
    sel = "selected=\"selected\""
    s = "<select name=\"catprefs[]\" id=\"#{cp.id}\">"
    s += "<option value=\"1\" #{cp.value==1 ? sel : ''}>YES!</option>"
    s += "<option value=\"2\" #{cp.value==2 ? sel : ''}>Okay</option>"
    s += "<option value=\"3\" #{cp.value==3 ? sel : ''}>No, thanks.</option>"
    s += "</select>"
    s
  end

end
