
module Puppet::Parser::Functions
  newfunction(:iptables_declare_multiple, :type => :rvalue, :doc => <<-EOS
Loop over a hash and define multiple resources based on it.
    EOS
  ) do |vals|
    type, names, name_tpl, params = vals
    raise(ArgumentError, 'Must specify a set of names') unless names
    raise(ArgumentError, 'Must specify a type') unless type
    raise(ArgumentError, 'Must specify a name_tpl') unless name_tpl
    raise(ArgumentError, 'Must specify a params') unless params

    names.each do |name_inner|
      Puppet::Parser::Functions.function(:create_resources)
      
      use_name = name_tpl.gsub(/\#\#\#name\#\#\#/, name_inner)
      
      # Creating a new hash in place, using this syntax we can support ruby 1.8
      params_inner = Hash[ *params.map{ |key,value| 
        value.is_a?(String) ? [key, value.gsub(/\#\#\#name\#\#\#/, name_inner) ] : [ key, value ]
      }.flatten ]
  
      function_create_resources(
        [type.capitalize, { name_tpl.gsub(/\#\#\#name\#\#\#/, name_inner).capitalize => params_inner }]
      )
    end
    
  end
end