class iptables::rules::invalid (
  $chains = [ 'INPUT', 'FORWARD', 'OUTPUT' ],
  $target = 'DROP',
  $order  = 100
) {

  each($chains) |$chain| {
    iptables::rule { "example42-invalid-filter-${chain}-LOG":
      table         => 'filter',
      chain         => $chain,
      rule          => '-m state --state INVALID',
      target        => 'LOGFORDROP',
      order         => $order,
    }
    
    iptables::rule { "example42-invalid-filter-${chain}":
      table         => 'filter',
      chain         => $chain,
      rule          => '-m state --state INVALID',
      target        => $target,
      order         => $order + 1,
    }
  }

}
