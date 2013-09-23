class iptables::rules::multicast (
  $chains = [ 'INPUT' ],
  $target = $iptables::default_target,
  $order  = 7500
) {

  each($chains) |$chain| {
    iptables::rule { "example42-multicast-filter-${chain}":
      table         => 'filter',
      chain         => $chain,
      rule          => '-m pkttype --pkt-type multicast',
      target        => $target,
      order         => $order,
    }
  }

}
