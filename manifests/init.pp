#
# Class: iptables
#
# Manages iptables.
#
# Usage:
# include iptables
#
class iptables (
  $my_class                 = params_lookup( 'my_class' ),
  $config                   = params_lookup( 'config' ),
  $source                   = params_lookup( 'source' ),
  $template                 = params_lookup( 'template' ),
  $service_autorestart      = params_lookup( 'service_autorestart' , 'global' ),
  $log                      = params_lookup( 'log' ),
  $log_prefix               = params_lookup( 'log_prefix' ),
  $log_limit_burst          = params_lookup( 'log_limit_burst' ),
  $log_limit                = params_lookup( 'log_limit' ),
  $log_level                = params_lookup( 'log_level' ),
  $safe_ssh                 = params_lookup( 'safe_ssh' ),
  $enableICMPHostProhibited = params_lookup( 'enableICMPHostProhibited' ),
  $default_target           = params_lookup( 'default_target' ),
  $configure_ipv6_nat       = params_lookup( 'configure_ipv6_nat' ),
  $default_order            = params_lookup( 'default_order' ),
  $package                  = params_lookup( 'package' ),
  $version                  = params_lookup( 'version' ),
  $service                  = params_lookup( 'service' ),
  $service_override_restart = params_lookup( 'service_override_restart' ),
  $service_status           = params_lookup( 'service_status' ),
  $service_status_cmd       = params_lookup( 'service_status_cmd' ),
  $config_file              = params_lookup( 'config_file' ),
  $config_file_v6           = params_lookup ('config_file_v6'),
  $config_file_mode         = params_lookup( 'config_file_mode' ),
  $config_file_owner        = params_lookup( 'config_file_owner' ),
  $config_file_group        = params_lookup( 'config_file_group' ),
  $absent                   = params_lookup( 'absent' ),
  $disable                  = params_lookup( 'disable' ),
  $disableboot              = params_lookup( 'disableboot' ),
  $debug                    = params_lookup( 'debug' , 'global' ),
  $enable_v4                = params_lookup( 'enable_v4', 'global' ),
  $enable_v6                = params_lookup( 'enable_v6', 'global' ),
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
  case $iptables::config {
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
