module CRUDHelper
  def cancel_link(options = {})
    if options.is_a?(Hash)
      options = options.merge(:action => 'index')
      url = url_for(options)
    else
      url = options
    end
    link_to 'Cancel', url
  end
  
  def create_or_update_submit_tag(object)
    submit_tag( object.new_record? ? "Submit" : "Update" )
  end
  
  # commenting out the function call for now since the JS is not included in the plugin
  # Borrowed from RadiantCMS
  def ruled_table(table_name, separator = nil)
    %{<script type="text/javascript">
    // <![CDATA[
      new RuledTable('#{table_name}'#{separator ? ", '"+ separator +"'" : nil});
    // ]]>
    </script>}
  end

  # from project.ioni.st
  # make_list(@links) {|l| link_to l.label, l.url}
  def make_list(items, options = {}, type = :ul)
    lis = items.map {|i| content_tag(:li, yield(i))} 
    content_tag(type, lis * "\n", options)
  end
  
  # Returns a string containing the controller name + '/' + controller.action_name
  def controller_action
    @controller_action ||= [controller.controller_name, controller.action_name].join('/')
  end

  # Returns 'selected' for the navigation menu if selected_url?
  def selected?(pattern)
    'current' if selected_url?(pattern)
  end

  # Returns 'selected' for the navigation menu if either the 
  # request.path + request.query_parameters matches, or if the pattern passed in is 
  # not a boolean and evaluates to 'true' (allows for more flexible calls to the method)
  #
  # Usage: selected?(/account/) # matches account
  # Usage: selected?(/^\/account/) # Rails' paths will include a prefix slash (/accounts), so use this
  #   if you want to match from the beginning of the path.
  def selected_url?(pattern)
    # Need to check using #blank? because empty strings won't be popped from an array with compact
    # and we don't want the query string separator ("?") to be included unless necessary
    @path_with_query_string ||= [request.path, request.query_string.blank? ? nil : request.query_string].compact.join('?')
    pattern.is_a?(Regexp) ? !!(@path_with_query_string =~ pattern) : !!pattern
  end

end