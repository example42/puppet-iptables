class iptables::rules::general {

  if 'lo' in $::interfaces {
    iptables::rule { "example42-general-filter-input-loopback":
      table         => 'filter',
      chain         => 'INPUT',
      target        => 'ACCEPT',
      in_interface  => 'lo',
      order         => 9900,
    }

    iptables::rule { "example42-general-filter-output-loopback":
      table         => 'filter',
      chain         => 'OUTPUT',
      target        => 'ACCEPT',
      out_interface => 'lo',
      order         => 9900,
    }
  }

}
