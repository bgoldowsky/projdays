module ProjectsHelper

  # Show person's name, but note if they're already scheduled.
  def person_note_if_scheduled (proj, person)
    plink = link_to(person.name, :controller=>'people', :action=>'show', :id=>person)
    if(proj.assignment_for_person(person))
      "<del>" + plink + "</del>"
    else
      plink
    end
  end

  # Show either an "assign" or "unassign" link for a given
  # request and session.  Ajax refreshes the given <tr>.
  def sess_sched_toggle (req, sess, trid, timeslot)
    assg = sess.assignments.detect {|a| a.person == req.person}
    if (assg)
      link = url_for(:action=>'sched_unassign', :id=>assg, :proj=>req.project, :trid=>trid)
      r = "<span class=\"scheduled\">"
      r += "<a href=\"#\" onclick=\"return update_tr('#{trid}', '#{link}')\">#{req.project.display_name}</a>"
    else
      conflict = sess.conflict_for_person(req.person)
      sched = req.person.assignments_for(timeslot)
      if (conflict.size > 1 and !sched.empty?)
        # Multiple conflicts; click just unschedules one.
        r = "<span class=\"conflict\">"
        for item in sched
          link = url_for(:action=>'sched_unassign', :id=>item, :proj=>req.project, :trid=>trid)
          r += "<a href=\"#\" onclick=\"return update_tr('#{trid}', '#{link}')\">#{item.sess.project.display_name}</a> "
        end
      elsif (!sched.empty?)
        # Single conflict.
        # Allow replacement of conflicting item and re-schedule to proj.
        link = url_for(:action=>'sched_assign', :id=>conflict.first.id, :req=>req.id, :sess=>sess.id, :trid=>trid)
        r = "<span class=\"conflict\">"
        r += "<a href=\"#\" onclick=\"return update_tr('#{trid}', '#{link}')\">#{conflict.first.sess.project.display_name}</a>"
      elsif (!conflict.empty?)
        # There is a conflict, but not in this timeslot. Leave cell blank
        r = "<span style=\"text-align: center\">#"
      else 
        # Non-conflicting empty session
        link = url_for(:action=>'sched_assign', :req=>req.id, :sess=>sess.id, :trid=>trid)
        r = "<span class=\"unsched\">"
        r += "<a href=\"#\" onclick=\"return update_tr('#{trid}', '#{link}')\">+</a>"
      end
    end
    r += "</span>"
    return r
  end

  def sess_sched_links (req)
    res = ''
    sesses = req.project.sesses.sort {|a,b| a.to_s<=>b.to_s}
    for s in sesses
      link = link_to(s.to_s, :action=>'assign_requester', :id=>req.id, :sess=>s, :role=>req.role)
      if (s.assignments.detect {|a| a.person == req.person})
        res += "<span class=\"scheduled\">#{link}</span>"
      elsif (!s.conflict_for_person(req.person).empty?)
        res += "<span class=\"conflict\">#{link}</span>"
      else
        res += link
      end
    end
    if req.role != 'P' and sesses.length > 1
      res += link_to('[all]', :action=>'assign_requester_all', :id=>req.id)
    end
    return res
  end

  def sess_unsched_links (req)
    res = ""
    num_assigned = 0
    sesses = req.project.sesses.sort {|a,b| a.to_s<=>b.to_s}
    for s in sesses
      a = s.assignments.detect {|a| a.person == req.person}
      if (a)
        res += link_to(s, :action=>'unassign', :id=>a)
        num_assigned += 1
      end
    end
    if num_assigned > 1
      res += link_to('[all]', :action=>'unassign_requester_all', :id=>req.id)
    end
    return res
  end

end
