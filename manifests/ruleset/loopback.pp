class iptables::ruleset::loopback(
  $log             = false,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {

  if 'lo' in $::interfaces {
    iptables::rule { "example42-general-filter-input-loopback":
      table           => 'filter',
      chain           => 'INPUT',
      target          => 'ACCEPT',
      in_interface    => 'lo',
      order           => 9900,
      log             => $log,
      log_prefix      => $log_prefix,
      log_limit_burst => $log_limit_burst,
      log_limit       => $log_limit,
      log_level       => $log_level
    }

    iptables::rule { "example42-general-filter-output-loopback":
      table           => 'filter',
      chain           => 'OUTPUT',
      target          => 'ACCEPT',
      out_interface   => 'lo',
      order           => 9900,
      log             => $log,
      log_prefix      => $log_prefix,
      log_limit_burst => $log_limit_burst,
      log_limit       => $log_limit,
      log_level       => $log_level
    }
  }

}
