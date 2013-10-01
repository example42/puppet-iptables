# = Class: iptables::ruleset::security
#
#  Loads several security-related rulesets.
#
#  The number of rulesets included by this module may be changed without notice
#  
class iptables::ruleset::security (
) {
  
  include iptables::ruleset::invalid
  include iptables::ruleset::smurf_attack
  
}