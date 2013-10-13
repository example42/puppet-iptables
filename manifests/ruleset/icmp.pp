# [*chains*]
#  The chains to apply this ruleset against
#
# [*target*]
#  What to do with packets that match the ruleset.
#  This functionality is meant to prevent a DDOS, do not make this
#
# [*order*]
#  The order 8500 was chosen as default
#
# [*limit*]
#  Limit the number of ICMP packets that are matched, allows to prevent SMURF
#  attacks. You should consider using this directive to prevent a SMURF-attack
#  (hence the default of '1/s')
#
# [*limit_burst*]
#  Limit the number of ICMP packets that are matched only once $limit_burst
#  was reached.
#
# [*icmp_type_v4*]
#   Only match against a specific ICMP type (IPv4). E.g. 'ping'
#
# [*icmp_type_v6*]
#   Only match against a specific ICMP type (IPv6). E.g. 'ping'
#
# [*drop_addr_mask_request_v4*]
#   Bool. To drop all ICMPv4 Address Mask Requests
#
# [*drop_addr_mask_request_v6*]
#   Bool. To drop all ICMPv6 Address Mask Requests
#
# [*log*]
#  Log packets captured by this ruleset
#
# [*log_prefix*]
#   Prefix for all log lines
#
# [*log_limit_burst*]
#   The Iptables limit-burst directive used for logging
#
# [*log_limit*]
#   The limit directive of Iptables to limit logging
#
# [*log_level*]
#   The Iptables log-level directive
#
class iptables::ruleset::icmp (
  $chains                    = [ 'INPUT', 'OUTPUT', 'FORWARD' ],
  $target                    = $iptables::default_target,
  $order                     = 8500,
  $limit                     = '5/s',
  $limit_burst               = 5,
  $icmp_type_v4              = '',
  $icmp_type_v6              = '',
  $drop_addr_mask_request_v4 = true,
  $drop_timestamp_request_v4 = true,
  $log                       = false,
  $log_prefix                = $iptables::log_prefix,
  $log_limit_burst           = $iptables::log_limit_burst,
  $log_limit                 = $iptables::log_limit,
  $log_level                 = $iptables::log_level,
) {

  $explicit_matches_limit = { 'limit'      => $limit,
                              'limit-burst' => $limit_burst }
  $explicit_matches_type_v4 = { 'icmp-type' => $icmp_type_v4 }
  $explicit_matches_type_v6 = { 'icmpv6-type' => $icmp_type_v6 }

  $explicit_matches = {}
  if $limit != '' {
    $discard_1 = inline_template('<% @explicit_matches["limit"] = @explicit_matches_limit %>')
  }

  if $icmp_type_v4 != '' {
    $discard_2 = inline_template('<% @explicit_matches["icmp_v4"] = @explicit_matches_type_v4 %>')
  }

  if $icmp_type_v6 != '' {
    $discard_3 = inline_template('<% @explicit_matches["icmpv6_v6"] = @explicit_matches_type_v6 %>')
  }

  $discard = iptables_declare_multiple('iptables::rule', $chains, 'example42-icmp-filter-###name###', {
    table            => 'filter',
    chain            => '###name###',
    implicit_matches => { 'protocol_v4' => 'ICMP', 'protocol_v6' => 'IPv6-ICMP' },
    explicit_matches => $explicit_matches,
    target           => $target,
    order            => $order,
    log              => $log,
    log_prefix       => $log_prefix,
    log_limit_burst  => $log_limit_burst,
    log_limit        => $log_limit,
    log_level        => $log_level
  })


  if $drop_addr_mask_request_v4 {
    $discard_2 = iptables_declare_multiple('iptables::rule', $chains,
                                           'example42-icmp-filter-###name###-addr-mask-req', {
      table            => 'filter',
      chain            => '###name###',
      implicit_matches => { 'protocol_v4' => 'ICMP' },
      explicit_matches => {'icmp_v4'   => { 'icmp-type'   => 'address-mask-request' } },
      target           => 'DROP',
      order            => $order - 1,
      log              => $log,
      log_prefix       => $log_prefix,
      log_limit_burst  => $log_limit_burst,
      log_limit        => $log_limit,
      log_level        => $log_level,
      enable_v6        => false,
    })
  }

  if $drop_timestamp_request_v4 {
    $discard_3 = iptables_declare_multiple('iptables::rule', $chains,
                                           'example42-icmp-filter-###name###-timestamp-req', {
      table            => 'filter',
      chain            => '###name###',
      implicit_matches => { 'protocol_v4' => 'ICMP', },
      explicit_matches => { 'icmp_v4' => { 'icmp-type'   => 'timestamp-request' } },
      target           => 'DROP',
      order            => $order - 1,
      log              => $log,
      log_prefix       => $log_prefix,
      log_limit_burst  => $log_limit_burst,
      log_limit        => $log_limit,
      log_level        => $log_level,
      enable_v6        => false,
    })
  }

}
