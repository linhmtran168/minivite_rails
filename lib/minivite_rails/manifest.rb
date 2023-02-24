# frozen_string_literal: true

require 'json'
require 'active_support/core_ext/object/blank'
require 'rails'

module MiniviteRails
  class Manifest
    class FileNotFoundError < StandardError; end
    class MissingEntryError < StandardError; end

    attr_reader :config, :manifest_path

    def initialize(config)
      update_config(config)
    end

    def update_config(config)
      @config = config
      @manifest_path = config.manifest_path || File.join(config.public_asset_dir, 'manifest.json')
      @data = nil
    end

    def data
      return load_manifest unless config.cache

      @data ||= load_manifest
    end

    def path_for(name, **options)
      lookup!(name, **options).fetch('file')
    end

    def vite_client_src
      prefix_vite_asset('@vite/client') if dev_server_available?
    end

    def resolve_entries(*names, **options)
      entries = names.map { |name| lookup!(name, **options) }
      script_paths = entries.map { |entry| entry.fetch('file') }

      imports = dev_server_available? ? [] : entries.flat_map { |entry| entry['imports'] }.compact.uniq
      {
        scripts: script_paths,
        imports: imports.map { |entry| entry.fetch('file') }.uniq,
        stylesheets: dev_server_available? ? [] : (entries + imports).flat_map { |entry| entry['css'] }.compact.uniq
      }
    end

    def react_refresh_preamble
      return unless dev_server_available?

      <<~REACT_REFRESH
        <script type="module">
          import RefreshRuntime from '#{prefix_vite_asset('@react-refresh')}'
          RefreshRuntime.injectIntoGlobalHook(window)
          window.$RefreshReg$ = () => {}
          window.$RefreshSig$ = () => (type) => type
          window.__vite_plugin_react_preamble_installed__ = true
        </script>
      REACT_REFRESH
    end

    protected

    def dev_server_available?
      !Rails.env.production? && config.vite_dev_server.present?
    end

    def load_manifest
      u = URI.parse(manifest_path)
      data = nil
      if u.scheme == 'file' || u.path == manifest_path # file path
        raise(FileNotFoundError, "#{manifest_path}: no such manifest found") unless File.exist?(manifest_path)

        data = File.read(manifest_path)
      else
        # http url
        data = u.read
      end
      JSON.parse(data).tap(&method(:resolve_references))
    end

    def prefix_vite_asset(path)
      root_path = dev_server_available? ? config.vite_dev_server : '/'
      File.join(root_path, config.public_base_path, path)
    end

    # Internal: Resolves the paths that reference a manifest entry.
    def resolve_references(manifest)
      manifest.each_value do |entry|
        entry['file'] = prefix_vite_asset(entry['file'])
        %w[css assets].each do |key|
          entry[key] = entry[key].map { |path| prefix_vite_asset(path) } if entry[key]
        end
        entry['imports']&.map! { |name| manifest.fetch(name) }
      end
    end

    def lookup!(name, **options)
      lookup(name, **options) || missing_entry_error(name, **options)
    end

    # Internal: Computes the path for a given Vite asset using manifest.json.
    #
    # Returns a relative path, or nil if the asset is not found.
    #
    # Example:
    #   manifest.lookup('calendar.js')
    #   => { "file" => "/vite/assets/calendar-1016838bab065ae1e122.js", "imports" => [] }
    def lookup(name, **options)
      find_manifest_entry resolve_entry_name(name, **options)
    end

    def find_manifest_entry(name)
      if dev_server_available?
        { 'file' => prefix_vite_asset(name) }
      else
        data[name]
      end
    end

    def resolve_entry_name(name, type: nil)
      return resolve_virtual_entry(name) if type == :virtual

      name = with_file_extension(name.to_s, type)
      raise ArgumentError, "Asset names can not be relative. Found: #{name}" if name.start_with?('.')

      # Explicit path, relative to the source_code_dir.
      name.sub(%r{^~/(.+)$}) { return Regexp.last_match(1) }
      name
    end

    # Internal: Resolves a virtual entry by walking all the manifest keys.
    def resolve_virtual_entry(name)
      data.keys.find { |file| file.include?(name) } || name
    end

    # Internal: Adds a file extension to the file name, unless it already has one.
    def with_file_extension(name, entry_type)
      if File.extname(name).empty? && (ext = extension_for_type(entry_type))
        "#{name}.#{ext}"
      else
        name
      end
    end

    # Internal: Allows to receive :javascript and :stylesheet as :type in helpers.
    def extension_for_type(entry_type)
      case entry_type
      when :javascript then 'js'
      when :stylesheet then 'css'
      when :typescript then 'ts'
      else entry_type
      end
    end

    # Internal: Raises a detailed message when an entry is missing in the manifest.
    def missing_entry_error(name, **_options)
      raise MissingEntryError, <<~MSG
        Can not find #{name} in #{manifest_path}.
        Your manifest contains:
        #{JSON.pretty_generate(data)}
      MSG
    end
  end
end
