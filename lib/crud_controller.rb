class CRUDController < ApplicationController
  before_filter :find_object, :only => [:show, :edit, :update, :destroy]

  def index
    @order ||= current_model.column_names.include?('created_at') ? 'created_at DESC' : nil
    instance_variable_set("@#{model_name.pluralize}", (current_instance(true) || current_model.find(:all, :order => @order)))
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => render_list_xml }
      index_formats(format)
    end
  end
  
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => current_instance.to_xml }
    end
  end

  def new
    instance_variable_set("@#{model_name}", current_instance || build_model)
    respond_to do |format|
      format.html
      format.xml { render :xml => current_instance.to_xml }
      format.js
    end
  end

  def create
    instance_variable_set("@#{model_name}", build_model)

    respond_to do |format|
      if current_instance.save
        format.html {
          flash[:notice] = "#{model_name.titleize} has been created."
          render_after_create
        }
        format.xml do
          headers["Location"] = model_path
          render :nothing => true, :status => "201 Created"
        end
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => current_instance.errors.to_xml }
        format.js
      end
    end
  end

  # GET /posts/1;edit
  def edit
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    respond_to do |format|
      if current_instance.update_attributes(params_hash)
        format.html {
          flash[:notice] = "#{model_name.titleize} has been updated."
          render_after_update
        }
        format.xml  { render :nothing => true }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => current_instance.errors.to_xml }
        format.js
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    current_instance.destroy

    respond_to do |format|
      format.html { render_after_destroy }
      format.xml  { render :nothing => true }
      format.js
    end
  end

  def update_model_table
    params[model_name].each do |id, val|
      yield(id)
    end
  end

protected

  def build_model
    current_model.new(params_hash)
  end

  def find_object
    instance_variable_set("@#{model_name}", current_instance || (current_model.find(params[:id]) rescue nil))
  end
  
  # Hook for controlling what happens after an object is created.
  def render_after_create
    redirect_back_or_default(after_create_path)
  end
  
  # Hook for controlling what happens after an object is destroyed.
  def render_after_destroy
    redirect_back_or_default(after_destroy_path)
  end
  
  # Hook for controlling what happens after an object is updated.
  def render_after_update
    redirect_back_or_default(after_update_path)
  end

  def after_destroy_path
    model_path(nil, true)
  end

  def model_name
    controller_name.singularize
  end
  
  def render_list_xml
    current_instance(true).to_xml(:root => model_name.pluralize)
  end
  
  # hook for adding additional formats when rendering the list
  def index_formats(format)
  end
  
  class << self
    def after_path(method, options = {})
      options[:on] ||= [:create, :destroy, :update]
      options[:on].each do |action|
        define_method("after_#{action}_path") do
          self.send method.to_sym
        end
      end
    end
    
    def model_class(klass)
      src = <<-end_src
        def model_name
          "#{klass.to_s.underscore}"
        end
      end_src
      class_eval src, __FILE__, __LINE__
    end
  end
  
  after_path :model_path, :on => [:create, :update]

private

  def current_model
    Object.const_get model_name.classify
  end

  # Could use RecordIdentifier bits from SimplyHelpful in here I think, to generate the proper URL
  def model_path(options = current_instance, pluralize = false)
    method_name = "#{pluralize ? model_name.pluralize : model_name}_path"
    if options
      self.send(method_name, options) rescue nil
    else
      self.send(method_name) rescue nil
    end
  end

  def current_instance(pluralize = false)
    instance_variable_get("@#{pluralize ? model_name.pluralize : model_name}")
  end

  def params_hash
    params[model_name.to_sym]
  end

end
