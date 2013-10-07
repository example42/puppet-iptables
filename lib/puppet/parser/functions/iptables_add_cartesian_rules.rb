
module Puppet::Parser::Functions
  newfunction(:iptables_add_cartesian_rules, :type => :rvalue, :doc => <<-EOS
Add rules from a cartesian product
    EOS
  ) do |vals|
    name, cartesian_product, implicit_matches, explicit_matches, \
       ip_version, order, var_ensure, table, command, chain, target, \
       target_options, rule = vals.clone
    raise(ArgumentError, 'Must specify a cartesian product') unless cartesian_product
    raise(ArgumentError, 'Must specify a implicit_matches') unless implicit_matches
    raise(ArgumentError, 'Must specify a ip_version') unless ip_version
    raise(ArgumentError, 'Must specify a order') unless order
    raise(ArgumentError, 'Must specify a ensure') unless var_ensure
    raise(ArgumentError, 'Must specify a table') unless table

    Puppet::Parser::Functions.function(:create_resources)
    rules = {}

    cartesian_product.each do |src_dst|

      implicit_matches_rule = implicit_matches.clone

      if src_dst[0] != ''
        implicit_matches_rule["source_v#{ip_version}"] = src_dst[0]
      end

      if src_dst[1] != ''
        implicit_matches_rule["destination_v#{ip_version}"] = src_dst[1]
      end

      implicit_matches_str = function_iptables_construct_implicit_matches([
        implicit_matches_rule, ip_version == "6"
      ])

      explicit_matches_str = function_iptables_construct_explicit_matches([
        explicit_matches, ip_version == "6"
      ])

      target_options_str   = target_options.map{|k, v| "--#{k} \"#{v}\""}.join(' ')

      if rule != ''
        line = "#{command} #{chain} #{rule} -j #{target}\n"
      else
        line = [ command, chain, implicit_matches_str, explicit_matches_str,
                 '-j', target, target_options_str
        ].join(" ").gsub(/\s+/, ' ') + "\n"
      end

      hash = Digest::SHA1.hexdigest(line)
      rules["iptables_rule_v#{ip_version}_#{name}-20-#{hash}"] = {
        'target' => "/var/lib/puppet/iptables/tables/v#{ip_version}_#{table}",
        'content'=> line,
        'order'  => order,
        'ensure' => var_ensure
      }

    end

    function_create_resources([ 'concat::fragment', rules ])

  end
end