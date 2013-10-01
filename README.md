# Puppet module: iptables


This is a Puppet module for iptables based on the second generation layout ("NextGen") of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42 and Dolf Schimmel - Freeaqingme

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
  * Intermediate rules are generally ACCEPTs
  * Localhost is ALLOWED

So a simple:

        class { 'iptables':
        }

  * Allows localhost and established traffic
  * Allows outbound traffic
  * Reject everything else
  * Logs all Rejected traffic

* Sane defaults:
  The situation where only the iptables class is defined provides a minimal
  skeleton. When using the Iptables class, consider using the following classes:

        class { 'iptables':
        }

        include iptables::ruleset::related_established
        include iptables::ruleset::ping
        include iptables::ruleset::broadcast
        include iptables::ruleset::multicast
        include iptables::ruleset::security

  In the subsections below you can find what these do and
  how to modify their behavior.


* Automatically include a custom subclass

        class { 'iptables':
          my_class => 'iptables::example42',
        }

### Commonly used rules

There is a set of rules provided with the Iptables package that are commonly
used. They can be found in ./manifests/rules.

#### Broadcast


        class { 'iptables':
        }

        include iptables::ruleset::broadcast

Beyond all actions described above, this will also allow all incoming broadcast
traffic (assuming $default_target = 'ACCEPT').

You can also allow it for multiple chains, by providing explicit parameters:

        class { 'iptables':
        }

        class { 'iptables::ruleset::broadcast':
          chains => [ 'INPUT', 'FORWARD' ]
        }

Options are:
* $chains The chains to configure this rule in the filter table.
  Default: [ 'INPUT' ]
* $target To accept or deny broadcast traffic.
  Allowed: ACCEPT, DROP or BLOCK
  Default: $iptables::default_target (default: ACCEPT)
* $order: The order used to sort rules within the same table/chain with.
  Default: 7500
* $log: To log packets that match this ruleset.
  Default: false
* $log_prefix: A prefix for each log line.
  Default: $iptables::log_prefix
* $log_limit_burst: The log limit-burst iptables directive.
  Default: $iptables::log_limit_burst
* $log_limit: The log limit iptables directive.
  Default: $iptables::log_limit
* $log_limit_level: The log limit-level iptables directive.
  Default: $iptables::log_limit_level

#### Default Action

The default_action ruleset is included by default, as it defines the policies
with each default chain in the Filter Table.

You can override its behavior by explicitly defining the class. E.g. if you'd
want to drop all outgoing traffic by default you could do:

        class { 'iptables':
        }

        class { 'iptables::ruleset::default_action':
          output_policy => 'drop'
        }

Options are:
* $output_policy: Policy to apply in the output chain.
  Allowed: accept, drop, reject
  Default: accept
* $input_policy: Policy to apply in the input chain.
  Allowed: accept, drop, reject
  Default: reject
* $forward_policy: Policy to apply in the forward chain.
  Allowed: accept, drop, reject
  Default: reject
* $log_type: What packets to log.
  Allowed: dropped, all, none
  Default: drop
* $log_input: What packets to log on the input chain.
  If '' is given, the value of $log_type is used.
  Allowed: dropped, all, none, ''
  Default: dropped
* $log_output: What packets to log on the output chain
  If '' is given, the value of $log_type is used.
  Allowed: dropped, all, none
  Default: dropped
* $log_forward: What packets to log on the forward chain
  If '' is given, the value of $log_type is used.
  Allowed: dropped, all, none
  Default: dropped
* $log_prefix: The prefix to use in log messages.
  Default: $iptables::log_prefix (default: 'iptables')
* $log_limit_burst: Limit-burst log directive to use.
  Default: $iptables::log_limit_burst
* $log_limit: Limit- log directive to use.
  Default: $iptables::log_limit
* $log_level: Level log directive to use.
  Default: $iptables::log_level

#### Loopback

This ruleset is included by default. It allows INPUT and OUTPUT traffic
on the loopback interface.

Options:
* $log: To log packets that match this ruleset.
  Default: false
* $log_prefix: A prefix for each log line.
  Default: $iptables::log_prefix
* $log_limit_burst: The log limit-burst iptables directive.
  Default: $iptables::log_limit_burst
* $log_limit: The log limit iptables directive.
  Default: $iptables::log_limit
* $log_limit_level: The log limit-level iptables directive.
  Default: $iptables::log_limit_level


#### ICMP

This ruleset allows you to accept or deny ICMP packets.

        class { 'iptables':
        }

        include iptables::ruleset::icmp

Beyond all default actions described above, this will also allow all ICMP
traffic.

