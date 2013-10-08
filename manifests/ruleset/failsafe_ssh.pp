
class iptables::ruleset::failsafe_ssh (
  $chains                  = [ 'INPUT', 'OUTPUT' ],
  $target                  = 'ACCEPT',
  $order                   = 11,
  $port                    = 22,
  $log                     = false,
  $lookup_alternative_port = true,
  $log_prefix              = $iptables::log_prefix,
  $log_limit_burst         = $iptables::log_limit_burst,
  $log_limit               = $iptables::log_limit,
  $log_level               = $iptables::log_level,
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

  # If openssh has been configured to use a different class we'll
  # usee that too.
  # We could combine the two rule statements into one by using a
  # multiport match, but not all kernels support this, so for a
  # failsafe we're not taking any chances.
  if $lookup_alternative_port and defined(Class['openssh']) and $openssh::port != $port {
      $discard_1 = iptables_declare_multiple('iptables::rule',
        $chains, 'example42-failsafe-ssh-###name###-otherPort',
    {
      table           => 'filter',
      chain           => '###name###',
      target          => $target,
      protocol        => 'tcp',
      port            => $openssh::port,
      order           => $order,
      log             => $log,
      log_prefix      => $log_prefix,
      log_limit_burst => $log_limit_burst,
      log_limit       => $log_limit,
      log_level       => $log_level
    })
  }

}
