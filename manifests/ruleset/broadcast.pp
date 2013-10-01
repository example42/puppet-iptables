class iptables::ruleset::broadcast (
  $chains          = [ 'INPUT' ],
  $target          = $iptables::default_target,
  $order           = 7500,
  $log             = false,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {

  each($chains) |$chain| {
    iptables::rule { "example42-broadcast-filter-${chain}":
      table           => 'filter',
      chain           => $chain,
      explicit_matches => { 'pkttype' => {'pkt-type' => 'broadcast'}},
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
