# MiniviteRails

MiniviteRails provides minimal integration with [Vite](https://vitejs.dev/) for Rails projects.

__DISCLAIMER:__ This gem is not thoroughly tested and is not yet ready for production use. For battle-tested and full featured integration with Vite for not only Rails but Ruby projects, please check out [vite_ruby](https://vite-ruby.netlify.app/). In fact, this gem reuses a lot of code from [vite_ruby](https://vite-ruby.netlify.app/) and is intended just for my projects' specific use cases that requires full manual control over Vite's configuration and build process.

## Features

* Rails view helpers to resolve paths to assets which are built by Vite (both by Vite's dev server and by Vite's build process).
* Support multiple configurations for Vite

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/minivite_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
