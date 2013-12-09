# Puppet module: iptables


This is a Puppet module for iptables based on the second generation layout ("NextGen") of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-iptables

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module (you need it even if you don't use and install Puppi)

## DESCRIPTION:
This module manages iptables.
In order to have functionality and flexibility some design decisions have been enforced:

* Rules are based on a iptables-save format file. 
* On RedHat/Centos systems it has been followed the standard iptables service approach
* On Debian/Ubuntu the same approach is achived via the iptables-persistent package
* Custom firewall solutions and builders are ignored or disabled (Shorewall, Ufw...) 

The rules configuration can be made in two ways:

* File Mode: Providing custom iptables files (as static files or templates)
* Concat Mode: Buildind up rules files with concat (this is the default choice and allows
  dynamic automatic firewalling rules with Example42 firewall extension)

## USAGE - Overrides and Customizations
* Default usage (Concat mode). It follows these defaults:
  * Default policy is ACCEPT (to permit reachability in case of syntax errors)
  * Last rule of every chain is a DENY as defined by $iptables_block_policy
  * Intermediate rules are generally ACCEPTs
  * Localhost and established traffic is ALLOWED

So a simple:

        class { 'iptables':
        }

  * Allows SSH access on port TCP 22
  * Allows ping and all ICMP packets
  * Allows localhost and established traffic
  * Allows outbound traffic
  * Allows multicast and broadcast traffic
  * Blocks everything else


* Use custom sources for iptables file

        class { 'iptables':
          config => 'file', # This is needed to activate file mode
          source => [ "puppet:///modules/lab42/iptables/iptables-${hostname}" , "puppet:///modules/lab42/iptables/iptables" ], 
        }


* Use custom template for iptables file. Note that template and source arguments are alternative. 

        class { 'iptables':
          config => 'file', # This is needed to activate file mode
          template => 'example42/iptables/iptables.conf.erb',
        }

* Automatically include a custom subclass

        class { 'iptables':
          my_class => 'iptables::example42',
        }


### CONCAT MODE SPECIFIC USER VARIABLES:

In concat mode some parameters define the general behaviour:

* $block_policy *

Define what to do with packets not expressively accepted:

* `drop` (Default) - DROP them silently
* `reject` - REJECT them with ICMP unreachable
* `accept` - ACCEPT them (Beware, if you do this you have no firewall :-)

* $icmp_policy *

Define what to to with ICMP packets

* `drop` - DROP them all
* `safe` - ALLOW all ICMP types except echo & reply (Ping) 
* `accept` (Default) - ACCEPT them all

* $output_policy *

Define what to to with outbound packets
* `drop` - DROP them (except for established and localhost 
* `accept` (Default) - ACCEPT them 

* $log *

Define what you what to log (`all` | `dropped` | `none`)

* $log_level *

Define the level of logging (numeric or see `syslog.conf(5)`)

* $safe_ssh *

Define if you want to force the precence of a rule that allows access to SSH port (tcp/22).

* $broadcast_policy *

Define what to do with INPUT broadcast packets

* `drop` - Treat them with the $iptables_block_policy 
* `accept` (Default) - Expressely ACCEPT them

* $multicast_policy * 

Define what to do with INPUT multicast

* "drop" - Treat them with the $iptables_block_policy
* "accept" (Default) - Expressely ACCEPT them

So for example for a stricter setup, compared to default:

        class { 'iptables':
          config           => 'concat', # This enforces concat mode (Default value)
          safe_ssh         => false,
          broadcast_policy => 'drop',
          multicast_policy => 'drop',
          icmp_policy      => 'drop',
          output_policy    => 'drop',
        }

### IPv6 specific configuration
In order to enable IPv6 there have to be configured two parts:
- iptables should be IPv6 enabled:
          class{ 'iptables' :
            enable_v6 => true,
          }
- then iptables::rules can be IPv6 enabled also:
        iptables::rule { 'http': 
          port       => '80',
          protocol   => 'tcp',
          enable_v6  => true,
        }
        
If specific source / destination adresses should be used, a definition will look like: 
        iptables::rule { 'http':
          source          => '10.42.0.0/24',
          source_v6       => '2001:0db8:3c4d:0015:0000:0000:abcd:ef12',
          destination     => '$ipaddress_eth0',
          destination_v6  => '2001:470:27:37e::2/64', 
          port            => '80',
          protocol        => 'tcp',
          enable_v6       => true,
        }

### Usage of iptables module with Example42 automatic firewalling 

The concat mode of this module is particularly useful when used with Example42's
automatic firewalling features.

You can enable them either setting a topscope variable or passing the firewall => true
parameter to a (nextgen) class.

You have also to set firewall_tool => 'iptables'.

So, for example, you can enable site wide automatic firewalling with:

        $::firewall = true
        $::firewall_tool = 'iptables'

and then whenever you add a NextGen Example42 module to a node, it's port is automatically openened (to every ip).

If you want to have better control on who can access to that port, you can use the firewall_src parameter and you can define the destination IP with the firewall_dst one.
For example the following accepts connections on MySql port only form 10.42.42.42/32 on eth1:

        class { 'mysql':
          firewall_src  => '10.42.42.42/32', # Allowed source
          firewall_dst  => $ipaddress_eth1,  # Destination IP (default is $ipaddress
        }


###  Module specific defines

All the single rules in Concat mode are managed by the iptables::rule define.
You can use it to automatically allow access from all your nodes when you don't know their address upstream (for example in the cloud)

        @@firewall { $hostname:
          source => $ipaddress,
          tag    => prod,
        }
        Firewall <| tag == prod |>

If you have a single node from where you want to ensure access you can also do something like:

        firewall { 'alfa': source => '42.42.42.42', }

[![Build Status](https://travis-ci.org/example42/puppet-iptables.png?branch=master)](https://travis-ci.org/example42/puppet-iptables)

