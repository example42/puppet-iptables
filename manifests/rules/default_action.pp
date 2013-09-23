
class iptables::rules::default_action (
  $output_policy  = $iptables::output_policy,
  $input_policy   = 'reject',
  $forward_policy = 'reject'
) {

  $real_output_policy = $output_policy ? {
    'drop'    => 'DROP',
    'DROP'    => 'DROP',
    'accept'  => 'ACCEPT',
    'ACCEPT'  => 'ACCEPT',
    'reject'  => $iptables::reject_string,
    'REJECT'  => $iptables::reject_string,
    default   => fail("Improper 'output_policy' value given to iptables: ${output_policy}")
  }

  $real_input_policy = $input_policy ? {
    'drop'    => 'DROP',
    'DROP'    => 'DROP',
    'accept'  => 'ACCEPT',
    'ACCEPT'  => 'ACCEPT',
    'reject'  => $iptables::reject_string,
    'REJECT'  => $iptables::reject_string,
    default   => fail("Improper 'input_policy' value given to iptables: ${output_policy}")
  }

  $real_forward_policy = $forward_policy ? {
    'drop'    => 'DROP',
    'DROP'    => 'DROP',
    'accept'  => 'ACCEPT',
    'ACCEPT'  => 'ACCEPT',
    'reject'  => $iptables::reject_string,
    'REJECT'  => $iptables::reject_string,
    default   => fail("Improper 'forward_policy' value given to iptables: ${forward_policy}")
  }

  include iptables::rules::log

  iptables::rule { "example42-rules-default_action-output":
    table         => 'filter',
    chain         => 'OUTPUT',
    target        => $real_output_policy,
    order         => 9995,
  }

  iptables::rule { "example42-rules-default_action-input":
    table         => 'filter',
    chain         => 'INPUT',
    target        => $real_input_policy,
    order         => 9995,
  }

  iptables::rule { "example42-rules-default_action-forward":
    table         => 'filter',
    chain         => 'FORWARD',
    target        => $real_forward_policy,
    order         => 9995,
  }

  if $iptables::rules::log::real_log_output != 'no' {
    iptables::rule { 'example42-rules-default_action-log-output':
      table         => 'filter',
      chain         => 'OUTPUT',
      target        => $real_output_policy ? { 'accept' => 'REGULARLOG', default => 'LOGFORDROP', },
      order         => 9990,
    }
  }

  if $iptables::rules::log::real_log_input != 'no' {
    iptables::rule { 'example42-rules-default_action-log-input':
      table         => 'filter',
      chain         => 'INPUT',
      target        => $real_input_policy ? { 'accept' => 'REGULARLOG', default => 'LOGFORDROP', },
      order         => 9990,
    }
  }

  if $iptables::rules::log::real_log_forward != 'no' {
    iptables::rule { 'example42-rules-default_action-log-forward':
      table         => 'filter',
      chain         => 'FORWARD',
      target        => $real_forward_policy ? { 'accept' => 'REGULARLOG', default => 'LOGFORDROP', },
      order         => 9990,
    }
  }

}
