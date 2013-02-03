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
# $destination - The packets destination (in iptables -d supported syntax, default 0/0)
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
#
define iptables::rule (
  $command        = '-A',
  $table          = 'filter',
  $chain          = 'INPUT',
  $target         = 'ACCEPT',
  $source         = '0/0',
  $destination    = '0/0',
  $protocol       = 'tcp',
  $port           = '',
  $order          = '',
  $rule           = '',
  $enable         = true ) {

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


  concat::fragment{ "iptables_rule_$name":
    target  => $iptables::config_file,
    content => template('iptables/concat/rule.erb'),
#    content => "${command} ${chain} ${true_rule} -j ${target}\n",
    order   => $true_order,
    ensure  => $ensure,
    notify  => Service['iptables'],
  }

}
