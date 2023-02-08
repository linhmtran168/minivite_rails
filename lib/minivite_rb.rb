# frozen_string_literal: true



module MiniviteRb
  require 'minivite_rb/configuration'
  require 'minivite_rb/manifest'
  require 'minivite_rb/tag_helpers'
  require 'minivite_rb/version'

  class << self
    def configuration(&block)
      @configuration ||= Configuration.new
      yield @configuration if block_given?
      @configuration
    end

    def configuration=(configuration)
      @configuration = configuration
      @manifest = nil
    end

    def manifest
      @manifest ||= Manifest.new(configuration)
    end
  end
end

require 'active_support/lazy_load_hooks'
ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, MiniviteRb::TagHelpers
end
