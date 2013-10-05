class iptables::ruleset::multicast (
  $chains          = [ 'INPUT' ],
  $target          = $iptables::default_target,
  $order           = 7500,
  $log             = false,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {

  $discard = iptables_declare_multiple('iptables::rule', $chains,
                                             'example42-multicast-filter-###name###', {
    table            => 'filter',
    chain            => '###name###',
    explicit_matches => { 'pkttype' => {'pkt-type' => 'multicast'}},
    target           => $target,
    order            => $order,
    log              => $log,
    log_prefix       => $log_prefix,
    log_limit_burst  => $log_limit_burst,
    log_limit        => $log_limit,
    log_level        => $log_level
  })

}
