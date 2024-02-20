# frozen_string_literal: true

require 'action_view'

# Use tag helpers from Vite Ruby
# https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/lib/vite_rails/tag_helpers.rb

module MiniviteRails
  # Public: Allows to render HTML tags for scripts and styles processed by Vite.
  module TagHelpers
    # Public: Renders a script tag for vite/client to enable HMR in development.
    def vite_client_tag(id: nil, crossorigin: 'anonymous', **options)
      src = vite_manifest(id:).vite_client_src
      return unless src

      javascript_include_tag(src, type: 'module', extname: false, crossorigin:, **options)
    end

    # Public: Renders a script tag to enable HMR with React Refresh.
    def vite_react_refresh_tag(id: nil, **options)
      react_preamble_code = vite_manifest(id:).react_preamble_code
      return unless react_preamble_code

      options[:nonce] = true if Rails::VERSION::MAJOR >= 6 && !options.key?(:nonce)

      javascript_tag(react_preamble_code.html_safe, type: :module, **options)
    end

    # Public: Resolves the path for the specified Vite asset.
    #
    # Example:
    #   <%= vite_asset_path 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
    def vite_asset_path(name, id: nil, **options)
      path_to_asset vite_manifest(id:).path_for(name, **options)
    end

    # Public: Resolves the url for the specified Vite asset.
    #
    # Example:
    #   <%= vite_asset_url 'calendar.css' %> # => "https://example.com/vite/assets/calendar-1016838bab065ae1e122.css"
    def vite_asset_url(name, id: nil, **options)
      url_to_asset vite_manifest(id:).path_for(name, **options)
    end

    # Public: Resolves the path for Vite's public assets
    #
    # Example:
    #   <%= vite_public_asset_path 'logo.svg' %> # => "/vite/logo.svg"
    def vite_public_asset_path(name, id: nil)
      path_to_asset vite_manifest(id:).public_path_for(name)
    end

    # Public: Renders a <script> tag for the specified Vite entrypoints.
    def vite_javascript_tag(*names, # rubocop:disable Metrics/ParameterLists
                            id: nil,
                            type: 'module',
                            asset_type: :javascript,
                            skip_preload_tags: false,
                            skip_style_tags: false,
                            crossorigin: 'anonymous',
                            media: 'screen',
                            **options)
      entries = vite_manifest(id:).resolve_entries(*names, type: asset_type)
      tags = javascript_include_tag(*entries.fetch(:scripts), crossorigin:, type:, extname: false,
                                                              **options)
      tags << vite_preload_tag(*entries.fetch(:imports), crossorigin:, **options) unless skip_preload_tags

      options[:extname] = false if Rails::VERSION::MAJOR >= 7

      tags << stylesheet_link_tag(*entries.fetch(:stylesheets), media:, **options) unless skip_style_tags

      tags
    end

    # Public: Renders a <script> tag for the specified Vite entrypoints.
    def vite_typescript_tag(*names, id: nil, **options)
      vite_javascript_tag(*names, id:, asset_type: :typescript, **options)
    end

    # Public: Renders a <link> tag for the specified Vite entrypoints.
    def vite_stylesheet_tag(*names, id: nil, **options)
      style_paths = names.map { |name| vite_asset_path(name, id:, type: :stylesheet) }

      options[:extname] = false if Rails::VERSION::MAJOR >= 7

      stylesheet_link_tag(*style_paths, **options)
    end

    # Public: Renders an <img> tag for the specified Vite asset.
    def vite_image_tag(name, id: nil, **options)
      if options[:srcset] && !options[:srcset].is_a?(String)
        options[:srcset] = options[:srcset].map do |src_name, size|
          "#{vite_asset_path(src_name, id:)} #{size}"
        end.join(', ')
      end

      image_tag(vite_asset_path(name, id:), options)
    end

    private

    # Internal: Returns the current manifest loaded by Vite Ruby.
    def vite_manifest(id: nil)
      MiniviteRails.manifest(id:)
    end

    # Internal: Renders a modulepreload link tag.
    def vite_preload_tag(*sources, crossorigin:, **options)
      asset_paths = sources.map { |source| path_to_asset(source) }
      try(:request).try(
        :send_early_hints,
        'Link' => asset_paths.map do |href|
          %(<#{href}>; rel=modulepreload; as=script; crossorigin=#{crossorigin})
        end.join("\n")
      )
      asset_paths.map do |href|
        tag.link(rel: 'modulepreload', href:, as: 'script', crossorigin:, **options)
      end.join("\n").html_safe
    end
  end
end
