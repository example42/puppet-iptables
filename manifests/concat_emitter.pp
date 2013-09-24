#
# defined type iptables::concat
#
# This class builds the iptables rule file using RIPienaar's concat module
# We build it using several fragments.
# Being the sequence of lines important we define these boundaries:
# 01 - General header
# Note that the iptables::rule define
# inserts (by default) its rules with priority 50.
#
define iptables::concat_emitter(
  $emitter_target,
  $is_ipv6 = false
) {

  include iptables
  include concat::setup

  $real_icmp_port = $is_ipv6 ? {
    true    => '-p icmpv6',
    default => '-p icmp',
  }

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

  if $iptables::use_legacy_ordering {
    # In the past, all rules were directly concatenated in the total ruleset.
    
  
    # The FILTER table header with the default policies
    concat::fragment{ "iptables_filter_header_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_header'),
      order   => 05,
      notify  => Service['iptables'],
    }
  
    # The input chain header with sane defaults
    concat::fragment{ "iptables_filter_input_header_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_input_header'),
      order   => 10,
      notify  => Service['iptables'],
    }
  
    # The input chain footer with logging and block_policy
    concat::fragment{ "iptables_filter_input_footer_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_input_footer'),
      order   => 19,
      notify  => Service['iptables'],
    }
  
    # The output chain header with sane defaults
    concat::fragment{ "iptables_filter_output_header_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_output_header'),
      order   => 20,
      notify  => Service['iptables'],
    }
  
    # The output chain footer with logging and block_policy
    concat::fragment{ "iptables_filter_output_footer_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_output_footer'),
      order   => 29,
      notify  => Service['iptables'],
    }
  
    # The forward chain header with sane defaults
    concat::fragment{ "iptables_filter_forward_header_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_forward_header'),
      order   => 30,
      notify  => Service['iptables'],
    }
  
    # The forward chain footer with logging and block_policy
    concat::fragment{ "iptables_filter_forward_footer_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_forward_footer'),
      order   => 39,
      notify  => Service['iptables'],
    }
  
    # The FILTER table footer (COMMIT)
    concat::fragment{ "iptables_filter_footer_$name":
      target  => $emitter_target,
      content => template('iptables/concat/filter_footer'),
      order   => 40,
      notify  => Service['iptables'],
    }
  
    if !$is_ipv6 {
      # Linux did not use to support NAT on IPv6. You'll have to declare thse
      # items yourself explicitly if your kernel and Netfilter does support this.

      # The NAT table header with the default policies
      concat::fragment{ "iptables_nat_header_$name":
        target  => $emitter_target,
        content => template('iptables/concat/nat_header'),
        order   => 45,
        notify  => Service['iptables'],
      }
    
      # The NAT table footer (COMMIT)
      concat::fragment{ "iptables_nat_footer_$name":
        target  => $emitter_target,
        content => template('iptables/concat/nat_footer'),
        order   => 60,
        notify  => Service['iptables'],
      }
    }
  
    # The MANGLE table header with the default policies
    concat::fragment{ "iptables_mangle_header_$name":
      target  => $emitter_target,
      content => template('iptables/concat/mangle_header'),
      order   => 65,
      notify  => Service['iptables'],
    }
  
    # The MANGLE table footer (COMMIT)
    concat::fragment{ "iptables_mangle_footer_$name":
      target  => $emitter_target,
      content => template('iptables/concat/mangle_footer'),
      order   => 80,
      notify  => Service['iptables'],
    }
    
  } else {
    # The organization of the iptables module was later changed by introducing
    # a concept of tables. By using the new structure, all rules are added to
    # their respective tables first, then tables are concatenated into their
    # ruleset.
    
    iptables::table { "v${ip_version}_filter":
      emitter_target => $emitter_target,
      order          => 5,
      table_name     => 'filter',
      ip_version     => $ip_version,
      chains         => [ 'INPUT', 'FORWARD', 'OUTPUT' ]
    }
  
    # The input chain header with sane defaults
    concat::fragment{ "iptables_filter_input_header_$name":
      target  => "/var/lib/puppet/iptables/tables/v${ip_version}_filter",
      content => template('iptables/concat/filter_input_header'),
      order   => 50,
      notify  => Service['iptables'],
    }
  
    # The input chain footer with logging and block_policy
    concat::fragment{ "iptables_filter_input_footer_$name":
      target  => "/var/lib/puppet/iptables/tables/v${ip_version}_filter",
      content => template('iptables/concat/filter_input_footer'),
      order   => 8000,
      notify  => Service['iptables'],
    }
    
    # The output chain header with sane defaults
    concat::fragment{ "iptables_filter_output_header_$name":
      target  => "/var/lib/puppet/iptables/tables/v${ip_version}_filter",
      content => template('iptables/concat/filter_output_header'),
      order   => 50,
      notify  => Service['iptables'],
    }
  
    # The output chain footer with logging and block_policy
    concat::fragment{ "iptables_filter_output_footer_$name":
      target  => "/var/lib/puppet/iptables/tables/v${ip_version}_filter",
      content => template('iptables/concat/filter_output_footer'),
      order   => 8000,
      notify  => Service['iptables'],
    }
  
    # The forward chain header with sane defaults
    concat::fragment{ "iptables_filter_forward_header_$name":
      target  => "/var/lib/puppet/iptables/tables/v${ip_version}_filter",
      content => template('iptables/concat/filter_forward_header'),
      order   => 50,
      notify  => Service['iptables'],
    }

    # The forward chain footer with logging and block_policy
    concat::fragment{ "iptables_filter_forward_footer_$name":
      target  => "/var/lib/puppet/iptables/tables/v${ip_version}_filter",
      content => template('iptables/concat/filter_forward_footer'),
      order   => 8000,
      notify  => Service['iptables'],
    }

    if !$is_ipv6 {
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

      # The NAT table header with the default policies
      concat::fragment{ "iptables_nat_header_$name":
        target  => "/var/lib/puppet/iptables/tables/v${ip_version}_nat",
        content => template('iptables/concat/nat_header'),
        order   => 50,
        notify  => Service['iptables'],
      }

    }
    
    iptables::table { "v${ip_version}_mangle":
      emitter_target => $emitter_target,
      order          => 65,
      table_name     => 'mangle',
      ip_version     => $ip_version,
      chains         => [ 'PREROUTING', 'INPUT', 'FORWARD', 'OUTPUT', 'POSTROUTING' ]
    }
      
    # The MANGLE table header with the default policies
    concat::fragment{ "iptables_mangle_header_$name":
      target  => "/var/lib/puppet/iptables/tables/v${ip_version}_mangle",
      content => template('iptables/concat/mangle_header'),
      order   => 50,
      notify  => Service['iptables'],
    }
    
  }
}
