# Class: iptables::params
#
# Sets internal variables and defaults for iptables module
# This class is loaded in all the classes that use the values set here
#
class iptables::params  {

  ### Definition of some variables used in the module
  $osver = split($::operatingsystemrelease, '[.]')
  $osver_maj = $osver[0]
  
## DEFAULTS FOR VARIABLES USERS CAN SET

  
  $my_class = ''
  $service_autorestart = true

  $log             = 'drop'
  $log_prefix      = 'iptables'
  $log_limit_burst = 10
  $log_limit       = '30/m'
  $log_level       = '4'

  $enableICMPHostProhibited = true
  $default_target = 'ACCEPT'
  $default_order = '5000'
  $configure_ipv6_nat = false

  $enable_v4 = true
  $enable_v6 = false
  
  $template = ''
  $mode = 'concat'
  

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
  
  $source = ''
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
