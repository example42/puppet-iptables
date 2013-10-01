
module Puppet::Parser::Functions
  newfunction(:iptables_construct_explicit_matches, :type => :rvalue, :doc => <<-EOS
Construct the Explicit Matches hash map for the Iptables module
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "iptables_construct_explicit_matches(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 2

    # Todo: Check the type of input arg
    explicit_matches = arguments[0]
    is_ipv6 = arguments[1]

    active_version   = is_ipv6 ? '6' : '4'
    unactive_version = is_ipv6 ? '4' : '6'
    explicit_matches_str = ""

    explicit_matches.each do |m, params|
      explicit_matches_str << "-m #{m} "
      params.each do |k, v|

        if k == 'invert' or k[-3, 3] == "_v#{unactive_version}" or ! explicit_matches[m]["#{k}_v#{active_version}"].nil? or k[-3, 3] == '_v#{unactive_version}'
          next
        elsif k[-3, 3] == "_v#{active_version}"
          k = k[0..-4]
        end

        invert = ''
        if ! explicit_matches[m]['invert'].nil? and implicit_matches[m]['invert'].include?(k)
          invert = '!'
        end

        explicit_matches_str << "--#{k} #{invert} #{v} "
      end
    end

    return explicit_matches_str
  end
end
