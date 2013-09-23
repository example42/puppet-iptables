class iptables::rules::ping (
  $chains = [ 'INPUT', 'OUTPUT', 'FORWARD' ],
  $target = $iptables::default_target,
  $order  = 7500
) {

  each($chains) |$chain| {
    iptables::rule { "example42-ping-filter-${chain}":
      table         => 'filter',
      chain         => $chain,
      rule          => '-p icmp -m icmp --icmp-type 8',
      target        => $target,
      order         => $order,
    }
  }

}
