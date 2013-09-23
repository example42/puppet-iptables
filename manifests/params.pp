# Class: iptables::params
#
# Sets internal variables and defaults for iptables module
# This class is loaded in all the classes that use the values set here
#
class iptables::params  {

  ### Definition of some variables used in the module
  $osver = split($::operatingsystemrelease, '[.]')
  $osver_maj = $osver[0]
  
  $default_target = 'ACCEPT'

# Enable support for IPv4
  $enable_v4 = true

# Enable support for IPv6
  $enable_v6 = false
  
## DEFAULTS FOR VARIABLES USERS CAN SET

# Define how you want to manage iptables configuration:
# "file" - To provide iptables rules as a normal file
# "concat" - To build them up using different fragments
#      - This option, set as default, permits the use of the iptables::rule define
#      - and many other funny things
  $config = 'concat'

# Define what to do with unknown packets
  $block_policy = 'DROP'

# Define what to do with icmp packets (quick'n'dirty approach)
  $icmp_policy = 'ACCEPT'
  
  $enableICMPHostProhibited = true
  
# Determine if we should actually do anything with ICMP rules
# (if false, you can always add icmp-rules manually using iptables::rule)
  $manage_icmp = true

# Define what to do with output packets
  $output_policy = 'ACCEPT'

## Define what packets to log
  $log = 'drop'
  $log_input = ''
  $log_output = ''
  $log_forward = ''

# Define the Level of logging (numeric or see syslog.conf(5))
  $log_level = '4'

# Define if you want to open SSH port by default
  $safe_ssh = true
  
# Default protocol to define when configuring a rule. E.g. 'all', 'tcp', 'udp', 'icmp', etc. 
# Consider using 'all'. TCP is used here for BC reasons.
  $default_protocol = 'tcp'  

# Define whether to allow all RELATED,ESTABLISHED traffic by default
  $allow_established = true

# Define what to do with INPUT broadcast packets
  $broadcast_policy = 'accept'

# Define what to do with INPUT multicast packets
  $multicast_policy = 'accept'
  
# Define what default $order value to use when declaring an instance of a iptables::rule
# (in conjunction with $use_legacy_ordering = false)
  $default_order = ''
  
# Define to use legacy ordering. If this is a new setup, consider setting this variable to false(!).
# In the past, all rules were directly concatenated in the total ruleset. The organization
# of the iptables module was later changed by introducing a concept of tables. By using the
# new structure, all rules are added to their respective tables first, then tables are concatenated
# into the ruleset.
  $use_legacy_ordering = true
  
# If a packet is dropped and logged, you can specify a prefix here that is applied. Consider using
# 'iptables '.
  $log_prefix_prefix = ''
  
  $configure_ipv6_nat = false


## MODULE INTERNAL VARIABLES
# (Modify to adapt to unsupported OSes)

  $package = $::operatingsystem ? {
    default => 'iptables',
  }

  $service = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'iptables-persistent',
    default                   => 'iptables',
  }
  
  # use "$service restart" to load new firewall rules?
  $service_override_restart = $::operatingsystem ? {
    /(?i:Ubuntu)/ => 'false', # Don't know about other distro's. Who does?
    default       => 'true',
  }

  $service_status = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => false,
    default                   => true,
  }

  $service_status_cmd = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/bin/true',
    default                   => undef,
  }

  case $::operatingsystem {
    /(?i:Debian)/: {
      if (($osver_maj =~ /^\d+$/) and ($osver_maj < 7)) {
        $config_file = '/etc/iptables/rules'
      } else {
        $config_file = '/etc/iptables/rules.v4' # Introduced in iptables-persistent 0.5/wheezy
      }
    }
    /(?i:Ubuntu)/: {
      if (($osver_maj =~ /^\d+$/) and ($osver_maj < 12)) {
        $config_file = '/etc/iptables/rules'
      } else {
        $config_file = '/etc/iptables/rules.v4' # Introduced in iptables-persistent 0.5/Ubuntu 12.04
        $config_file_v6 = '/etc/iptables/rules.v6' # Introduced in iptables-persistent 0.5/Ubuntu 12.04
      }
    }
    /(?i:Mint)/: {
      if (($osver_maj =~ /^\d+$/) and ($osver_maj < 13)) {
        $config_file = '/etc/iptables/rules'
      } else {
        $config_file = '/etc/iptables/rules.v4' # Introduced in iptables-persistent 0.5/Mint 13
      }
    }
    default: {
      $config_file = '/etc/sysconfig/iptables'
    }
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0640',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }
  
  $my_class = ''
  $source = ''
  $template = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false
  $disable = false
  $disableboot = false
  $debug = false
  $audit_only = false

  ## FILE SERVING SOURCE
  case $::base_source {
    '': {
      $general_base_source = $::puppetversion ? {
        /(^0.25)/ => 'puppet:///modules',
        /(^0.)/   => "puppet://${servername}",
        default   => 'puppet:///modules',
      }
    }
    default: { $general_base_source = $::base_source }
  }

}
