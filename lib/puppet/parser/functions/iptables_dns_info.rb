
module Puppet::Parser::Functions
  newfunction(:iptables_dns_info, :type => :rvalue, :doc => <<-EOS
Lookup a hostname (both IPv4 and IPv6) and return its ip addresses
    EOS
  ) do |vals|
    hostname = vals[0]
    raise(ArgumentError, 'Must specify a hostname') unless hostname
    
    Puppet::Parser::Functions.function(:iptables_nslookup)
    
    out = {
      'ip_v4' => function_iptables_nslookup([ hostname, 'A'   ]),
      'ip_v6' => function_iptables_nslookup([ hostname, 'AAAA'])
    }
    
    out['enable_v4'] = out['ip_v4'].length > 0
    out['enable_v6'] = out['ip_v6'].length > 0

    return out
  end
end
