
module Puppet::Parser::Functions
  newfunction(:iptables_nslookup, :type => :rvalue, :doc => <<-EOS
Lookup a hostname and return its ip addresses
    EOS
  ) do |vals|
    hostname, type = vals
    
    require 'ipaddr'

    raise(ArgumentError, 'Must specify a hostname') unless hostname
    type = 'AAAA' unless type

    typeConst = Resolv::DNS::Resource::IN.const_get "#{type.upcase}"
    out = []
    
    Resolv::DNS.open do |dns|
      dns.getresources(hostname, typeConst).collect {|r| 
        out << IPAddr::new_ntoh(r.address.address).to_s
      }
    end

    return out
  end
end
