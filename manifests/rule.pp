# Define: iptables::rule
#
# Adds a custom iptables rule
# Supported arguments:
# $command - The iptables command to issue (default -A)
# $table - The iptables table to work on (default filter)
# $chain - The iptables chain to work on (default INPUT). Write it UPPERCASE
#      coherently with iptables syntax
# $target - The iptables target for the rule (default ACCEPT)
# $source - The packets source address (in iptables -s supported syntax, default 0/0)
# $source_v6 - The packets IPv6 source address
# $destination - The packets destination (in iptables -d supported syntax, default 0/0)
# $destination_v6 - The packets IPv6 destination
# $protocol - The transport protocol (tcp/udp, default tcp)
# $port - The DESTINATION port
# $order - The CONCAT order where to place your rule. By default this is automatically calculated
#      if you want to set it be sure of what you're doing and check iptables::concat to see
#      current order numbers in order to avoid building a wrong iptables rule file
# $rule - A custom iptables rule (in whatever iptables supported format). Use this as an alternative to
#     the use of the above $protocol, $port, $source and $destination parameters.
#
# Note that s single call to iptables::rule creates a rule with the following content:
# $command $chain $true_rule -j $target     in the $table you define.
# Note that $true_rule is built in this way:
# - If $rule is defined, $true_rule == $rule
# - If not, $true_rule is "-p $protocol --dport $port -s $source -d $destination"
# $enable - 
# $enable_v6 - enables the IPv6 part. Default is false for compatibility reasons. 
#
define iptables::rule (
  $command        = '-A',
  $table          = 'filter',
  $chain          = 'INPUT',
  $target         = 'ACCEPT',
  $source         = '0/0',
  $source_v6      = '',
  $destination    = '0/0',
  $destination_v6 = '',
  $protocol       = 'tcp',
  $port           = '',
  $order          = '',
  $rule           = '',
  $enable         = true,
  $enable_v6      = false ) {

  include iptables
  include concat::setup

  # If (concat) order is not defined we find out the right one
  $true_order = $order ? {
    ''    => $table ? {
      'filter' => $chain ? {
         'INPUT'   => '15',
         'OUTPUT'  => '25',
         'FORWARD' => '35',
      },
      'nat'    => '50',
      'mangle' => '60',
    },
    default => $order,
  }

  # We build the rule if not explicitely set
  $true_protocol = $protocol ? {
    ''    => '',
    default => "-p ${protocol}",
  }

  $true_port = $port ? {
    ''    => '',
    default => "--dport ${port}",
  }

  $true_source = $source ? {
    ''    => '',
    default => "-s ${source}",
  }

  $true_destination = $destination ? {
    ''    => '',
    default => "-d ${destination}",
  }

  $true_rule = $rule ? {
     ''    => "${true_protocol} ${true_port} ${true_source} ${true_destination}",
     default => $rule,
  }

  $ensure = bool2ensure($enable)

  $array_source = is_array($source) ? {
    false     => $source ? {
      ''      => [],
      default => [$source],
    },
    default   => $source,
  }

  $array_destination = is_array($destination) ? {
    false     => $destination ? {
      ''      => '',
      default => [$destination],
    },
    default   => $destination,
  }
  
  $array_source_v6 = is_array($source_v6) ? {
    false     => $source_v6 ? {
      ''      => [],
      default => [$source_v6],
    },
    default   => $source_v6,
  }

  $array_destination_v6 = is_array($destination_v6) ? {
    false     => $destination_v6 ? {
      ''      => '',
      default => [$destination_v6],
    },
    default   => $destination_v6,
  }

  concat::fragment{ "iptables_rule_$name":
    target  => $iptables::config_file,
    content => template('iptables/concat/rule.erb'),
    order   => $true_order,
    ensure  => $ensure,
    notify  => Service['iptables'],
  }
  
  if $enable_v6 {
    concat::fragment{ "iptables_rule_v6_$name":
      target  => $iptables::config_file_v6,
      content => template('iptables/concat/rule_v6.erb'),
      order   => $true_order,
      ensure  => $ensure,
      notify  => Service['iptables'],
    }
  }
}
