class iptables::rules::related_established (
  $chains = [ 'INPUT', 'OUTPUT', 'FORWARD' ],
  $target = $iptables::default_target,
  $protocol = 'ALL',
  $order  = 7500
) {

  each($chains) |$chain| {
    iptables::rule { "example42-established-filter-${chain}":
      table         => 'filter',
      chain         => $chain,
      protocol      => $protocol,
      rule          => '-m state --state RELATED,ESTABLISHED',
      target        => $target,
      order         => $order,
    }
  }

}
