class iptables::rules::related_established (
  $chains          = [ 'INPUT', 'OUTPUT', 'FORWARD' ],
  $target          = $iptables::default_target,
  $protocol        = '',
  $order           = 9000,
  $log             = false,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {

  each($chains) |$chain| {
    iptables::rule { "example42-established-filter-${chain}":
      table           => 'filter',
      chain           => $chain,
      protocol        => $protocol,
      explicit_matches => { 'state' => { 'state' => 'RELATED,ESTABLISHED'} },
      target          => $target,
      order           => $order,
      log             => $log,
      log_prefix      => $log_prefix,
      log_limit_burst => $log_limit_burst,
      log_limit       => $log_limit,
      log_level       => $log_level
    }
  }

}
