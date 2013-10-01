
module Puppet::Parser::Functions
  newfunction(:iptables_cartesian_product, :type => :rvalue, :doc => <<-EOS
Return the cartesian product of the given parameters
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "iptables_construct_implicit_matches(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 2

    # Todo: Check the type of input arg
    # Todo: This could be made to accept > 2 arguments?

    use_values = []
    arguments.each { |arg|
      use_values.push << (arg.is_a?(Array) ? arg : [ arg ])
    }

    return use_values[0].product(use_values[1])
  end
end

#
#    return (arguments[0].is_a?(Array) ? arguments[0] : [ arguments[0] ])
#            .product((arguments[1].is_a?(Array) ? arguments[1] : [ arguments[1] ]))
