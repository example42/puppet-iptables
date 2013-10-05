
define iptables::table (
  $emitter_target,
  $order,
  $chains = [],
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
    force   => true,
  }

  concat::fragment{ "iptables_table_${name}_header":
    target  => "/var/lib/puppet/iptables/tables/v${ip_version}_${real_name}",
    content => "*${real_name}\n",
    order   => '0001',
  }

  concat::fragment{ "iptables_table_${name}_footer":
    target  => "/var/lib/puppet/iptables/tables/v${ip_version}_${real_name}",
    content => "COMMIT\n",
    order   => 9999,
  }

  concat::fragment { "iptables_table_${ip_version}_${real_name}":
    target  => $emitter_target,
    source  => "/var/lib/puppet/iptables/tables/v${ip_version}_${real_name}",
    order   => $order,
    require => Concat[ "/var/lib/puppet/iptables/tables/v${ip_version}_${real_name}" ]
  }

  iptables::chain { $name:
    table      => $real_name,
    chain_name => $chains,
    ip_version => $ip_version
  }

}
