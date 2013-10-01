# Class: iptables::params
#
# Sets internal variables and defaults for iptables module
# This class is loaded in all the classes that use the values set here
#
class iptables::params  {

  ### Definition of some variables used in the module
  $osver = split($::operatingsystemrelease, '[.]')
  $osver_maj = $osver[0]

  # This should be dependent on the kernel, netfilter version and capabilities
  $configure_ipv6_nat = false

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
