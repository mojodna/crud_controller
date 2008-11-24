class <%= controller_class_name %>Controller < CRUDController
  before_filter :login_required, :except => [:index, :show]
end