When explicitly defining this class, you can use the following options:
* $chains The chains to configure this rule in the filter table.
  Default: [ 'INPUT', 'OUTPUT', 'FORWARD' ]
* $target To accept or deny ICMP traffic.
  Allowed: ACCEPT, DROP or BLOCK
  Default: $iptables::default_target (default: ACCEPT)
* order: The order used to sort rules within the same table/chain with.
  Default: 8500
* $log: To log packets that match this ruleset.
  Default: false
* $log_prefix: A prefix for each log line.
  Default: $iptables::log_prefix
* $log_limit_burst: The log limit-burst iptables directive.
  Default: $iptables::log_limit_burst
* $log_limit: The log limit iptables directive.
  Default: $iptables::log_limit
* $log_limit_level: The log limit-level iptables directive.
  Default: $iptables::log_limit_level

#### Invalid


        class { 'iptables':
        }

        include iptables::ruleset::invalid

Beyond all actions described above, this will also drop all packets
that iptables has classified as INVALID

Options are:
* $chains The chains to configure this rule in the filter table.
  Default: [ 'INPUT', 'FORWARD', 'OUTPUT' ]
* $target To accept or deny broadcast traffic.
  Allowed: ACCEPT, DROP or BLOCK
  Default: DROP
* order: The order used to sort rules within the same table/chain with.
  Default: 100
* $log: To log packets that match this ruleset.
  Default: true
* $log_prefix: A prefix for each log line.
  Default: $iptables::log_prefix
* $log_limit_burst: The log limit-burst iptables directive.
  Default: $iptables::log_limit_burst
* $log_limit: The log limit iptables directive.
  Default: $iptables::log_limit
* $log_limit_level: The log limit-level iptables directive.
  Default: $iptables::log_limit_level


#### PING

This ruleset allows you to accept or deny ICMP packets.

        class { 'iptables':
        }

        include iptables::ruleset::ping

Beyond all default actions described above, this will also allow all Ping
(icmp type 8) traffic.

When explicitly defining this class, you can use the following options:
* $chains The chains to configure this rule in the filter table.
  Default: [ 'INPUT', 'OUTPUT', 'FORWARD' ]
* $target To accept or deny ping traffic.
  Allowed: ACCEPT, DROP or BLOCK
  Default: $iptables::default_target (default: ACCEPT)
* order: The order used to sort rules within the same table/chain with.
  Default: 8250
* $log: To log packets that match this ruleset.
  Default: false
* $log_prefix: A prefix for each log line.
  Default: $iptables::log_prefix
* $log_limit_burst: The log limit-burst iptables directive.
  Default: $iptables::log_limit_burst
* $log_limit: The log limit iptables directive.
  Default: $iptables::log_limit
* $log_limit_level: The log limit-level iptables directive.
  Default: $iptables::log_limit_level


#### Multicast


        class { 'iptables':
        }

        include iptables::ruleset::multicast

Beyond all actions described above, this will also allow all incoming multicast
traffic (assuming $default_target = 'ACCEPT').

You can also allow it for multiple chains, by providing explicit parameters:

        class { 'iptables':
        }

        class { 'iptables::ruleset::multicast':
          chains => [ 'INPUT', 'FORWARD' ]
        }

Options are:
* $chains The chains to configure this rule in the filter table.
  Default: [ 'INPUT' ]
* $target To accept or deny multicast traffic.
  Allowed: ACCEPT, DROP or BLOCK
  Default: $iptables::default_target (default: ACCEPT)
* order: The order used to sort rules within the same table/chain with.
  Default: 7500
* $log: To log packets that match this ruleset.
  Default: false
* $log_prefix: A prefix for each log line.
  Default: $iptables::log_prefix
* $log_limit_burst: The log limit-burst iptables directive.
  Default: $iptables::log_limit_burst
* $log_limit: The log limit iptables directive.
  Default: $iptables::log_limit
* $log_limit_level: The log limit-level iptables directive.
  Default: $iptables::log_limit_level


#### Related, Established


        class { 'iptables':
        }

        include iptables::ruleset::related_established

Beyond all actions described above, this will also allow all traffic
that is RELATED or has been ESTABLISHED (basically all sessions that
have been approved of when initiating).

Options are:
* $chains The chains to configure this rule in the filter table.
  Default: [ 'INPUT', 'OUTPUT', 'FORWARD' ]
* $target To accept or deny related,established traffic.
  Allowed: ACCEPT, DROP or BLOCK
  Default: $iptables::default_target (default: ACCEPT)
