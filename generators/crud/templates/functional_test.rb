require File.dirname(__FILE__) + '<%= '/..' * controller_class_name.split(/::/).size %>/test_helper'
require '<%= controller_class_name.underscore %>_controller'

# Re-raise errors caught by the controller.
class <%= controller_class_name %>Controller; def rescue_action(e) raise e end; end

class <%= controller_class_name %>ControllerTest < Test::Unit::TestCase
  fixtures :<%= table_name %>, :users
  
  def setup
    @controller = <%= controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_get_index
    get :index
    assert_response :success
  
    assert assigns(:<%= table_name %>)
  end
  
  def test_should_get_new
    assert_requires_login(:quentin) do |c|
      c.get :new
      assert_response :success
    end
  end
  
  def test_should_create_<%= file_name %>
    assert_requires_login(:quentin) do |c|
      assert_difference <%= class_name %>, :count do
        c.post :create, :<%= file_name %> => <%= file_name %>_attributes
      end
    
      assert_response :redirect
      assert_redirected_to :controller => "<%= table_name %>", :action => :show, :id => assigns(:<%= file_name %>).id
    end
  end
  
  def test_should_show_<%= file_name %>
    get :show, :id => <%= table_name %>(:first).id
    assert_response :success
  
    assert_equal <%= table_name %>(:first), assigns(:<%= file_name %>)
  end
  
  def test_should_get_edit
    assert_requires_login(:quentin) do |c|
      c.get :edit, :id => <%= table_name %>(:first).id
      assert_response :success
    
      assert_equal <%= table_name %>(:first), assigns(:<%= file_name %>)
    end
  end
  
  def test_should_update_<%= file_name %>
    assert_requires_login(:quentin) do |c|
      <%= file_name %> = <%= table_name %>(:first)
      c.post :update, :id => <%= file_name %>.id, :<%= file_name %> => <%= file_name %>_attributes(<%= file_name %>)
    
      assert_response :redirect
      assert_redirected_to :controller => "<%= table_name %>", :action => :show, :id => <%= file_name %>.id
    
      <%= file_name %> = <%= table_name %>(:first, true)
      assert_equal <%= file_name %>, assigns(:<%= file_name %>)
      # assert_equal new_value, <%= file_name %>.attribute
    end
  end
  
  def test_should_destroy_<%= file_name %>
    assert_requires_login(:quentin) do |c|
      assert_difference <%= class_name %>, :count, -1 do
        c.post :destroy, :id => <%= table_name %>(:first).id
      end
    
      assert_response :redirect
      assert_redirected_to :controller => "<%= table_name %>", :action => :index
    end
  end
  
protected

  def <%= file_name %>_attributes(obj = nil, opts = {})
    opts = obj and obj = nil if obj.is_a?(Hash)
    
    if obj
      obj.attributes.merge(opts.stringify_keys)
    else
      opts.reverse_merge({})
    end
  end
end