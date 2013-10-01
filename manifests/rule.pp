# Define: iptables::rule
#
# Adds a custom iptables rule
# Supported arguments:
# $command        - The iptables command to issue (default -A)
# $table          - The iptables table to work on (default filter)
# $chain          - The iptables chain to work on (default INPUT).
#                   Write it UPPERCASE coherently with iptables syntax
# $in_interface   - The inbound interface for the rule
# $out_interface  - The outbound interface for the rule
# $target         - The iptables target for the rule (default ACCEPT)
# $source         - The packets source address (in iptables -s supported
#                   syntax, default 0/0)
# $source_v6      - The packets IPv6 source address
# $destination    - The packets destination (in iptables -d supported
#                   syntax, default 0/0)
# $destination_v6 - The packets IPv6 destination
# $protocol       - The transport protocol (tcp/udp, default tcp)
# $port           - The DESTINATION port
# $order          - The CONCAT order where to place your rule.
#                   By default this is automatically calculated if you want to
#                   set it be sure of what you're doing and check
#                   iptables::concat to see current order numbers in order to
#                   avoid building a wrong iptables rule file
# $rule           - A custom iptables rule (in whatever iptables supported
#                   format). Use this as an alternative to the use of the
#                   above $protocol, $port, $source and $destination parameters.
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
  $command          = '-A',
  $table            = 'filter',
  $chain            = 'INPUT',
  $target           = $iptables::default_target,
  $implicit_matches = {'invert' => {}},
  $explicit_matches = {},
  $target_options   = {},
  $in_interface     = '',
  $out_interface    = '',
  $source           = '',
  $source_v6        = '',
  $destination      = '',
  $destination_v6   = '',
  $protocol         = '',
  $port             = '',
  $rule             = '',
  $order            = $iptables::default_order,
  $log              = false,
  $log_prefix       = $iptables::log_prefix,
  $log_limit_burst  = $iptables::log_limit_burst,
  $log_limit        = $iptables::log_limit,
  $log_level        = $iptables::log_level,
  $enable           = true,
  $enable_v4        = $iptables::bool_enable_v4,
  $enable_v6        = $iptables::bool_enable_v6,
  $debug            = false
) {

  include iptables
  include concat::setup

  $bool_enable_v4 = any2bool($enable_v4)
  $bool_enable_v6 = any2bool($enable_v6)
  $ensure         = bool2ensure($enable)

  # The concat module may not support natural sorting,
  # so we make sure it's all at least 4 digits
  $true_order = $order ? {
    ''      => inline_template("<%= scope.lookupvar('iptables::default_order').to_s.rjust(4, '0') %>"),
    default => inline_template("<%= @order.to_s.rjust(4, '0') %>")
  }

  if $in_interface != '' {
    $discard_1= inline_template('<% @implicit_matches["in-interface"] = @in_interface %>')
  }

  if $out_interface != '' {
    $discard_2 = inline_template('<% @implicit_matches["out-interface"] = @out_interface %>')
  }

  if $protocol != '' {
    $discard_3 = inline_template('<% @implicit_matches["protocol"] = @protocol %>')
  }

  if $port != '' {
    $discard_4 = inline_template('<% @implicit_matches["destination-port"] = @port %>')
  }

  if $debug {
    iptables::debug{ "debug params $name":
      true_port            => $true_port,
      true_protocol        => $true_protocol,
      array_source_v6      => $array_source_v6,
      array_destination_v6 => $array_destination_v6,
      array_source         => $array_source,
      array_destination    => $array_destination,
    }
  }

  if $log {

    $log_explicit_matches = $explicit_matches + {'limit' => {'limit-burst' => $log_limit_burst } }

    iptables::rule { "${name}-10":
      command          => $command,
      table            => $table,
      chain            => $chain,
      target           => 'LOG',
      implicit_matches => $implicit_matches,
      explicit_matches => $log_explicit_matches,
      source           => $source,
      source_v6        => $source_v6,
      destination      => $destination,
      destination_v6   => $destination_v6,
      order            => $true_order,
      log              => false,
      target_options   => { 'log-level'     => $log_level,
                            'log-prefix'    => $log_prefix },
      enable           => $enable,
      enable_v4        => $enable_v4,
      enable_v6        => $enable_v6,
      debug            => $debug
    }
  }

  if $bool_enable_v4 {

    if $target == $iptables::reject_string_v6 {
      $target_v4 = $iptables::reject_string_v4
    } else {
      $target_v4 = $target
    }

    $source_x_destination_v4 = iptables_cartesian_product($source, $destination)
    $source_x_destination_v4.each |$src_dst| {

      $implicit_matches_rule = $implicit_matches

      if $src_dst[0] != '' {
        $discard_6 = inline_template('<% @implicit_matches_rule["source_v4"] = @src_dst[0] %>')
      }

      if $src_dst[1] != '' {
        $discard_7 = inline_template('<% @implicit_matches_rule["destination_v4"] = @src_dst[1] %>')
      }

      # We use the hash of $content to ensure the rules will always be ordered the same
      $is_ipv6 = false
      $content = template('iptables/rule.erb')
      $hash = inline_template('<%= Digest::SHA1.hexdigest(@content) %>')
      concat::fragment{ "iptables_rule_v4_${name}-20-${hash}":
        target  => "/var/lib/puppet/iptables/tables/v4_${table}",
        content => $content,
        order   => $true_order,
        ensure  => $ensure,
        notify  => Service['iptables'],
      }
    }

  }

  if $bool_enable_v6 {

    if $target == $iptables::reject_string_v4 {
      $target_v6 = $iptables::reject_string_v6
    } else {
      $target_v6 = $target
    }

    $source_x_destination_v6 = iptables_cartesian_product($source_v6, $destination_v6)
    $source_x_destination_v6.each |$src_dst| {

      $implicit_matches_rule = $implicit_matches

      if $src_dst[0] != '' {
        $discard_8 = inline_template('<% @implicit_matches_rule["source_v6"] = @src_dst[0] %>')
      }

      if $src_dst[1] != '' {
        $discard_9 = inline_template('<% @implicit_matches_rule["destination_v6"] = @src_dst[1] %>')
      }

      # We use the hash of $content to ensure the rules will always be ordered the same
      $is_ipv6 = true
      $content = template('iptables/rule.erb')
      $hash = inline_template('<%= Digest::SHA1.hexdigest(@content) %>')
      concat::fragment{ "iptables_rule_v6_${name}-20-${hash}":
        target  => "/var/lib/puppet/iptables/tables/v6_${table}",
        content => $content,
        order   => $true_order,
        ensure  => $ensure,
        notify  => Service['iptables'],
      }
    }

  }

}
