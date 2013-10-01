
define iptables::chain (
  $table,
  $chain_name,
  $ip_version = 6,
  $action = 'ACCEPT'
) {

  concat::fragment{ "iptables_chain_${name}":
    target  => "/var/lib/puppet/iptables/tables/v${ip_version}_${table}",
    content => inline_template("<% @chain_name.each do |name| %>:<%= name %> ${action} [0:0]\n<% end %>"),
    order   => '0010',
    notify  => Service['iptables'],
  }

}
