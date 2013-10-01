# = Class: iptables
#
# Manages Iptables.
#
#
# == Parameters
#
# Module specific parameters
#
# [*my_class*]
#   Inlcude your own class when this class is invoked
#
# [*service_autorestart*]
#   Restart the iptables service when the configuration has changed.
#   Defaults to true
#
# [*log*]
#   Define what packets to log. Can be 'all', 'drop' or 'none'. Defaults to 'drop'
#
# [*log_prefix*]
#   The prefix to use for logged lines. Defaults to 'iptables'
#
# [*log_limit_burst*]
#   The iptables log limit-burst directive. Defaults to 10
#
# [*log_limit*]
#   The iptables log limit. Defaults to '30/m'
#
# [*log_level*]
#   The desired default iptables log level. Defaults to 4
#   numeric or see syslog.conf(5)
#
# [*enableICMPHostProhibited*]
#   Reject using --reject-with icmp-host-prohibited. Defaults to true
#
# [*default_target*]
#   Default target to use when adding a rule. Defaults to 'ACCEPT'
#
# [*default_order*]
#   Default order parameter to use when adding a new route. Defaults to 5000.
#
# [*configure_ipv6_nat*]
#   Configure NAT chain with IPv6. False by default.
#   Rationale for this setting and default is that many older versions
#   of linux and netfilter/iptables don't support the NAT table with
#   IPv6
#
# [*enable_v4*]
#   Use this module with IPv4. Defaults to true.
#
# [*enable_v6*]
#   Use this module with IPv6. Defaults to false.
#
# [*template*]
#   The template file to use when config=file
#
# [*mode*]
#   Define how you want to manage iptables configuration:
#   "file" - To provide iptables rules as a normal file
#   "concat" - To build them up using different fragments
#      - This option, set as default, permits the use of the iptables::rule define
#      - and many other funny things
#
# Default class params - As defined in iptables::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The package of the Iptables software.
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*service*]
#   The name of the Iptables service
#
# [*service_override_restart*]
#   To use the distro's built-in service to reload iptables
#
# [*service_status*]
#   If the standard42 service init script supports status argument
#
# [*service_status_cmd*]
#   Command to check if the iptables service is running
#
# [*config_file*]
#   The IPv4 config file
#
# [*config_file_v6*]
#   The IPv6 config file
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $standard42_absent
#
# [*disable*]
#   Set to 'true' to disable service(s) managed by module
#
# [*disableboot*]
#   Set to 'true' to disable service(s) at boot, without checks if it's running
#   Use this when the service is managed by a tool like a cluster software
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#
# == Examples
#
# Include it to install and manage Iptables
# It defines package, service, tables, chains, policies and rules.
#
# Usage:
#
# See README for details.
#
#
# == Author
#   Alessandro Franceschi <al@lab42.it/>
#   Dolf Schimmel - Freeaqingme <dolf@dolfschimmel.nl/>
#
class iptables (
  $my_class                 = params_lookup( 'my_class' ),
  $service_autorestart      = params_lookup( 'service_autorestart' , 'global' ),
  $log                      = params_lookup( 'log' ),
  $log_prefix               = params_lookup( 'log_prefix' ),
  $log_limit_burst          = params_lookup( 'log_limit_burst' ),
  $log_limit                = params_lookup( 'log_limit' ),
  $log_level                = params_lookup( 'log_level' ),
  $enableICMPHostProhibited = params_lookup( 'enableICMPHostProhibited' ),
  $default_target           = params_lookup( 'default_target' ),
  $default_order            = params_lookup( 'default_order' ),
  $configure_ipv6_nat       = params_lookup( 'configure_ipv6_nat' ),
  $enable_v4                = params_lookup( 'enable_v4', 'global' ),
  $enable_v6                = params_lookup( 'enable_v6', 'global' ),
  $template                 = params_lookup( 'template' ),
  $mode                     = params_lookup( 'mode' ),
  $package                  = params_lookup( 'package' ),
  $version                  = params_lookup( 'version' ),
  $service                  = params_lookup( 'service' ),
  $service_override_restart = params_lookup( 'service_override_restart' ),
  $service_status           = params_lookup( 'service_status' ),
  $service_status_cmd       = params_lookup( 'service_status_cmd' ),
  $config_file              = params_lookup( 'config_file' ),
  $config_file_v6           = params_lookup( 'config_file_v6'),
  $config_file_mode         = params_lookup( 'config_file_mode' ),
  $config_file_owner        = params_lookup( 'config_file_owner' ),
  $config_file_group        = params_lookup( 'config_file_group' ),
  $absent                   = params_lookup( 'absent' ),
  $disable                  = params_lookup( 'disable' ),
  $disableboot              = params_lookup( 'disableboot' ),
  $debug                    = params_lookup( 'debug' , 'global' ),
  $audit_only               = params_lookup( 'audit_only' , 'global' )
  ) inherits iptables::params {

  $bool_service_autorestart = any2bool($service_autorestart)
  $bool_absent = any2bool($absent)
  $bool_disable = any2bool($disable)
  $bool_disableboot = any2bool($disableboot)
  $bool_debug = any2bool($debug)
  $bool_audit_only = any2bool($audit_only)
  $bool_manage_icmp = any2bool($manage_icmp)
  $bool_enable_v4 = any2bool($enable_v4)
  $bool_enable_v6 = any2bool($enable_v6)
  $bool_service_override_restart = any2bool($service_override_restart)

  ### Definition of some variables used in the module
  $manage_package = $iptables::bool_absent ? {
    true  => 'absent',
    false => $iptables::version,
  }

  $manage_service_enable = $iptables::bool_disableboot ? {
    true    => false,
    default => $iptables::bool_disable ? {
      true    => false,
      default => $iptables::bool_absent ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_ensure = $iptables::bool_disable ? {
    true    => 'stopped',
    default =>  $iptables::bool_absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $reject_string = any2bool($enableICMPHostProhibited) ? {
    true    => 'REJECT --reject-with icmp-host-prohibited',
    false   => 'REJECT'
  }

  $manage_service_autorestart = $iptables::bool_service_autorestart ? {
    true    => Service[iptables],
    false   => undef,
  }

  $manage_file = $iptables::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_directory = $iptables::bool_absent ? {
    true    => 'absent',
    default => 'directory',
  }

  $manage_audit = $iptables::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $iptables::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $iptables::source ? {
    ''        => undef,
    default   => $iptables::source,
  }

  $manage_file_content = $iptables::template ? {
    ''        => undef,
    default   => template($iptables::template),
  }

  $real_safe_ssh = any2bool($safe_ssh)

  case $::operatingsystem {
    debian: { require iptables::debian }
    ubuntu: { require iptables::debian }
    default: { }
  }

  # Basic Package - Service - Configuration file management
  package { 'iptables':
    ensure => $iptables::manage_package,
    name   => $iptables::package,
  }

  include iptables::rules::default_action
  include iptables::rules::loopback

  # Todo: For now this always evaluates to false, no service is getting restarted
  if false and ! $bool_service_override_restart {
    service { 'iptables':
      ensure     => $iptables::manage_service_ensure,
      name       => $iptables::service,
      enable     => $iptables::manage_service_enable,
      hasstatus  => $iptables::service_status,
      status     => $iptables::service_status_cmd,
      require    => Package['iptables']
   }
 } else {

#    $cmd_restart_v4 = inline_template('iptables-restore < <%= scope.lookupvar("iptables::config_file") %>')
#    $cmd_restart_v6 = inline_template('ip6tables-restore < <%= scope.lookupvar("iptables::config_file_v6") %>')
#
#    if $bool_enable_v4 and $bool_enable_v6 {
#      $cmd_restart = "${cmd_restart_v4} && ${cmd_restart_v6}"
#    } elsif $bool_enable_v4 {
#      $cmd_restart = $cmd_restart_v4
#    } else {
#      $cmd_restart = $cmd_restart_v6
#    }

    $cmd_restart = '/bin/true'

    service { 'iptables':
      ensure     => $iptables::manage_service_ensure,
      name       => $iptables::service,
      enable     => $iptables::manage_service_enable,
      hasstatus  => $iptables::service_status,
      status     => $iptables::service_status_cmd,
      require    => Package['iptables'],
      hasrestart => false,
      restart    => $cmd_restart
    }

  }

  file { [ '/var/lib/puppet/iptables',
           '/var/lib/puppet/iptables/tables/' ]:
    ensure => $iptables::manage_directory,
    audit  => $iptables::manage_audit,
  }

  # How to manage iptables configuration
  case $iptables::mode {
    'file': { include iptables::file }
    'concat': {
      if $bool_enable_v4 {
        iptables::concat_emitter { 'v4':
          emitter_target  => $iptables::config_file,
          is_ipv6         => false,
        }
      }
      if $bool_enable_v6 {
        iptables::concat_emitter { 'v6':
          emitter_target  => $iptables::config_file_v6,
          is_ipv6         => true,
        }
      }
    }
    default: { }
  }

  ### Include custom class if $my_class is set
  if $iptables::my_class {
    include $iptables::my_class
  }

  ### Debugging, if enabled ( debug => true )
  if $iptables::bool_debug == true {
    file { 'debug_iptables':
      ensure  => $iptables::manage_file,
      path    => "${settings::vardir}/debug-iptables",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
    }
  }
}
