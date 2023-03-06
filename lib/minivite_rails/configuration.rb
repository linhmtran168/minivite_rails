# frozen_string_literal: true

module MiniviteRails
  # Class to manage configuration related logics.
  class Configuration
    class Error < StandardError; end

    ROOT_DEFAULT_ID = :''

    class << self
      def config_attr(prop, default: nil)
        define_method(prop) do
          # If not overridden, children will use parent's setting
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
    def initialize
      @parent = nil
      @children = {}
      @config = {}
    end

    def public_asset_dir
      File.expand_path('.', File.join(public_dir, public_base_path))
    end

    def manifest
      @manifest ||= Manifest.new(self)
    end

    def reload_manifest
      @manifest&.update_config(self)
      @children.each_value(&:reload_manifest)
    end

    def add(id)
      raise Error, 'Can only define sub configuration from root config' unless root?
      raise Error, 'Id already used by root configuration' if id == @config[:id]

      @children[id] ||= self.class.new.tap do |c|
        c.instance_variable_set(:@parent, self)
        c.instance_variable_set(:@children, nil)
        c.id = id
        yield c if block_given?
      end
    end

    def child_by_id(id)
      raise Error, 'Can only get sub configuration from root config' unless root?

      return self if id == @config[:id] # return itself if id is root id

      @children.fetch(id)
    rescue KeyError
      raise Error, "No sub configuration with id #{id}"
    end

    def root?
      @parent.nil?
    end
  end
end
