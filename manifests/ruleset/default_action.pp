
class iptables::ruleset::default_action (
  $output_policy  = 'accept',
  $input_policy   = 'reject',
  $forward_policy = 'reject',
  $log_type       = 'drop',
  $log_input      = '',
  $log_output     = '',
  $log_forward    = '',
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level
) {

  $real_output_policy = $output_policy ? {
    'drop'    => 'DROP',
    'DROP'    => 'DROP',
    'accept'  => 'ACCEPT',
    'ACCEPT'  => 'ACCEPT',
    'reject'  => $iptables::reject_string_v4,
    'REJECT'  => $iptables::reject_string_v4,
    default   => fail("Improper 'output_policy' value given to iptables: ${output_policy}")
  }

  $real_input_policy = $input_policy ? {
    'drop'    => 'DROP',
    'DROP'    => 'DROP',
    'accept'  => 'ACCEPT',
    'ACCEPT'  => 'ACCEPT',
    'reject'  => $iptables::reject_string_v4,
    'REJECT'  => $iptables::reject_string_v4,
    default   => fail("Improper 'input_policy' value given to iptables: ${input_policy}")
  }

  $real_forward_policy = $forward_policy ? {
    'drop'    => 'DROP',
    'DROP'    => 'DROP',
    'accept'  => 'ACCEPT',
    'ACCEPT'  => 'ACCEPT',
    'reject'  => $iptables::reject_string_v4,
    'REJECT'  => $iptables::reject_string_v4,
    default   => fail("Improper 'forward_policy' value given to iptables: ${forward_policy}")
  }

  $real_log_type = $log_type ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    'all'     => 'no',
    default   => fail("Improper 'log_type' value given to iptables::ruleset::log: ${log_type}")
  }

  $real_log_output = $log_output ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    'all'     => 'no',
    ''        => $real_log_type,
    default   => fail("Improper 'log_output' value given to iptables::ruleset::log: ${log_output}")
  }
  $real_log_input = $log_input ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    'all'     => 'no',
    ''        => $real_log_type,
    default   => fail("Improper 'log_input' value given to iptables::ruleset::log: ${log_input}")
  }
  $real_log_forward = $log_forward ? {
    'dropped' => 'drop',
    'drop'    => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    'all'     => 'no',
    ''        => $real_log_type,
    default   => fail("Improper 'log_forward' value given to iptables::ruleset::log: ${log_forward}")
  }

  #          'drop'    'no'    $real_log_output
  # 'drop'   true     false
  # 'accept' false    false
  # 'reject' true     false
  # $output_policy
  $bool_log_output = $real_log_output ? {
    'no'    => false,
    default => $real_output_policy ? {
      'ACCEPT' => false,
      default  => true
    }
  }

  $bool_log_input = $real_log_input ? {
    'no'    => false,
    default => $real_input_policy ? {
      'ACCEPT' => false,
      default  => true
    }
  }

  $bool_log_forward = $real_log_forward ? {
    'no'    => false,
    default => $real_forward_policy ? {
      'ACCEPT' => false,
      default  => true
    }
  }

  iptables::rule { "example42-rules-default_action-output":
    table           => 'filter',
    chain           => 'OUTPUT',
    target          => $real_output_policy,
    log             => $bool_log_output,
    order           => 9990,
    log_prefix      => $log_prefix,
    log_limit_burst => $log_limit_burst,
    log_limit       => $log_limit,
    log_level       => $log_level,
  }

  iptables::rule { "example42-rules-default_action-input":
    table           => 'filter',
    chain           => 'INPUT',
    target          => $real_input_policy,
    log             => $bool_log_input,
    order           => 9990,
    log_prefix      => $log_prefix,
    log_limit_burst => $log_limit_burst,
    log_limit       => $log_limit,
    log_level       => $log_level,
  }

  iptables::rule { "example42-rules-default_action-forward":
    table           => 'filter',
    chain           => 'FORWARD',
    target          => $real_forward_policy,
    log             => $bool_log_forward,
    order           => 9990,
    log_prefix      => $log_prefix,
    log_limit_burst => $log_limit_burst,
    log_limit       => $log_limit,
    log_level       => $log_level,
  }

  if $log_output == 'all' {
    iptables::rule { "example42-rules-default_action-output-log":
      table           => 'filter',
      chain           => 'OUTPUT',
      target          => 'LOG',
      order           => 25,
      log_prefix      => $log_prefix,
      log_limit_burst => $log_limit_burst,
      log_limit       => $log_limit,
      log_level       => $log_level,
    }
  }

  if $log_input == 'all' {
    iptables::rule { "example42-rules-default_action-input-log":
      table           => 'filter',
      chain           => 'INPUT',
      target          => 'LOG',
      order           => 25,
      log_prefix      => $log_prefix,
      log_limit_burst => $log_limit_burst,
      log_limit       => $log_limit,
      log_level       => $log_level,
    }
  }

  if $log_forward == 'all' {
    iptables::rule { "example42-rules-default_action-forward-log":
      table           => 'filter',
      chain           => 'FORWARD',
      target          => 'LOG',
      order           => 25,
      log_prefix      => $log_prefix,
      log_limit_burst => $log_limit_burst,
      log_limit       => $log_limit,
      log_level       => $log_level,
    }
  }

}
