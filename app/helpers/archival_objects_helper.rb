module ArchivalObjectsHelper
  include ApplicationHelper
  include DigitalObjectsHelper

  def archival_object_html(record, options={})
    p = record.presenter
    if p.containers || (p.digital_objects && p.level != 'series')
      output = "<div class='row container-list-item'>"
      output << "<div class='small-8 medium-10 columns'>#{archival_object_description(p, options)}</div>"
      output << "<div class='small-4 medium-2 columns'>#{container_info(record, options)}</div>"
    else
      output = "<div class='row'>"
      output << "<div class='small-12 columns'>#{archival_object_description(p, options)}</div>"
    end
    output << '</div>'
  end


  def archival_object_description(presenter, options={})
    output = ''
    p = presenter
    heading = p.title || ''
    heading += !p.date_statement.blank? ? " <span class=\"date\">#{p.date_statement}</span>" : ''
    heading += !p.component_id.blank? ? " <span class=\"component-id\">(#{p.component_id})</span>" : ''

    if options[:layout] === false
      output << content_tag('div', heading.html_safe, class: 'component-title')
    else
      output << content_tag('h1', heading.html_safe, class: 'component-title')
    end

    if !p.extent_statement.blank?
      output << inline_description_element('extent', p.extent_statement, 'Size')
    end

    if p.abstract
      output << inline_description_element('abstract', p.abstract)
    end

    note_elements.map { |x| x.to_sym}.each do |e|
      if p.notes[e]
        previous_label = ''
        p.notes[e].each do |note|
          note_content = ''
          label = note_label(e, note)
          if label == previous_label
            note_content << "<div class=\"element-heading\">#{label}</div>"
          end
          previous_label = label
          note_content << note[:content]
          output << content_tag('div', note_content.html_safe, class: "description-element #{e}")
        end
      end
    end


    if p.subjects || p.agents
      access_terms_output = '<div class="description-element access-terms">'
      terms = []
      if p.agents
        p.agents.each do |a|
          # agent = agent_search_link(a).html_safe
          agent = a[:display_name]
          if a[:relator_term]
            agent << " (#{a[:relator_term]})"
          elsif !a[:relator_term] && a[:role] == 'creator'
            agent << " (Creator)"
          end
          terms << agent
        end
      end
      if p.subjects
        p.subjects.each do |s|
          # terms << subject_search_link(s).html_safe
          terms << s[:subject]
        end
      end
      access_terms_output << terms.join('; ')
      access_terms_output << '</div>'
      output << access_terms_output.html_safe
    end


    if p.digital_objects && !p.containers && p.level == 'series'
      digital_object_output = '<div class="description-element digital-objects">'
      digital_object_output << archival_object_digital_object_link(p)
      digital_object_output << '</div>'
      output << digital_object_output.html_safe
    end


    output.html_safe
  end





  def container_info(record, options={})
    output = ''
    p = record.presenter
    container_div_class = p.containers ? "containers" : "containers empty"
    output << "<div class=\"#{container_div_class}\">#{p.containers ? p.containers.join('; ') : ''}</div>"
    if p.digital_objects
      do_link = archival_object_digital_object_link(p)
      if do_link
        output << "<div class=\"digital-objects\">#{ archival_object_digital_object_link(p) }</div>"
      end
    end
    output.html_safe
  end


  # Load custom methods if they exist
  begin
    include ArchivalObjectsHelperCustom
  rescue
  end

end
