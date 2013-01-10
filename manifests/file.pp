#
# Class iptables::file
#
# This class configures iptables via a base rule file
# The file itselt is not provided. Use this class (or, better,
# your custom $my_project class that inherits this) to
# manage the iptables file in the way you want
#
# It's used if $iptables_config = "file"
#
class iptables::file inherits iptables {

  file { 'iptables.conf':
    ensure  => $iptables::manage_file,
    path    => $iptables::config_file,
    mode    => $iptables::config_file_mode,
    owner   => $iptables::config_file_owner,
    group   => $iptables::config_file_group,
    require => Package['iptables'],
    notify  => $iptables::manage_service_autorestart,
    source  => $iptables::manage_file_source,
    content => $iptables::manage_file_content,
    replace => $iptables::manage_file_replace,
    audit   => $iptables::manage_audit,
  }

}
