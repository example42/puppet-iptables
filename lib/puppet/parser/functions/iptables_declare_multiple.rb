
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

      params_inner = {}
      params.each { |k, v|
        params_inner[k] = v.is_a?(String) ? v.gsub(/\#\#\#name\#\#\#/, name_inner) : v
      }

      function_create_resources(
        [type.capitalize, { name_tpl.gsub(/\#\#\#name\#\#\#/, name_inner).capitalize => params_inner }]
      )
    end

  end
end
