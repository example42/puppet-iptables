#
module Puppet::Parser::Functions
  newfunction(:string2int, :type => :rvalue, :doc => <<-EOS
Converts a string to an integer.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "size(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    item = arguments[0]
    return item.to_i
  end
end

# vim: set ts=2 sw=2 et :
