class iptables::rules::log (
  $log_type    = 'drop',
  $log_input   = '',
  $log_output  = '',
  $log_forward = '',
  $limit_burst = 10,
  $limit       = '30/m',
  $log_level   = 7,
) {

  $real_log_type = $log_type ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    default   => fail("Improper 'log_type' value given to iptables::rules::log: ${log_type}")
  }

  $real_log_output = $log_output ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    ''        => $real_log_type,
    default   => fail("Improper 'log_output' value given to iptables::rules::log: ${log_output}")
  }
  $real_log_input = $log_input ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    ''        => $real_log_type,
    default   => fail("Improper 'log_input' value given to iptables::rules::log: ${log_output}")
  }
  $real_log_forward = $log_forward ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    ''        => $real_log_type,
    default   => fail("Improper 'log_forward' value given to iptables::rules::log: ${log_forward}")
  }

  if $iptables::enable_v4 {
    iptables::chain { 'v4_filter_regularlog':
      table => 'filter',
      chain_name => [ 'REGULARLOG' ],
      ip_version => 4,
      action     => '-',
    }
  } else {
    iptables::chain { 'v6_filter_regularlog':
      table => 'filter',
      chain_name => [ 'REGULARLOG' ],
      ip_version => 6,
      action     => '-',
    }
  }
  
  if $iptables::enable_v4 {
    iptables::chain { 'v4_filter_logfordrop':
      table => 'filter',
      chain_name => [ 'LOGFORDROP' ],
      ip_version => 4,
      action     => '-',
    }
  } else {
    iptables::chain { 'v6_filter_logfordrop':
      table => 'filter',
      chain_name => [ 'LOGGANDDROP' ],
      ip_version => 6,
      action     => '-',
    }
  }
  
  if $iptables::enable_v4 {
    each(['TCP', 'UDP', 'ICMP']) |$protocol| {
      iptables::rule { "example42-log-logfordrop-log-v4-${protocol}":
        table     => 'filter',
        chain     => 'LOGFORDROP',
        rule      => "-p ${protocol} -m limit --limit ${limit}",
        target    => 'LOG',
        options   => {'log-prefix'  => "Iptables - Drop ${protocol}",
                     'limit-burst' => $limit_burst,
                     'log-level'   => $log_level },
        order     => 10,
        enable_v6 => false,
      }

      iptables::rule { "example42-log-logfordrop-drop-v4-${protocol}":
        table    => 'filter',
        chain    => 'LOGFORDROP',
        rule     => "-p ${protocol}",
        target   => 'RETURN',
        order    => 20,
        enable_v6 => false,
      }
    }
  }
 
  if $iptables::enable_v6 {
    each(['TCP', 'UDP', 'ICMPv6']) |$protocol| {
      iptables::rule { "example42-log-logfordrop-log-v6-${protocol}":
        table    => 'filter',
        chain    => 'LOGFORDROP',
        rule     => "-p ${protocol} -m limit --limit ${limit}",
        target   => 'LOG',
        options  => {'log-prefix'  => "Iptables - Drop ${protocol}",
                     'limit-burst' => $limit_burst,
                     'log-level'   => $log_level },
        order    => 10,
        enable_v4 => false,
      }
  
      iptables::rule { "example42-log-logfordrop-drop-v6-${protocol}":
        table    => 'filter',
        chain    => 'LOGFORDROP',
        rule     => "-p ${protocol}",
        target   => 'RETURN',
        order    => 20,
        enable_v4 => false,
      }
    }
  }
  
    
  iptables::rule { "example42-log-logfordrop-otherprotocol":
    table    => 'filter',
    chain    => 'LOGFORDROP',
    rule     => "-m limit --limit ${limit}",
    target   => 'LOG',
    options  => {'log-prefix'  => "Iptables - Drop unknown ",
                 'limit-burst' => $limit_burst,
                 'log-level'   => $log_level },
    order    => 30,
  }
  
  iptables::rule { "example42-log-logfordrop-drop-otherprotocol":
    table    => 'filter',
    chain    => 'LOGFORDROP',
    target   => 'DROP',
    order    => 40,
  }

  if $iptables::enable_v4 {
  
    each(['TCP', 'UDP', 'ICMP']) |$protocol| {
      iptables::rule { "example42-log-log-v4-${protocol}":
        table    => 'filter',
        chain    => 'REGULARLOG',
        rule     => "-p ${protocol} -m limit --limit ${limit}",
        target   => 'LOG',
        options  => {'log-prefix'  => "Iptables - Accept ${protocol}",
                     'limit-burst' => $limit_burst,
                     'log-level'   => $log_level },
        order    => 10,
        enable_v6 => false
      }
                     
      iptables::rule { "example42-log-log-return-v4-${protocol}":
        table    => 'filter',
        chain    => 'REGULARLOG',
        rule     => "-p ${protocol}",
        target   => 'RETURN',
        order    => 20,
        enable_v6 => false
      }
    }
  }
  
  if $iptables::enable_v6 {
    each(['TCP', 'UDP', 'ICMPv6']) |$protocol| {
    
      iptables::rule { "example42-log-log-v6-${protocol}":
        table    => 'filter',
        chain    => 'REGULARLOG',
        rule     => "-p ${protocol} -m limit --limit ${limit}",
        target   => 'LOG',
        options  => {'log-prefix'  => "Iptables Accept ${protocol}",
                     'limit-burst' => $limit_burst,
                     'log-level'   => $log_level },
        order    => 10,
        enable_v4 => false,
      }
                     
      iptables::rule { "example42-log-log-return-v6-${protocol}":
        table    => 'filter',
        chain    => 'REGULARLOG',
        rule     => "-p ${protocol}",
        target   => 'RETURN',
        order    => 20,
        enable_v4 => false,
      }
    }
  }

  iptables::rule { "example42-log-log-otherprotocol":
    table    => 'filter',
    chain    => 'REGULARLOG',
    rule     => "-m limit --limit ${limit}",
    target   => 'LOG',
    options  => {'log-prefix'  => "Iptables - Accept unknown ",
                 'limit-burst' => $limit_burst,
                 'log-level'   => $log_level },
    order    => 30,
  }

  iptables::rule { "example42-log-log-return-otherprotocol":
    table    => 'filter',
    chain    => 'REGULARLOG',
    target   => 'RETURN',
    order    => 40,
  }
}
