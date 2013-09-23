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

  if $iptables::real_safe_ssh {
    iptables::rule { "example42-general-filter-input-ssh":
      table         => 'filter',
      chain         => 'INPUT',
      target        => 'ACCEPT',
      port          => '22',
      protocol      => 'tcp',
      order         => 10,
    }    
  }
  
}
