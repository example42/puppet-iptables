
class iptables::ruleset::failsafe_ssh (
  $chains          = [ 'INPUT', 'OUTPUT' ],
  $target          = 'ACCEPT',
  $order           = 11,
  $port            = 22,
  $log             = false,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {
  
  $discard = iptables_declare_multiple('iptables::rule',
    $chains, 'example42-failsafe-ssh-###name###',
  {
    table           => 'filter',
    chain           => '###name###',
    target          => $target,
    protocol        => 'tcp',
    port            => $port,
    order           => $order,
    log             => $log,
    log_prefix      => $log_prefix,
    log_limit_burst => $log_limit_burst,
    log_limit       => $log_limit,
    log_level       => $log_level
  })

}
