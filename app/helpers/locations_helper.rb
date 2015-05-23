module LocationsHelper

  # Popup for selecting location
  def loc_popup (s)
    link_to s.project.display_name, {:action=>'assign', :id=>s}, pop_opts()
  end

end
