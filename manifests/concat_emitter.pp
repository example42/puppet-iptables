#
# defined type iptables::concat
#
# This class builds the iptables rule file using RIPienaar's concat module
# We build it using several fragments.
#
define iptables::concat_emitter(
  $emitter_target,
  $is_ipv6 = false
) {

  include iptables
  include concat::setup

  $ip_version = $is_ipv6 ? {
    true  => 6,
    false => 4
  }

  concat { $emitter_target:
    mode    => $iptables::config_file_mode,
    owner   => $iptables::config_file_owner,
    group   => $iptables::config_file_group,
    order   => 'natural',
    notify  => Service['iptables'],
  }

  # The File Header. With Puppet comment
  concat::fragment{ "iptables_header_$name":
    target  => $emitter_target,
    content => "# File Managed by Puppet\n",
    order   => 01,
    notify  => Service['iptables'],
  }

  iptables::table { "v${ip_version}_filter":
    emitter_target => $emitter_target,
    order          => 5,
    table_name     => 'filter',
    ip_version     => $ip_version,
    chains         => [ 'INPUT', 'FORWARD', 'OUTPUT' ]
  }

  if !$is_ipv6 or ( $is_ipv6 and $iptables::configure_ipv6_nat ) {
    # Linux did not use to support NAT on IPv6. You'll have to declare thse
    # items yourself explicitly if your kernel and Netfilter does support this.
    # Feel free to write (and contribute back!) a mechanism that actually
    # does support this. Thank you! ;-)

    iptables::table { "v${ip_version}_nat":
      emitter_target => $emitter_target,
      order          => 45,
      table_name     => 'nat',
      ip_version     => $ip_version,
      chains         => [ 'PREROUTING', 'INPUT', 'OUTPUT', 'POSTROUTING' ]
    }

  }

  iptables::table { "v${ip_version}_mangle":
    emitter_target => $emitter_target,
    order          => 65,
    table_name     => 'mangle',
    ip_version     => $ip_version,
    chains         => [ 'PREROUTING', 'INPUT', 'FORWARD', 'OUTPUT', 'POSTROUTING' ]
  }

  iptables::table { "v${ip_version}_raw":
    emitter_target => $emitter_target,
    order          => 65,
    table_name     => 'raw',
    ip_version     => $ip_version,
    chains         => [ 'PREROUTING', 'OUTPUT' ]
  }

}
