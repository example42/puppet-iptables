# Class: iptables::params
#
# Sets internal variables and defaults for iptables module
# This class is loaded in all the classes that use the values set here
#
class iptables::params  {

  ### Definition of some variables used in the module
  $osver = split($::operatingsystemrelease, '[.]')
  $osver_maj = string2int($osver[0])

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

# Define what to do with INPUT broadcast packets
  $broadcast_policy = 'accept'

# Define what to do with INPUT multicast packets
  $multicast_policy = 'accept'

# Define use comment module
  $comment = false

## MODULE INTERNAL VARIABLES
# (Modify to adapt to unsupported OSes)

  $package = $::operatingsystem ? {
    default => 'iptables',
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
      if ($osver_maj < 7) {
        # Squeeze or earlier
        $config_file = '/etc/iptables/rules'
        $service_hasrestart = false
        $service = 'iptables-persistent'
      } elsif ($osver_maj < 8) {
        # Wheezy
        $config_file = '/etc/iptables/rules.v4' # Introduced in iptables-persistent 0.5/wheezy
        $service_hasrestart = true
        $service = 'iptables-persistent'
      } else {
        # Jessie (and later)
        $config_file = '/etc/iptables/rules.v4' # Introduced in iptables-persistent 0.5/wheezy
        $service_hasrestart = true
        $service = 'netfilter-persistent'        # Changed in iptables-persistent 1.0/jessie
      }
      $config_file_v6 = '/etc/iptables/rules.v6' # Introduced in iptables-persistent 0.5/wheezy, noop before
    }
    /(?i:Ubuntu)/: {
      if ($osver_maj < 12) {
        $config_file = '/etc/iptables/rules'
        $service_hasrestart = false
      } else {
        $config_file = '/etc/iptables/rules.v4' # Introduced in iptables-persistent 0.5/Ubuntu 12.04
        $service_hasrestart = true
      }
      $config_file_v6 = '/etc/iptables/rules.v6' # Introduced in iptables-persistent 0.5/Ubuntu 12.04, noop before
      $service = 'iptables-persistent'
    }
    /(?i:Mint)/: {
      if ($osver_maj < 13) {
        $config_file = '/etc/iptables/rules'
        $service_hasrestart = false
      } else {
        $config_file = '/etc/iptables/rules.v4' # Introduced in iptables-persistent 0.5/Mint 13
        $service_hasrestart = true
      }
      $config_file_v6 = '/etc/iptables/rules.v6' # Introduced in iptables-persistent 0.5/Mint 13, noop before
      $service = 'iptables-persistent'
    }
    default: {
      $config_file = '/etc/sysconfig/iptables'
      $service_hasrestart = true
      $config_file_v6 = '/etc/sysconfig/ip6tables'
      $service = 'iptables'
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
  $content = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false
  $disable = false
  $disableboot = false
  $debug = false
  $audit_only = false
  $options = {}

  $filter_header_template         = 'iptables/concat/filter_header'
  $filter_input_header_template   = 'iptables/concat/filter_input_header'
  $filter_input_footer_template   = 'iptables/concat/filter_input_footer'
  $filter_output_header_template  = 'iptables/concat/filter_output_header'
  $filter_output_footer_template  = 'iptables/concat/filter_output_footer'
  $filter_forward_header_template = 'iptables/concat/filter_forward_header'
  $filter_forward_footer_template = 'iptables/concat/filter_forward_footer'
  $filter_footer_template         = 'iptables/concat/filter_footer'
  $nat_header_template            = 'iptables/concat/nat_header'
  $nat_footer_template            = 'iptables/concat/nat_footer'
  $mangle_header_template         = 'iptables/concat/mangle_header'
  $mangle_footer_template         = 'iptables/concat/mangle_footer'
  $rules                          = {}

}
