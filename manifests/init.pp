#
# Class: iptables
#
# Manages iptables.
#
# Usage:
# include iptables
#
class iptables (
  $my_class                       = params_lookup( 'my_class' ),
  $config                         = params_lookup( 'config' ),
  $source                         = params_lookup( 'source' ),
  $template                       = params_lookup( 'template' ),
  $content                        = params_lookup( 'content' ),
  $service_autorestart            = params_lookup( 'service_autorestart' , 'global' ),
  $block_policy                   = params_lookup( 'block_policy' ),
  $icmp_policy                    = params_lookup( 'icmp_policy' ),
  $output_policy                  = params_lookup( 'output_policy' ),
  $broadcast_policy               = params_lookup( 'broadcast_policy' ),
  $multicast_policy               = params_lookup( 'multicast_policy' ),
  $comment                        = params_lookup( 'comment' ),
  $log                            = params_lookup( 'log' ),
  $log_input                      = params_lookup( 'log_input' ),
  $log_output                     = params_lookup( 'log_output' ),
  $log_forward                    = params_lookup( 'log_forward' ),
  $log_level                      = params_lookup( 'log_level' ),
  $safe_ssh                       = params_lookup( 'safe_ssh' ),
  $package                        = params_lookup( 'package' ),
  $version                        = params_lookup( 'version' ),
  $service                        = params_lookup( 'service' ),
  $service_status                 = params_lookup( 'service_status' ),
  $service_status_cmd             = params_lookup( 'service_status_cmd' ),
  $service_hasrestart             = params_lookup( 'service_hasrestart'),
  $config_file                    = params_lookup( 'config_file' ),
  $config_file_v6                 = params_lookup( 'config_file_v6' ),
  $config_file_mode               = params_lookup( 'config_file_mode' ),
  $config_file_owner              = params_lookup( 'config_file_owner' ),
  $config_file_group              = params_lookup( 'config_file_group' ),
  $absent                         = params_lookup( 'absent' ),
  $disable                        = params_lookup( 'disable' ),
  $disableboot                    = params_lookup( 'disableboot' ),
  $debug                          = params_lookup( 'debug' , 'global' ),
  $enable_v6                      = params_lookup( 'enable_v6', 'global' ),
  $audit_only                     = params_lookup( 'audit_only' , 'global' ),
  $options                        = params_lookup( 'options' ),
  $filter_header_template         = params_lookup( 'filter_header_template' ),
  $filter_input_header_template   = params_lookup( 'filter_input_header_template' ),
  $filter_input_footer_template   = params_lookup( 'filter_input_footer_template' ),
  $filter_output_header_template  = params_lookup( 'filter_output_header_template' ),
  $filter_output_footer_template  = params_lookup( 'filter_output_footer_template' ),
  $filter_forward_header_template = params_lookup( 'filter_forward_header_template' ),
  $filter_forward_footer_template = params_lookup( 'filter_forward_footer_template' ),
  $filter_footer_template         = params_lookup( 'filter_footer_template' ),
  $nat_header_template            = params_lookup( 'nat_header_template' ),
  $nat_footer_template            = params_lookup( 'nat_footer_template' ),
  $mangle_header_template         = params_lookup( 'mangle_header_template' ),
  $mangle_footer_template         = params_lookup( 'mangle_footer_template' ),
  ) inherits iptables::params {

  $bool_service_autorestart = any2bool($service_autorestart)
  $bool_absent = any2bool($absent)
  $bool_disable = any2bool($disable)
  $bool_disableboot = any2bool($disableboot)
  $bool_debug = any2bool($debug)
  $bool_audit_only = any2bool($audit_only)

  ### Definitions of specific variables
  $real_block_policy = $block_policy ? {
    'drop'    => 'DROP',
    'DROP'    => 'DROP',
    'reject'  => 'REJECT --reject-with icmp-host-prohibited',
    'REJECT'  => 'REJECT --reject-with icmp-host-prohibited',
    'accept'  => 'ACCEPT',
    'ACCEPT'  => 'ACCEPT',
    default   => 'DROP',
  }

  $real_icmp_policy = $icmp_policy ? {
    'drop'    => '-j DROP',
    'DROP'    => '-j DROP',
    'safe'    => '-m icmp ! --icmp-type echo-request -j ACCEPT',
    'accept'  => '-j ACCEPT',
    'ACCEPT'  => '-j ACCEPT',
    'limit'   => '-j ICMP_LIMITS',
    'LIMIT'   => '-j ICMP_LIMITS',
    default   => '-j ACCEPT',
  }

  $real_output_policy = $output_policy ? {
    'drop'    => 'drop',
    'DROP'    => 'drop',
    default   => 'accept',
  }

  $real_log = $log ? {
    'all'     => 'all',
    'dropped' => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    default   => 'drop',
  }
  $real_log_input = $log_input ? {
    ''        => $real_log,
    'all'     => 'all',
    'dropped' => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    default   => 'drop',
  }
  $real_log_output = $log_output ? {
    ''        => $real_log,
    'all'     => 'all',
    'dropped' => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    default   => 'drop',
  }
  $real_log_forward = $log_forward ? {
    ''        => $real_log,
    'all'     => 'all',
    'dropped' => 'drop',
    'none'    => 'no',
    'no'      => 'no',
    default   => 'drop',
  }

  $real_safe_ssh = any2bool($safe_ssh)

  $real_broadcast_policy = $broadcast_policy ? {
    'drop'    => 'drop',
    'DROP'    => 'drop',
    default   => 'accept',
  }

  $real_multicast_policy = $multicast_policy ? {
    'drop'    => 'drop',
    'DROP'    => 'drop',
    default   => 'accept',
  }


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

  $manage_service_autorestart = $iptables::bool_service_autorestart ? {
    true    => Service[iptables],
    false   => undef,
  }

  $manage_file = $iptables::bool_absent ? {
    true    => 'absent',
    default => 'present',
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

  $manage_file_content = $iptables::content ? {
    ''        => $iptables::template ? {
      ''        => undef,
      default   => template($iptables::template),
    },
    default   => $iptables::content,
  }

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

  $restart_cmd = $service_hasrestart?{
    true  => undef,
    false => inline_template('iptables-restore < <%= scope.lookupvar("iptables::config_file") %>; [ -f <%= scope.lookupvar("iptables::config_file_v6") %> ] && ip6tables-restore < <%= scope.lookupvar("iptables::config_file_v6") %>'),
  }

  service { 'iptables':
    ensure     => $iptables::manage_service_ensure,
    name       => $iptables::service,
    enable     => $iptables::manage_service_enable,
    hasstatus  => $iptables::service_status,
    status     => $iptables::service_status_cmd,
    require    => Package['iptables'],
    hasrestart => $iptables::service_hasrestart,
    restart    => $restart_cmd,
  }

  # How to manage iptables configuration
  case $iptables::config {
    'file': { include iptables::file }
    'concat': {
      iptables::concat_emitter { 'v4':
        emitter_target  => $iptables::config_file,
        is_ipv6         => false,
      }
      if $enable_v6 {
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
