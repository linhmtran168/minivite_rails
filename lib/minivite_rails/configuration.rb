# frozen_string_literal: true

module MiniviteRails
  class Configuration
    class Error < StandardError; end

    ROOT_DEFAULT_ID = :''

    class << self
      def config_attr(prop, default: nil)
        define_method(prop) do
          @config.fetch(prop) do
            @parent ? @parent.public_send(prop) : default
          end
        end

        define_method("#{prop}=".to_sym) do |v|
          @config[prop] = v
        end
      end
    end

    # Private
    config_attr :id, default: ROOT_DEFAULT_ID
    config_attr :cache, default: false
    # The base directory of the frontend.
    config_attr :vite_dev_server
    config_attr :manifest_path
    config_attr :public_base_path, default: '/vite'
    config_attr :public_dir, default: 'public'

    # Initializes a new instance of Configuration class.
    def initialize()
      @config = {}
    end

    def public_asset_dir
      File.expand_path('.', File.join(public_dir, public_base_path))
    end
  end
end