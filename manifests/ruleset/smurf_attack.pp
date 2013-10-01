# = Class: iptables::ruleset::smurf_attack
#
#  Prevents against SMURF attacks.
#
#  See also:
#  - https://en.wikipedia.org/wiki/Smurf_attack
#  - https://www.nordu.net/articles/smurf.html
#
#  Todo: Evaluate risk with IPv6. For now this module is IPv4 only.
#  
# [*chains*]
#  The chains to apply this ruleset against
#
# [*target*]
#  What to do with packets that match the ruleset.
#  This functionality is meant to prevent a DDOS, do not make this
#
# [*order*]
#  The order 8500 was chosen as default because the more specific ping
#  rule (iptables::ruleset::ping uses a lower order index
#
# [*log*]
#  Log packets captured by this ruleset
#
# [*log_prefix*]
#   Prefix for all log lines
#
# [*log_limit_burst*]
#   The Iptables limit-burst directive used for logging
#
# [*log_limit*]
#   The limit directive of Iptables to limit logging
#
# [*log_level*]
#   The iptables log level directive for logging
#
class iptables::ruleset::smurf_attack (
  $chains          = [ 'INPUT', 'FORWARD' ],
  $target          = 'DROP',
  $order           = 600,
  $log             = true,
  $log_prefix      = $iptables::log_prefix,
  $log_limit_burst = $iptables::log_limit_burst,
  $log_limit       = $iptables::log_limit,
  $log_level       = $iptables::log_level,
) {

  each($chains) |$chain| {
    iptables::rule { "example42-smurf_attack-filter-${chain}-addr-mask-req":
      table            => 'filter',
      chain            => $chain,
      implicit_matches => { 'protocol_v4' => 'ICMP' },
      explicit_matches => {'icmp_v4'   => { 'icmp-type'   => 'address-mask-request' } },
      target           => $target,
      order            => $order,
      log              => $log,
      log_prefix       => $log_prefix,
      log_limit_burst  => $log_limit_burst,
      log_limit        => $log_limit,
      log_level        => $log_level,
      enable_v6        => false,
    }

    iptables::rule { "example42-smurf_attack-filter-${chain}-timestamp-req":
      table            => 'filter',
      chain            => $chain,
      implicit_matches => { 'protocol_v4' => 'ICMP', },
      explicit_matches => { 'icmp_v4' => { 'icmp-type'   => 'timestamp-request' } },
      target           => $target,
      order            => $order,
      log              => $log,
      log_prefix       => $log_prefix,
      log_limit_burst  => $log_limit_burst,
      log_limit        => $log_limit,
      log_level        => $log_level,
      enable_v6        => false,
    }
  }

}
