# frozen_string_literal: true

module MiniviteRails
  require 'minivite_rails/configuration'
  require 'minivite_rails/manifest'
  require 'minivite_rails/tag_helpers'
  require 'minivite_rails/version'

  class << self
    def configuration
      @configuration ||= Configuration.new
      yield @configuration if block_given?
      @configuration
    end

    def manifest(id: nil)
      raise 'MiniviteRails is not configured' if @configuration.nil?

      return @configuration.manifest if id.nil?

      @configuration.child_by_id(id).manifest
    end
  end
end

require 'active_support/lazy_load_hooks'
ActiveSupport.on_load :action_view do
  ::ActionView::Base.include MiniviteRails::TagHelpers
end
