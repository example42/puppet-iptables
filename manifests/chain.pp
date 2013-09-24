
define iptables::chain (
  $table,
  $chain_name,
  $ip_version = 6,
) {
  
  concat::fragment{ "iptables_chain_${name}":
    target  => "/var/lib/puppet/iptables/tables/v${ip_version}_${table}",
    content => inline_template("<% @chain_name.each do |name| %>:<%= name %> ACCEPT [0:0]\n<% end %>"),
    order   => 10,
    notify  => Service['iptables'],
  }
  
}