* protocol: The protocol to apply this ruleset to.
  Default: ALL
* order: The order used to sort rules within the same table/chain with.
  Default: 7500

#### Security

This ruleset includes several security-related rule sets.

        class { 'iptables':
        }

        include iptables::ruleset::security

Beyond all actions described above, this will:
* Block all invalid packets
* Block a smurf attack on IPv4

The number of rulesets included by this module may be changed without notice

#### Smurf_Attack

Prevents against SMURF attacks.

        class { 'iptables':
        }

        include iptables::ruleset::smurf_attack

Beyond all actions described above, this will:
* Block a smurf attack on IPv4

Options are:
* $chains The chains to configure this rule in the filter table.
  Default: [ 'INPUT', 'FORWARD' ]
* $target To accept or deny multicast traffic.
  Allowed: DROP or BLOCK
  Default: $iptables::default_target (default: DROP)
* order: The order used to sort rules within the same table/chain with.
  Default: 600
* $log: To log packets that match this ruleset.
  Default: false
* $log_prefix: A prefix for each log line.
  Default: $iptables::log_prefix
* $log_limit_burst: The log limit-burst iptables directive.
  Default: $iptables::log_limit_burst
* $log_limit: The log limit iptables directive.
  Default: $iptables::log_limit
* $log_level: The log limit-level iptables directive.
  Default: $iptables::log_level


### FILE BASED CONFIG:

If you're considering to use this mode, make sure to thoroughly review the possibilities
of the concat mode first.

* Use custom sources for iptables file

        class { 'iptables':
          mode => 'file', # This is needed to activate file mode
          source => [ "puppet:///modules/lab42/iptables/iptables-${hostname}" , "puppet:///modules/lab42/iptables/iptables" ],
        }


* Use custom template for iptables file. Note that template and source arguments are alternative.

        class { 'iptables':
          mode => 'file', # This is needed to activate file mode
          template => 'example42/iptables/iptables.conf.erb',
        }

### CONCAT MODE SPECIFIC USER VARIABLES:

* $enableICMPHostProhibited *

When a packet is rejected, an ICMP host prohibited packet will be returned if
set to true.


#### Logging
* $log *

Define what you what to log (`all` | `dropped` | `none`)

* $log_prefix *

The prefix to use for logged lines. Defaults to 'iptables'

* $log_limit_burst *

The iptables log limit-burst directive. Defaults to 10

* $log_limit*

The iptables log limit. Defaults to '30/m'

* $log_level *

Define the level of logging (numeric or see `syslog.conf(5)`)

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


### A note on ordering of firewall rules

In the world of firewalling, the order of rules matters, and is the case with
Iptables. Whenever a packet matches within a chain, further processing of that
chain is aborted (except for some notable exceptions like the LOG target).

Therefore, it's a common- and best-practice to put the most specific rules on
top of your firewall configuration, and the least specific ones on the bottom.

To accomodate this, within the Iptables module each rule has an $order
parameter that should be between 1 and 10000. The order indexes don't have to
be used as unique, however. Say you want to allow all traffic to your SSH and
Webserver, you could use two rules that have the same order index:
        5000        -A INPUT -p tcp --dport 22 -J ACCEPT
        5000        -A INPUT -p tcp --dport 80 -j ACCEPT

If you want to later add a blaclist, you would have to use different (lower)
order indexes:

        2000        -A INPUT -p tcp --dport 80 -s 192.168.1.206 -J DROP
        2000        -A INPUT -p tcp --dport 80 -s 10.0.0.123    -J DROP
        5000        -A INPUT -p tcp --dport 22 -J ACCEPT
        5000        -A INPUT -p tcp --dport 80 -j ACCEPT

It's important to make sure to spread out related rules with plenty of space.
In the future, you may want to add additional related rules that should go
between the ones you already have. Spreading them will ensure you don't
have to reorder your existing rules.

#### Default rules and their order

All rules created by the Iptables module have a default order index that can
often be overriden if desired. The following scheme has been adhered and
suggested:

1 - 150 Used for 'initialization' of chains and logging
          1.  Table definition
          10. Chain definition
250  - 750  Fraud prevention
1000 - 6000 Specific rules
7000 - 9500 Generic rules
9500 - 9999 Related to closing the Chain, like default action and COMMIT.

What you consider 'specific' and 'generic' is up to you. A definition could be
that all rules containing a source address are specific, whereas the others are
generic.

##### Optimization

Please be aware that you should not order rules with the sole intention of
optimizing your firewall configuration. Iptables is very fast, and chances
are very slim that you'll notice any difference in performance by reordering
rules.
