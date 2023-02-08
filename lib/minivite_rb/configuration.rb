# frozen_string_literal: true

module MiniviteRb
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
    config_attr :root_path
    config_attr :id, default: ROOT_DEFAULT_ID
    config_attr :cache, default: false
    # The base directory of the frontend.
    config_attr :base_path
    config_attr :vite_dev_server
    config_attr :manifest_path
    config_attr :public_output_path, default: 'public'

    # Initializes a new instance of Configuration class.
    def initialize()
      @config = {}
    end

    # Resolve base_path as an absolute path
    #
    # @return [String]
    def resolved_base_path
      File.expand_path(base_path || '.', root_path)
    end
  end
end