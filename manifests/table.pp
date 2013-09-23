
define iptables::table (
  $emitter_target,
  $order,
  $table_name = '',
  $ip_version = 6,
) {

  $real_name = $table_name ? {
    ''      => $name,
    default => $table_name
  }

  concat { "/var/lib/puppet/iptables/tables/v${ip_version}_${real_name}":
    mode    => $iptables::config_file_mode,
    owner   => $iptables::config_file_owner,
    group   => $iptables::config_file_group,
    notify  => Service['iptables'],
  }

  concat::fragment { "iptables_table_${ip_version}_${name}":
    target  => $emitter_target,
    source  => "/var/lib/puppet/iptables/tables/v${ip_version}_${real_name}",
    order   => $order,
    notify  => Service['iptables'],
    after   => Concat::Fragment[ "iptables_table_${ip_version}_${name}" ]
  }

}
