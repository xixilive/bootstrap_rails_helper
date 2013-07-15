module BootstrapFormHelper

  def control_group form, field, opts={}, &block
    errors = opts.delete(:errors)
    label = opts.delete(:label) || field_name(field)
    content_tag(:div, :class=>"control-group") do
      concat content_tag(:label, label, :class=>"control-label")
      concat(content_tag(:div, :class=>"controls"){
        if(block_given?)
         concat yield(form, field, opts)
        else
         concat form_field(form, field, opts)
        end
        concat content_tag(:span, errors.join(","), :class=>"help-inline error-help") if (errors && errors.count >0)
      })
    end
  end

  def form_action form, opts, &block
    content_tag(:div, :class=>"form-actions") do
      if block_given?
        concat yield(form, opts)
      else
        submit_label = opts.delete(:submit)
        concat form.submit(submit_label, :class=>'btn btn-primary')

        cancel = opts.delete(:cancel)
        if (cancel)
          label = cancel[0]
          url = cancel[1]
          concat content_tag(:span, "OR")
          concat link_to(label, url, :class=>"cancel")
        end
      end
    end
  end

  def form_field form, field, opts
    type = opts.delete :type
    raise "No type defined for #{field} field" if type.nil?

    cls =  opts.delete(:class)
    size = opts.delete(:size)
    help = opts.delete(:help)

    opts = opts.merge(:class=>[cls, size].compact.join(" "))
    opts = opts.merge(:title=>help, :"data-toggle"=>"tooltip", :"data-trigger"=>"focus", :"data-placement"=>"bottom") if help.present?

    field_of(form, field) do |f, field|
      case type
      when :select
        f.select(field, selection_values(opts), opts)

      when :radio_button
        render_radio_button(f, field, selection_values(opts))

      when :check_box
        render_check_box(f, field, selection_values(opts))  

      else
        f.send(type.to_sym, field, opts)
      end
    end
  end


  def field_of form, field

    nested_fields = field.to_s.split(".")
    if (nested_fields.size == 2)
      form.fields_for(nested_fields[0].to_sym) {|fields|
        yield(fields, nested_fields[1].to_sym)
      }
    else
      yield(form, field)
    end
  end

 

  def render_fileupload(file_field, extra=nil)
    extra ||= ""
    render :partial=>"components/bootstrap/fileupload", :locals=>{file_field: file_field, extra:extra}
  end

  def render_check_box form, field, selection
    check_boxes = selection.collect do |item|
      content_tag(:label, :class=>"checkbox") do
        concat form.check_box(field, {}, item[1], nil)
        concat item[0]
      end
    end
    check_boxes.join("\n").html_safe
  end

  def render_radio_button form, field, selection
    radio_buttons = selection.collect do |item|
      content_tag(:label, :class=>"radio") do
        concat form.radio_button(field, item[1])
        concat item[0]
      end
    end
    radio_buttons.join("\n").html_safe
  end

  private 
  def selection_values opts
    selection = opts.delete(:selection)
    if selection.respond_to? :keys
      selection.collect{|k,v| [v,k]}
    else
      selection.collect{|i| [i,i]}
    end
  end

end
