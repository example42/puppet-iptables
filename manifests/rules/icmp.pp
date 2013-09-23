class iptables::rules::icmp (
  $chains = [ 'INPUT', 'OUTPUT', 'FORWARD' ],
  $target = $iptables::default_target,
  $order  = 7600
) {

  each($chains) |$chain| {
    iptables::rule { "example42-icmp-filter-${chain}":
      table         => 'filter',
      chain         => $chain,
      protocol      => 'ICMP',
      target        => $target,
      order         => $order,
    }
  }

}
