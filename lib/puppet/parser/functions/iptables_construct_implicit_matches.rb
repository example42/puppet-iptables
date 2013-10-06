
module Puppet::Parser::Functions
  newfunction(:iptables_construct_implicit_matches, :type => :rvalue, :doc => <<-EOS
Construct the Implicit Matches hash map for the Iptables module
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "iptables_construct_implicit_matches(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 2

    # Todo: Check the type of input arg
    implicit_matches = arguments[0]
    is_ipv6 = arguments[1]

    active_version   = is_ipv6 ? '6' : '4'
    unactive_version = is_ipv6 ? '4' : '6'
    implicit_matches_str = ""

    implicit_matches.sort.each do |k, v|
      if k == 'invert' or k[-3, 3] == "_v#{unactive_version}" or ! implicit_matches["#{k}_v#{active_version}"].nil? or k[-3, 3] == '_v#{unactive_version}'
        next
      elsif k[-3, 3] == "_v#{active_version}"
        k = k[0..-4]
      end

      invert = ''
      if ! implicit_matches['invert'].nil? and implicit_matches['invert'].include?(k)
        invert = '!'
      end

      # Ensure protocol is always first.
      # See https://github.com/example42/puppet-iptables/issues/35
      prepend_items = [ 'protocol', 'protocol_v4', 'protocol_v6', 'p', 'p_v4', 'p_v6' ]
      if prepend_items.include?(k)
        if k.length == 1
          implicit_matches_str = "-#{k} #{invert} #{v} " + implicit_matches_str
        else
          implicit_matches_str = "--#{k} #{invert} #{v} " + implicit_matches_str
        end       
      else
    
        if k.length == 1
          implicit_matches_str << "-#{k} #{invert} #{v} "
        else
          implicit_matches_str << "--#{k} #{invert} #{v} "
        end
      end
    end

    return implicit_matches_str
  end
end
