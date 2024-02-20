# MiniviteRails

MiniviteRails provides minimal integration with [Vite](https://vitejs.dev/) for Rails projects.

__DISCLAIMER:__ This gem is not thoroughly tested and is not yet ready for production use. For battle-tested and full featured integration with Vite for not only Rails but Ruby projects, please check out [vite_ruby](https://vite-ruby.netlify.app/). In fact, this gem reuses a lot of code from [vite_ruby](https://vite-ruby.netlify.app/) and is intended just for my projects' specific use cases that requires full manual control over Vite's configuration and build process.

## Features

* Rails view helpers to resolve paths to assets which are built by Vite (both by Vite's dev server and by Vite's build process).
* Support multiple configurations for Vite

### Notes

* MiniviteRails does not automatically install Vite and manage Vite's configuration. You must install Vite, its dependencies and manage Vite's configuration manually.
* It also does not provide any integration with Rails' asset pipeline. So you must use Vite to build all your assets.

If you need above features, please use [vite_ruby](https://vite-ruby.netlify.app/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minivite_rails'
```

And then run:

```sh
$ bundle install
```

## Configuration

After installed, configure your Rails app below as a new file `config/initializers/minivite_rails.rb`.

```rb
MiniviteRails.configuration do |c|
  # By default c.cache is set to `false`, which means an application always parses a
  # manifest.json. In development, you should set cache false usually.
  # Instead, setting it `true` which caches the manifest in memory is recommended basically.
  c.cache = Rails.env.production?

  # Register vite dev server address here, if you are using vite dev server.
  # It will only be used in development mode.
  c.vite_dev_server = 'http://127.0.0.1:5173'

  # Vite base path, default will be `/vite`
  # c.public_base_path = '/vite'

  # Vite public directory, default will be `public`
  # c.public_dir, default: 'public'

  # Vite manifest file path, default will be `#{c.public_dir}#{c.public_base_path}/.vite/manifest.json`
  # c.manifest_path = "#{c.public_dir}#{c.public_base_path}/.vite/manifest.json"
end
```

With the above default configuration, you are expected to have a Vite's configuration like below:

```js
import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  base: '/vite',
  plugins: [vue()],
  build: {
    manifest: true, // This is required
    rollupOptions: {
      input: fileURLToPath(new URL('./src/main.ts', import.meta.url)) // The entry file of your application, it will depends on your project structure
    },
    // For this example, the frontend code and vite configuration file are directly in a child folder from the root of the Rails project.
    outDir: fileURLToPath(new URL('../public/vite', import.meta.url)),
    emptyOutDir: true,
  },
  server: {
    origin: 'http://127.0.0.1:5173' // For referencing assets from vite dev server
  }
})
```

## Usage

### Rails view helpers

Use the following helpers in your Rails views to resolve paths to assets which are built by Vite.

### `vite_javascript_tag`

Renders a `<script>` tag for the specified Vite js entrypoints. This is the most commonly used helper and will also load needed css entrypoints. The entry path must be relative to the root path of Vite project.

```erb
<%= vite_javascript_tag 'src/main.js' %>
```

### `vite_typescript_tag`

Same as `vite_javascript_tag` but for typescript entrypoints

### `vite_stylesheet_tag`

Renders a `<link>` tag for the specified Vite css entrypoints

```erb
<%= vite_stylesheet_tag 'app.css' %>
```

### `vite_client_tag`

Render a script tag to load vite/client to enable HMR

```erb
<%= vite_client_tag %>
```

### `vite_react_refesth_tag`

Render a script tag to enable HMR with React Refresh

```erb
<%= vite_react_refesh_tag %>
```

### `vite_asset_path`

Render a path to a specified asset built by Vite

```erb
<%= vite_asset_path 'calender.js' %>
```

### `vite_asset_url`

Same as `vite_asset_path` but returns a full URL

### `vite_public_asset_path`

Render a path to a public asset copied by Vite

```erb
<%= vite_public_asset_path 'logo.svg' %>
```

### `vite_image_tag`

Renders an `<img>` tag for the specified Vite image asset

```erb
<%= vite_image_tag 'logo.png' %>
```

### Multiple configurations

Besides the main configuration, you can also register multiple configurations for Vite. For example, you may want to have a separate configuration for your admin panel.

```rb
MiniviteRails.configuration do |c|
  # Main configuration
  c.cache = Rails.env.production?
  c.vite_dev_server = 'http://127.0.0.1:5173'

  # Sub configuration for admin panel
  c.add :admin do |sc|
    sc.public_base_path = '/vite_admin'
    sc.vite_dev_server = 'http://127.0.0.1:5174'
  end
end
```

The corresponding Vite configuration for above admin panel:

```js
import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  base: '/vite_admin/',
  plugins: [react()],
  build: {
    manifest: true, // This is required
    rollupOptions: {
      input: fileURLToPath(new URL('./src/main.jsx', import.meta.url))
    },
    outDir: fileURLToPath(new URL('../public/vite_admin', import.meta.url)),
    emptyOutDir: true,
  },
  server: {
    port: 5174,
    origin: 'http://127.0.0.1:5174'
  }
})

```

__Note:__ The sub configuration must have a unique name and it will inherit all the configurations' value from the main configuration.

## Special Thanks

This project uses ideas and codes from the following projects:

* [vite_ruby](https://github.com/ElMassimo/vite_ruby)
* [minipack](https://github.com/nikushi/minipack)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
