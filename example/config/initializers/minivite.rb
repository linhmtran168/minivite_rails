# frozen_string_literal: true

MiniviteRails.configuration do |c|
  # By default c.cache is set to `false`, which means an application always parses a
  # manifest.json. In development, you should set cache false usually.
  # Instead, setting it `true` which caches the manifest in memory is recommended basically.
  c.cache = Rails.env.production?

  # Register vite dev server address here, if you are using vite dev server.
  # It will only be used in development mode.
  c.vite_dev_server = 'http://localhost:5173'

  # Vite base path, default will be `/vite`
  # c.public_base_path = '/vite'

  # Vite public directory, default will be `public`
  # c.public_dir, default: 'public'

  # Vite manifest file path, default will be `#{c.public_dir}#{c.public_base_path}/manifest.json`
  # c.manifest_path = "#{c.public_dir}#{c.public_base_path}/.vite/manifest.json"

  # Sub configuration for admin panel
  c.add :admin do |sc|
    sc.public_base_path = '/vite_admin'
    sc.vite_dev_server = 'http://localhost:5174'
  end
end
