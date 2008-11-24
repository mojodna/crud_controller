class CrudGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    # Take controller name from the next argument.  Default to the pluralized model name.
    @controller_name = args.shift
    @controller_name ||= ActiveRecord::Base.pluralize_table_names ? @name.pluralize : @name
    
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_class_path, "#{controller_class_name}Controller", 
                                                "#{controller_class_name}ControllerTest", 
                                                "#{controller_class_name}Helper"
      m.class_collisions class_path,            "#{class_name}"
                                                #"#{class_name}Test"
      
      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      m.directory File.join('test/functional', controller_class_path)
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      
      m.template 'controller.rb',
        File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      
      m.template 'functional_test.rb',
        File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb")
      
      m.template 'helper.rb',
        File.join('app/helpers', controller_class_path, "#{controller_file_name}_helper.rb")
      
      %w( index new show edit _form ).each do |action|
        m.template "#{action}.rhtml",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.rhtml")
      end
      
      m.template '_partial.rhtml',
        File.join('app/views', controller_class_path, controller_file_name, "_#{file_name}.rhtml")
        
      m.template 'destroy.rjs',
        File.join('app/views', controller_class_path, controller_file_name, "destroy.rjs")
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} crud ModelName ControllerName"
    end
end