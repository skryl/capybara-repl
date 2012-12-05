# About

Capybara REPL environment for experimenting with drivers and running Capybara and Cucumber scripts.

## Installation

Add this line to your application's Gemfile:

    gem 'capybara-repl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-repl

## Usage

Run the bundled binary

    $ capybara


You will be greeted by a help banner inside a Pry shell

    Capybara DSL

      visit   '/apply'
      fill_in 'username', with: 'nconjure'

    Commands

      url    [URL]  -  connect to a custom url for Capybara to control
      driver [NAME] -  select a web driver for Capybara to use
      drivers       -  list all supported Capybara drivers
      snap   [PATH] -  take a screenshot of the currently active Capybara page
      exec   PATH   -  execute a plain Capybara script
      cuke   PATH   -  scan path for cucumber step definitions and load
      given  NAME   -  invoke a loaded cucumber step definition
      steps         -  show all available cucumber steps
      all { ... }   -  run Capybara commands in multiple browsers (terminus driver only)
      commands      -  print the available capybara DSL commands
      h             -  print this message


This is just a good 'ol Pry shell with the Capybara stack loaded and some extra
helpers.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
