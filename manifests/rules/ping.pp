class iptables::rules::ping (
  $chains          = [ 'INPUT', 'OUTPUT', 'FORWARD' ],
  $target          = $iptables::default_target,
  $order           = 8250,
  $log             = false,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {

  each($chains) |$chain| {
    iptables::rule { "example42-ping-filter-${chain}":
      table            => 'filter',
      chain            => $chain,
      implicit_matches => { 'protocol_v4' => 'ICMP', 'protocol_v6' => 'ICMPv6' },
      explicit_matches => { 'icmp' => { 'icmp-type' => 8 } },
      target           => $target,
      order            => $order,
      log              => $log,
      log_prefix       => $log_prefix,
      log_limit_burst  => $log_limit_burst,
      log_limit        => $log_limit,
      log_level        => $log_level      
    }
  }

}
