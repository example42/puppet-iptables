# Class iptables::debian
#
class iptables::debian {

  # Load the variables used in this module. Check the params.pp file
  require iptables::params

  # We use iptables-persistent to keep coherency with the module layout
  package { 'iptables-persistent':
    ensure => present,
    name   => 'iptables-persistent',
    before => Service['iptables'],
  }

  file { '/etc/iptables':
    ensure => directory,
  }
}
