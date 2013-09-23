class iptables::rules::broadcast (
  $chains = [ 'INPUT' ],
  $target = $iptables::default_target,
  $order  = 7500
) {

  each($chains) |$chain| {
    iptables::rule { "example42-broadcast-filter-${chain}":
      table         => 'filter',
      chain         => $chain,
      rule          => '-m pkttype --pkt-type broadcast',
      target        => $target,
      order         => $order,
    }
  }

}
