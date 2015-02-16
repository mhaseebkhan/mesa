Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
  config.action_mailer.default_options = { from: "'Mesa&Cadeira' <no-reply@test.com>" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'gmail.com',
      user_name:            'test.amir.yamin@gmail.com',
      password:             '50boiledeggs',
      authentication:       'plain',
      enable_starttls_auto: true  }
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.serve_static_assets = true
  config.assets.compress = false
  config.assets.debug = true
  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  config.action_mailer.perform_deliveries = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

      # Compile Assets *.js and *,css and icons
  config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif,
                                  "/fonts/glyphicons-halflings-regular.ttf",
                                 "/fonts/glyphicons-halflings-regular.eot",
                                 "/fonts/glyphicons-halflings-regular.svg",
                                 "/fonts/glyphicons-halflings-regular.woff")

  # config/application.rb
  config.assets.precompile << Proc.new do |path|
    if path =~ /\.(css|js)\z/
      full_path = Rails.application.assets.resolve(path).to_path
      app_assets_path = Rails.root.join('app', 'assets').to_path
      if full_path.starts_with? app_assets_path
        puts "including asset: " + full_path
        true
      else
        puts "excluding asset: " + full_path
        false
      end
    else
      false
    end
  end

end
