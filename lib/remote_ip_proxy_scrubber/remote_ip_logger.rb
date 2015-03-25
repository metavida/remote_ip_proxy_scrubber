# Simplify monkey-patching Rails logging
# so that it logs the request.remote_ip, not just the ip
module RemoteIpProxyScrubber
  # Rails 3.3.0 through 4.x
  # define the log format in Rails::Rack::Logger#started_request_message
  # * https://github.com/rails/rails/blob/v4.2.1/railties/lib/rails/rack/logger.rb#L48-L55
  # * https://github.com/rails/rails/blob/v4.0.0/railties/lib/rails/rack/logger.rb#L48-L55
  module Rails4
    class RemoteIPLogger < Rails::Rack::Logger
      protected
      def started_request_message(request)
        'Started %s "%s" for %s at %s' % [
          request.request_method,
          request.filtered_path,
          request.remote_ip,
          Time.now.to_default_s ]
      end
    end
  end
  # Rails 3.2.9 through 3.2.x
  # use the same Rails::Rack::Logger#started_request_message
  # * https://github.com/rails/rails/blob/v3.2.21/railties/lib/rails/rack/logger.rb#L37-L44
  # * https://github.com/rails/rails/blob/v3.2.9/railties/lib/rails/rack/logger.rb#L37-L44
  module Rails3_2_9
    class RemoteIPLogger < RemoteIpProxyScrubber::Rails4:RemoteIPLogger
    end
  end

  # Rails 3.2.0 through 3.2.8
  # define the log format directly in in Rails::Rack::Logger#call_app
  # * https://github.com/rails/rails/blob/v3.2.8/railties/lib/rails/rack/logger.rb#L22-L29
  # * https://github.com/rails/rails/blob/v3.2.0/railties/lib/rails/rack/logger.rb#L22-L29
  module Rails3_2_0
    class RemoteIPLogger < Rails::Rack::Logger
      protected
      def call_app(env)
        request = ActionDispatch::Request.new(env)
        path = request.filtered_path
        Rails.logger.info "\n\nStarted #{request.request_method} \"#{path}\" for #{request.remote_ip} at #{Time.now.to_default_s}"
        @app.call(env)
      ensure
        ActiveSupport::LogSubscriber.flush_all!
      end
    end
  end

  # Rails 3.0.6 through 3.1.X
  # use the Rails::Rack::Logger#before_dispatch method
  # * https://github.com/rails/rails/blob/v3.1.12/railties/lib/rails/rack/logger.rb#L20-L26
  # * https://github.com/rails/rails/blob/v3.1.0/railties/lib/rails/rack/logger.rb#L20-L26
  # * https://github.com/rails/rails/blob/v3.0.20/railties/lib/rails/rack/logger.rb#L20-L26
  # * https://github.com/rails/rails/blob/v3.0.6/railties/lib/rails/rack/logger.rb#L20-L26
  module Rails3_1
    class RemoteIPLogger < Rails::Rack::Logger
      protected
      def before_dispatch(env)
        request = ActionDispatch::Request.new(env)
        path = request.filtered_path

        info "\n\nStarted #{request.request_method} \"#{path}\" " \
             "for #{request.remote_ip} at #{Time.now.to_default_s}"
      end
    end
  end

  # Rails 3.0.0 through 3.0.5
  # also use the Rails::Rack::Logger#before_dispatch method
  # but use a slightly different implementation
  # Rails 3.0.0 through 3.0.3 actually are even more slightly different
  # but I don't expect the difference to affect our functionality
  # * https://github.com/rails/rails/blob/v3.0.5/railties/lib/rails/rack/logger.rb#L20-L26
  # * https://github.com/rails/rails/blob/v3.0.4/railties/lib/rails/rack/logger.rb#L20-L26
  # * https://github.com/rails/rails/blob/v3.0.3/railties/lib/rails/rack/logger.rb#L20-L26
  # * https://github.com/rails/rails/blob/v3.0.0/railties/lib/rails/rack/logger.rb#L20-L26
  module Rails3_0
    class RemoteIPLogger < Rails::Rack::Logger
      protected
      def before_dispatch(env)
        request = ActionDispatch::Request.new(env)
        path = request.fullpath

        info "\n\nStarted #{request.request_method} \"#{path}\" " \
             "for #{request.remote_ip} at #{Time.now.to_default_s}"
      end
    end
  end
end