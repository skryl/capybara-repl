# This is a simplified interface for generating random data using the Faker gem.
# It allows easier access to faker methods through method_missing. Including
# this module will give access to all faker methods without having to namespace
# anything. In case of conflicts, the method can be namespaced by prefixing it
# with the downcased faker module name. 

# Example
#
# class MyClass
#   include NConjure::FakerDSL
#   def person
#     { first_name: first_name,     # calls Faker::Name.first_name
#       company:    company_name }  # calls Faker::Company.name
#   end
# end
#
# To list the existing generators provided by Faker (see https://github.com/EmmanuelOga/ffaker)
#
# MyClass.faker_methods
#
class CapybaraRepl
  module FakerDSL
    FAKER_MODS = [:Name, :AddressUS, :Company, :Education, :Internet, :Job, :Lorem, :Name, :PhoneNumber]

    module FakerProxy
      extend Faker::ModuleUtils
      FAKER_MODS.each { |m| extend Faker.const_get(m) }
    end

    def faker_methods
      FakerProxy.singleton_methods
    end

    def method_missing(method, *args, &block)
      method =~ /^(.*)_(.*)$/
      if faker_module?($1) && faker_module_method?($1, $2)
        constantize("Faker::#{$1}").send($2)
      elsif faker_method?(method)
        FakerProxy.send(method)
      else super 
      end
    end

private

    def faker_module?(name)
      FAKER_MODS.include?(classify(name).to_sym)
    end

    def faker_method?(method)
      FakerProxy.respond_to?(method)
    end

    def faker_module_method?(mod, method)
      faker_mod = constantize("Faker::#{mod}")
      faker_mod.respond_to?(method)
    end

    def classify(name)
      name.to_s.split('_').map(&:capitalize).join
    end

    def constantize(name)
      namespaces = name.to_s.split('::')
      namespaces.inject(Object) { |c, n| c.const_get(n.capitalize) }
    end

  end
end
