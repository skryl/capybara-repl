class CapybaraRepl
    include CapybaraRepl::FakerDSL

    BUILTIN_DRIVERS =  [:selenium_firefox, :selenium_chrome] 
    OPTIONAL_DRIVERS = [:mechanize, :webkit, :poltergeist, :terminus]

    DRIVERS = BUILTIN_DRIVERS + OPTIONAL_DRIVERS

    DRIVER_GEMS = {
      :mechanize   => 'capybara-mechanize',
      :webkit      => 'capybara-webkit',
      :poltergeist => 'poltergeist',
      :terminus    => 'terminus'
    }.freeze

    def initialize(options = {})
      h
      @steps = []
      require 'pry'
      require 'capybara/dsl'

      setup_pry
      setup_capybara(options)
      info "Controling #{url} using the #{driver} driver"
    end

    def self.start
      new.pry
    end

    def h; puts manual end
    def commands; puts Capybara::DSL.instance_methods.sort end

    def url(url = nil) 
      return Capybara.app_host unless url

      unless url =~ /^http.*$/
        warn "#{url} is not a valid URL"
      else
        Capybara.app_host = url
      end
    end

    def drivers; DRIVERS.select { |d| available_driver?(d) } end
    def driver(driver = nil)
      return Capybara.current_driver unless driver

      if available_driver?(driver)
        self.send("load_#{driver}_driver")
        true
      else
        warning "#{driver} is not a valid driver, please select one of #{DRIVERS.inspect}"
        false
      end
    end

    def snap(path = nil)
      path ||= default_snapshot_path 

      case driver
      when :selenium_firefox, :selenium_chrome
        page.driver.browser.save_screenshot path
      when :webkit
        page.driver.render path
      when :poltergeist
        page.driver.render(path, :full => true)
      when :mechanize, :terminus
        warn "Screenshot functionality is not available with the #{driver} driver"
      end
    end

    def exec(path)
      unless File.exists?(path) 
        warning "File #{path} cannot be found"
      else
        source_capybara_script(path)
      end
    end

    # TODO: load file or directory
    def cuke(path)
      step_definitions = find_step_definitions(path)
      if step_definitions.empty?
        warning "No step definitions found at #{path}/step_definitions"
      else
        load_feature_steps(step_definitions)
      end
    end

    def steps
      if @steps.empty?
        warning "No steps defined, please load a definition file using the 'cuke' command"
      else
        @steps.inject(nil) { |_,s| puts s.regexp_source }
      end
    end

    def given(name, *args)
      unless m = @cucumber.step_match(name)
        warning "No steps matched, you can check what steps are loaded by running the 'steps' command"
      else
        s = m.step_definition
        p = s.instance_variable_get('@proc').curry(*args)
        instance_eval &p
      end
    end

    def all(&block)
      unless Capybara.current_driver == :terminus
        warning "The 'all' command only works with the :terminus driver, please switch using the 'driver' command"
      else
        Terminus.browsers.inject(nil) { |_,b| run_in_browser(b, &block) }
      end
    end

private

# capybara

    def setup_capybara(options = {})
      self.class.send(:include, Capybara::DSL)
      Capybara.server_boot_timeout = 20
      Capybara.app_host = "http://www.google.com"

      # rename default driver
      Capybara.register_driver :selenium_firefox do
        Capybara::Selenium::Driver.new(url, :browser => :firefox)
      end

      # add chrome selenium driver
      Capybara.register_driver :selenium_chrome do
        Capybara::Selenium::Driver.new(url, :browser => :chrome)
      end

      load_selenium_firefox_driver
    end

    def source_capybara_script(path)
      self.instance_eval File.read(path)
    end

# drivers
    
    def available_driver?(driver)
      case driver.to_sym
      when *BUILTIN_DRIVERS
        true
      when *OPTIONAL_DRIVERS
        Gem::Specification.find_by_name(driver.to_s)
      end
    rescue Gem::LoadError
      false
    end

    def default_snapshot_path
      count = 0
      while true do
        path = "#{ENV['HOME']}/Desktop/screenshot#{count}.jpg"
        return path unless File.exists?(path)
        count += 1
      end 
    end

    def load_selenium_firefox_driver
      Capybara.current_driver = :selenium_firefox
    end

    def load_selenium_chrome_driver
      Capybara.current_driver = :selenium_chrome
    end
    
    def load_terminus_driver
      require 'terminus'
      info "Starting Terminus (this may take a while)..."
      Capybara.current_driver = :terminus
      Terminus.start_browser(port: 7000)
      info "Terminus started, please dock your browser at http://localhost:#{Terminus.port}"
    end

    def load_webkit_driver
      require 'capybara/webkit'
      Capybara.current_driver = :webkit
    end

    def load_poltergeist_driver
      require 'capybara/poltergeist'
      Capybara.current_driver = :poltergeist
    end

    def load_mechanize_driver
      require 'capybara/mechanize'
      Capybara.current_driver = :mechanize
    end

# terminus

    def run_in_browser(browser)
      old_browser = Terminus.browser
      Terminus.browser = browser
      yield
    ensure
      Terminus.browser = old_browser
    end

# cucumber

    def load_feature_steps(step_definitions)
      require 'cucumber'
      @cucumber = Cucumber::Runtime::SupportCode.new(nil)
      @cucumber.load_files!(step_definitions)
      @steps = @cucumber.step_definitions
    end

    def find_step_definitions(path)
      return [] unless File.exists?(path)

      require 'find'
      steps = []
      Find.find(path) { |path| steps << path if path =~ /\/features\// && path =~ /^.+\.rb$/ }
      steps
    end

# pry

    def setup_pry
      Pry.prompt = proc { |obj, nest_level| "[#{nest_level}] >> "  }
    end

# other

    def manual
    %Q(

      8""""8                                              
      8    " eeeee eeeee e    e eeeee  eeeee eeeee  eeeee 
      8e     8   8 8   8 8    8 8   8  8   8 8   8  8   8 
      88     8eee8 8eee8 8eeee8 8eee8e 8eee8 8eee8e 8eee8 
      88   e 88  8 88      88   88   8 88  8 88   8 88  8 
      88eee8 88  8 88      88   88eee8 88  8 88   8 88  8 
      

      Welcome to the Capybara REPL

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
      )
    end

    MESSAGE_TYPES = [:error, :info, :warning]
    MESSAGE_TYPES.each do |m|
      define_method m do |message|
        message(m, message)
      end
    end

    def message(type, message)
      puts "#{type.to_s.upcase.ljust 7} => #{message}"
    end

end
