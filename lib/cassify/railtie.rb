class CassifyRailtie < Rails::Railtie
  config.after_initialize do
    ActionController::Base.prepend_view_path(File.expand_path("../views", __FILE__))
  end
end
