class iptables::ruleset::invalid (
  $chains          = [ 'INPUT', 'FORWARD', 'OUTPUT' ],
  $target          = 'DROP',
  $order           = 250,
  $log             = true,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {

  each($chains) |$chain| {
    iptables::rule { "example42-invalid-filter-${chain}":
      table            => 'filter',
      chain            => $chain,
      explicit_matches => { 'state' => { 'state' => 'INVALID' }},
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
