module BootstrapHelper

 class TabBuilder
    attr_accessor :tabs

    def tab name, opts={}, &block
      @tabs ||= []
      @tabs << {:name=>name, :opts=>opts, :proc=>block}
    end

    def tabs
      return @tabs || []
    end
  end

  def bootstrap_form_fields form, model, &block
    BootstrapFormBuilder.render_items(form, model, self, &block)
  end

  # Render a standard bootstrap sidebar panel with nav-stacked, nav-pills content
  # 
  # opts:: Options that will be passed to the yieled block
  def bootstrap_sidebar opts={}
    content_tag(:div, :class=>"section sidebar-nav") do
      nav_class = opts.delete(:nav_class) || "nav-pills nav-stacked"
      content_tag(:ul, :class=>"nav #{nav_class}") do
        header = opts.delete(:header)
        concat(content_tag :li, header.html_safe, :class=>"nav-header") if header.present?
        yield(opts) if block_given?
      end
    end
  end
  

  # Render a standard fixed-top bootstrap navbar 
  # It will yield to a block that will output nav menus as <li> markup.
  # #bootstrap_dropdown_menu will output a menu markup.
  #
  # opts[:brand]:: The html markups for brand section
  # opts[:right]:: The html markups for the pull-right section
  def bootstrap_navbar opts={}, &block
    brand = opts.delete :brand || ""
    right = opts.delete :right || ""
    
    content_tag(:div, :class=>"navbar navbar-fixed-top") do
      content_tag(:div, :class=>"navbar-inner") do
        content_tag(:div, :class=>"container-fluid") do
          concat(nav_collapse.html_safe)
          concat(link_to brand.html_safe, "#", :class=>"brand")
          nav = content_tag(:div, :class=>"container-fluid nav-collapse") do
            concat(content_tag(:ul, :class=>"nav", &block))
            concat(content_tag(:ul, right, :class=>"nav pull-right"))
          end
          concat(nav)
        end
      end
    end
  end

  # Render a dropdown menu <li> markup in the bootstrap nav bar
  # It will yield to a block that will output the menu items as html <li> tag
  #
  # menu:: The text on the menu
  def bootstrap_dropdown_menu menu, cls=nil
    opts = {:class=>["dropdown",cls].compact.join(" ")}
    content_tag(:li, opts) do
      concat link_to(%{#{menu} #{content_tag :b, "", :class=>"caret"}}.html_safe, "#", :class=>"dropdow-toggle", :"data-toggle"=>"dropdown")
      concat content_tag(:ul, :class=>"dropdown-menu"){yield}
    end
  end

  # Render a bootstrap dropdown button.
  # The yielded block should render each dropdown item as a <li>
  # 
  # content:: The html content on the button
  # opts[:class]:: The dropdown button class, default is "btn"
  def bootstrap_dropdown_button content, opts={}
    btn_class = (opts||{}).delete(:class) || "btn"
    content_tag(:div, :class=>"btn-group") do
      concat link_to(%{#{content} #{content_tag :span, "", :class=>"caret"}}.html_safe, "#", :class=>"#{btn_class} dropdown-toggle", :"data-toggle"=>"dropdown")
      concat content_tag(:ul, :class=>"dropdown-menu"){yield if block_given?}
    end
  end


  # Render a bootstrap button group
  # data:: The data content in the button group. If it is an emuratable object, this method
  # will yield the block with each item in the collection.
  def bootstrap_btn_group data=nil, &block
    content_tag(:div, :class=>"btn-group") do
      if data.respond_to? :each
        data.each(&block)
      else
        yield data
      end
    end
  end


  # Render standard fav link icons for different devices.
  # It normally embeded in the <header>
  def bootstrap_fav_links
    render "components/bootstrap/fav_links"
  end

  # Render a bootstrap modal panel.
  # It will yield to a block that should ouput the modal-body content
  #
  # options[:id]:: Dialog id
  # options[:title]:: Dialog title, default "Title"
  # options[:actions]:: Html markups for modal-footer section, default is a Cancel button
  # options[:remote_path]:: If presented, the modal div will have 'data-remote-path' attribute set to this value
  def bootstrap_modal options
    id = options.delete(:id)
    remote_path = options.delete(:remote_path)
    title=options.delete(:title) || "Title"
    actions = options.delete(:actions) || [link_to("Cancel","#", :class=>"btn ", :"data-dismiss"=>"modal", :"aria-hidden"=>"true")]
    cls = options.delete(:class) || ""

    modal_options = {:class=>"modal hide fade #{cls}"}
    modal_options[:id] = id if id.present?
    modal_options[:"data-remote-path"] = remote_path if remote_path.present?

    content_tag(:div, modal_options) do
      concat(content_tag(:div, :class=>"modal-header"){
        concat content_tag(:button,"&times;".html_safe, :type=>"button", :class=>"close", :"data-dismiss"=>"modal", :"aria-hidden"=>"true")
        concat content_tag(:h3, title)
      })
      concat(content_tag(:div, :class=>"modal-body"){yield if block_given?})
      concat content_tag(:div, actions.join("\n").html_safe, :class=>"modal-footer")
    end
  end

 
  # Render a bootstrap tab pane
  # Example code:
  # <tt>
  #   bootstrap_tabs(tab_pos: "tabs-top") do |t|
  #     t.tab "Tab1", :id=>"id_of_tab1" do
  #       ...
  #     end
  #     t.tab "Tab2", :id=>"id_of_tab2" do
  #       ...
  #     end
  #   end
  # </tt>
  #
  # Parameters for the tab panel
  # opts[:tab_pos]:: The bootstrap class name for the tab position, like "tab-top". 
  #                  Default value is "tab-top"
  # 
  # Parameters for each tab
  # name:: The tab name
  # opts[:id]:: The tab id, default value is the tab name
  #
  def bootstrap_tab_pane opts={}
    tab_builder = TabBuilder.new
    yield(tab_builder) if block_given?

    tab_pos = opts.delete(:tab_pos) || "tabs-top"
    tab_options = tab_builder.tabs.collect do |item|
      opts = item[:opts] || {}
      name = item[:name]
      id = opts.delete(:id) || name
      {:id=>id, :link=>link_to(name, "##{id}", :"data-toggle"=>"tab"), :content_proc=>item[:proc], :opts=>opts}
    end

    content_tag :div, :class=>"tabbable #{tab_pos}" do
      concat(content_tag(:ul, :class=>"nav nav-tabs"){
        tab_options.each_with_index do |item, index|
          cls = "active" if index==0
          concat content_tag(:li, item[:link], :class=>cls)
        end
      })

      concat(content_tag(:div, :class=>"tab-content"){
        tab_options.each_with_index do |item, index|
          opts = {:id=>item[:id], :class=>"tab-pane #{'active' if index==0}"}.merge(item[:opts])
          concat(content_tag(:div, opts){
            proc = item[:content_proc] 
            proc.call if proc
          })
        end
      })

    end
  end


  private 
  def nav_collapse
    content_tag(:a, :class=>"btn btn-navbar", :"data-target"=>".nav-collapse", :"data-toggle"=>"collapse") do
      (1..3).each{|i| concat(content_tag :span,"", :class=>"icon-bar")}
    end
  end

end