# cassandra
[![Puppet Forge](http://img.shields.io/puppetforge/v/locp/cassandra.svg)](https://forge.puppetlabs.com/locp/cassandra)
[![Github Tag](https://img.shields.io/github/tag/locp/cassandra.svg)](https://github.com/locp/cassandra)
[![Build Status](https://travis-ci.org/locp/cassandra.png?branch=master)](https://travis-ci.org/locp/cassandra)
[![Coverage Status](https://coveralls.io/repos/locp/cassandra/badge.svg?branch=master&service=github)](https://coveralls.io/github/locp/cassandra?branch=master)
[![Join the chat at https://gitter.im/locp/cassandra](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/locp/cassandra?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with cassandra](#setup)
    * [What cassandra affects](#what-cassandra-affects)
    * [Beginning with cassandra](#beginning-with-cassandra)
    * [Upgrading](#upgrading)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Create a Cluster in a Single Data Center](#create-a-cluster-in-a-single-data-center)
    * [Create a Cluster in Multiple Data Centers](#create-a-cluster-in-multiple-data-centers)
    * [OpsCenter](#opscenter)
    * [DataStax Enterprise](#datastax-enterprise)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [cassandra](#class-cassandra)
    * [cassandra::datastax_agent](#class-cassandradatastax_agent)
    * [cassandra::datastax_repo](#class-cassandradatastax_repo)
    * [cassandra::firewall_ports](#class-cassandrafirewall_ports)
    * [cassandra::java](#class-cassandrajava)
    * [cassandra::opscenter](#class-cassandraopscenter)
    * [cassandra::opscenter::cluster_name](#defined-type-cassandraopscentercluster_name)
    * [cassandra::opscenter::pycrypto](#class-cassandraopscenterpycrypto)
    * [cassandra::optutils](#class-cassandraoptutils)
    * [cassandra::opscenter::setting](#defined-type-cassandraopscentersetting)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Contributers](#contributers)

## Overview

A Puppet module to install and manage Cassandra, DataStax Agent & OpsCenter

## Setup

### What cassandra affects

#### What the cassandra class affects

* Installs the Cassandra package (default **dsc22**).
* Configures settings in *${config_path}/cassandra.yaml*.
* Optionally ensures that the Cassandra service is enabled and running.
* On Ubuntu systems, optionally replace ```/etc/init.d/cassandra``` with a
  workaround for 
  [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).

#### What the cassandra::datastax_agent class affects

* Optionally installs the DataStax agent.

#### What the cassandra::datastax_agent class affects

* Optionally configures a Yum repository to install the Cassandra packages
  from (on Red Hat).
* Optionally configures an Apt repository to install the Cassandra packages
  from (on Ubuntu).

#### What the cassandra::firewall_ports class affects

* Optionally configures the firewall for the cassandra related network
  ports.

#### What the cassandra::java class affects

* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk) and the
  Java Native Access (JNA).

#### What the cassandra::opscenter class affects

* Installs the opscenter package.
* Manages the content of the configuration file
  (/etc/opscenter/opscenterd.conf).
* Manages the opscenterd service.

#### What the cassandra::opscenter::cluster_name type affects

* An optional type that allows DataStax OpsCenter to connect to a remote
  key space for metrics storage.  These files will be created in
  /etc/opscenter/clusters.  The module also creates this directory if
  required.  This functionality is only valid in DataStax Enterprise.

#### What the cassandra::opscenter::pycrypto class affects

* On the Red Hat family it installs the pycrypto library and it's
  pre-requisits (the python-devel and python-pip packages).
* Optionally installs the Extra Packages for Enterprise Linux (EPEL)
  repository.
* As a workaround for
  [PUP-3829](https://tickets.puppetlabs.com/browse/PUP-3829) a symbolic
  link is created from ```/usr/bin/pip``` to
  ```/usr/bin/pip-python```.  Hopefully this can be removed in the not
  too distant future.

#### What the cassandra::optutils class affects

* Optionally installs the Cassandra support tools (e.g. cassandra22-tools).

### Beginning with cassandra

A basic example is as follows:

```puppet
  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    seeds           => '110.82.155.0,110.82.156.3'
  }
```

### Upgrading

The following changes to the API have taken place.

#### Changes in 1.0.0

* cassandra::cassandra_package_ensure has been renamed to
  cassandra::package_ensure.
* cassandra::cassandra_package_name has been renamed to
  cassandra::package_name.

#### Changes in 0.4.0

There is now a cassandra::datastax_agent class, therefore:

* cassandra::datastax_agent_package_ensure has now been replaced with
  cassandra::datastax_agent::package_ensure.
* cassandra::datastax_agent_service_enable has now been replaced with
  cassandra::datastax_agent::service_enable.
* cassandra::datastax_agent_service_ensure has now been replaced with
  cassandra::datastax_agent::service_ensure.
* cassandra::datastax_agent_package_name has now been replaced with
  cassandra::datastax_agent::package_name.
* cassandra::datastax_agent_service_name has now been replaced with
  cassandra::datastax_agent::service_name.

Likewise now there is a new class for handling the installation of Java:

* cassandra::java_package_ensure has now been replaced with
  cassandra::java::ensure.
* cassandra::java_package_name has now been replaced with
  cassandra::java::package_name.

Also there is now a class for installing the optional utilities:

* cassandra::cassandra_opt_package_ensure has now been replaced with
  cassandra::optutils:ensure.
* cassandra::cassandra_opt_package_name has now been replaced with
  cassandra::optutils:package_name.

#### Changes in 0.3.0

* cassandra_opt_package_ensure changed from 'present' to undef.

* The manage_service option has been replaced with service_enable and
  service_ensure.

## Usage

### Create a Cluster in a Single Data Center

In the DataStax documentation _Initializing a multiple node cluster (single
data center)_
<http://docs.datastax.com/en/cassandra/2.2/cassandra/initialize/initSingleDS.html>
there is a basic example of a six node cluster with two seeds to be created in
a single data center spanning two racks.  The nodes in the cluster are:

**Node Name**  | **IP Address** |
---------------|----------------|
node0 (seed 1) | 110.82.155.0   |
node1          | 110.82.155.1   |
node2          | 110.82.155.2   |
node3 (seed 2) | 110.82.156.3   |
node4          | 110.82.156.4   |
node5          | 110.82.156.5   |

Each node is configured to use the GossipingPropertyFileSnitch and 256 virtual
nodes (vnodes).  The name of the cluster is _MyCassandraCluster_.

In this initial example, we are going to expand the example by:

* Ensuring that the software is installed via the DataStax Community
  repository by including `cassandra::datastax_repo`.  This needs to be
  executed before the Cassandra package is installed.
* That a suitable Java Runtime environment (JRE) is installed with Java Native
  Access (JNA) by including `cassandra::java`.  This need to be executed
  before the Cassandra service is started.

```puppet
node /^node\d+$/ {
  class { 'cassandra::datastax_repo':
    before => Class['cassandra']
  }

  class { 'cassandra::java':
    before => Class['cassandra']
  }

  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '110.82.155.0,110.82.156.3'
  }
}
```

The default value for the num_tokens is already 256, but it is
included in the example for clarity.

### Create a Cluster in Multiple Data Centers

To continue with the examples provided by DataStax, we look at the example
for a cluster across multiple data centers
<http://docs.datastax.com/en/cassandra/2.2/cassandra/initialize/initMultipleDS.html>.

**Node Name**  | **IP Address** | **Data Center** | **Rack** |
---------------|----------------|-----------------|----------|
node0 (seed 1) | 10.168.66.41   | DC1             | RAC1     |
node1          | 10.176.43.66   | DC1             | RAC1     |
node2          | 10.168.247.41  | DC1             | RAC1     |
node3 (seed 2) | 10.176.170.59  | DC2             | RAC1     |
node4          | 10.169.61.170  | DC2             | RAC1     |
node5          | 10.169.30.138  | DC2             | RAC1     |

For the sake of simplicity, we will confine this example to the nodes:

```puppet
node /^node[012]$/ {
  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '10.168.66.41,10.176.170.59',
    dc              => 'DC1'
  }
}

node /^node[345]$/ {
  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '10.168.66.41,10.176.170.59',
    dc              => 'DC2'
  }
}
```

We don't need to specify the rack name (with the rack parameter) as RAC1 is
the default value.

### OpsCenter

To continue with the original example within a single data center, say we
have an instance of OpsCenter running on a node called opscenter which has
an IP address of 110.82.157.6.  We add the `cassandra::datastax_agent` to
the cassandra node to connect to OpsCenter:

```puppet
node /^node\d+$/ {
  class { 'cassandra::datastax_repo':
    before => Class['cassandra']
  } ->
  class { 'cassandra::java':
    before => Class['cassandra']
  } ->
  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '110.82.155.0,110.82.156.3',
    before          => Class['cassandra::datastax_agent']
  } ->
  class { 'cassandra::datastax_agent':
    stomp_interface => '110.82.157.6'
  }
}

node /opscenter/ {
  include '::cassandra::datastax_repo' ->
  include '::cassandra' ->
  include '::cassandra::opscenter'
}
```

We have also added the `cassandra::opscenter` class for the opscenter node.

### DataStax Enterprise

After configuring the relevant repositories elsewhere in the manifest, the
following snippet works on CentOS 7 to install DSE Cassandra 4.7.0:

```puppet
class { 'cassandra':
  cluster_name   => 'MyCassandraCluster',
  config_path    => '/etc/dse/cassandra',
  package_ensure => '4.7.0-1',
  package_name   => 'dse-full',
  service_name   => 'dse',
}
```

Also with DSE, one can specify a remote keyspace for storing the metrics for
a cluster.  An example is:

```puppet
cassandra::opscenter::cluster_name { 'Cluster1':
  cassandra_seed_hosts       => 'host1,host2',
  storage_cassandra_username => 'opsusr',
  storage_cassandra_password => 'opscenter',
  storage_cassandra_api_port => 9160,
  storage_cassandra_cql_port => 9042,
  storage_cassandra_keyspace => 'OpsCenter_Cluster1'
}
```

## Reference

### Public Classes

* **cassandra**
* **cassandra::datastax_agent**
* **cassandra::datastax_repo**
* **cassandra::firewall_ports**
* **cassandra::java**
* **cassandra::opscenter**
* **cassandra::opscenter::pycrypto**
* **cassandra::optutils**

### Public Defined Types
* **cassandra::opscenter::cluster_name**

### Private Defined Types

* **cassandra::opscenter::setting**
* **cassandra::firewall_ports::rule**

### Class: cassandra

A class for installing the Cassandra package and manipulate settings in the
configuration file.

#### Parameters

##### `authenticator`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **AllowAllAuthenticator**).

##### `authorizer`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default: **AllowAllAuthorizer**).

##### `auto_snapshot`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **true**).

##### `cassandra_9822`
If set to true, this will apply a patch to the init file for the Cassandra
service as a workaround for
[CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).  This
option is silently ignored on the Red Hat family of operating systems as
this bug only affects Ubuntu systems (default **false**).

##### `cassandra_yaml_tmpl`
The path to the Puppet template for the Cassandra configuration file.  This
allows the user to supply their own customized template.  A Cassandra 1.X
compatible template called cassandra1.yaml.erb has been provided by @Spredzy
(default **cassandra/cassandra.yaml.erb**).

##### `client_encryption_enabled`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **false**).

##### `client_encryption_keystore`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **conf/.keystore**).

##### `client_encryption_keystore_password`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **cassandra**).

##### `cluster_name`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **Test Cluster**).

##### `commitlog_directory`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **/var/lib/cassandra/commitlog**).

##### `concurrent_counter_writes`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **32**).

##### `concurrent_reads`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **32**).

##### `concurrent_writes`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **32**).

##### `config_path`
The path to the cassandra configuration file.  If this is undef, it will be
changed to **/etc/cassandra/default.conf** on the Red Hat family of operating
systems or **/etc/cassandra** on Ubuntu.  Otherwise the user can specify the
path name
(default **undef**).

##### `data_file_directories`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **['/var/lib/cassandra/data']**).

##### `dc`
Sets the value for dc in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.0/cassandra/architecture/architectureSnitchesAbout_c.html
for more details
(default **DC1**).

##### `dc_suffix`
Sets the value for dc_suffix in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.0/cassandra/architecture/architectureSnitchesAbout_c.html
for more details.  If the value is *undef* then change will be made to the
snitch properties file for this setting
(default *undef*).

##### `disk_failure_policy`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default: **stop**).

##### `endpoint_snitch`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default: **SimpleSnitch**).

##### `hinted_handoff_enabled`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(defaults to **'true'**).

##### `incremental_backups`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **false**).

##### `internode_compression`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **all**).

##### `listen_address`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **localhost**).

##### `manage_dsc_repo`
DEPRECATION WARNING:  This option is deprecated.  Please include the
the ::cassandra::datastax_repo instead.

If set to true then a repository will be setup so that packages can be
downloaded from DataStax community (default **false**).

##### `native_transport_port`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **9042**).

##### `num_tokens`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **256**).

##### `package_ensure`
The status of the package specified in **package_name**.  Can be
*present*, *latest* or a specific version number (default **present**).

##### `package_name`
The name of the Cassandra package.  Must be available from a repository
(default **dsc22**).

##### `partitioner`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **org.apache.cassandra.dht.Murmur3Partitioner**)

##### `prefer_local`
Sets the value for prefer_local in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.0/cassandra/architecture/architectureSnitchesAbout_c.html
for more details.  Valid values are true, false or *undef*.  If the value is
*undef* then change will be made to the snitch properties file for this
setting
(default *undef*).

##### `rack`
Sets the value for rack in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.0/cassandra/architecture/architectureSnitchesAbout_c.html
for more details
(default **RAC1**).

##### `rpc_address`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **localhost**).

##### `rpc_port`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **9160**).

##### `rpc_server_type`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **sync**).

##### `saved_caches_directory`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **/var/lib/cassandra/saved_caches**).

##### `seeds`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **127.0.0.1**).

##### `server_encryption_internode`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **none**).

##### `server_encryption_keystore`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **conf/.keystore**).

##### `server_encryption_keystore_password`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **cassandra**).

##### `server_encryption_truststore`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **conf/.truststore**).

##### `server_encryption_truststore_password`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **cassandra**).

##### `service_enable`
Enable the Cassandra service to start at boot time.  Valid values are true
or false
(default: **true**)

##### `service_ensure`
Ensure the Cassandra service is running.  Valid values are running or stopped
(default: **running**)

##### `service_name`
The name of the service that runs the Cassandra software (default
**cassandra**).

##### `snapshot_before_compaction`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **false**).

##### `snitch_properties_file`
The name of the snitch properties file.  The full path name would be
*config_path*/*snitch_properties_file*
(default **cassandra-rackdc.properties**).

##### `ssl_storage_port`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **7001**).

##### `start_native_transport`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **true**).

##### `start_rpc`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **true**).

##### `storage_port`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **7000**).

### Class: cassandra::datastax_agent

A class for installing the DataStax agent and to point it at an OpsCenter
instance.

#### Parameters

##### `package_ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

##### `package_name`
Is passed to the package reference (default **datastax-agent**).

##### `service_ensure`
Is passed to the service reference (default **running**).

##### `service_enable`
Is passed to the service reference (default **true**).

##### `service_name`
Is passed to the service reference (default **datastax-agent**).

##### `stomp_interface`
If the value is changed from the default of *undef* then this is what is
set as the stomp_interface setting in
**/var/lib/datastax-agent/conf/address.yaml**
which connects the agent to an OpsCenter instance
(default **undef**).

### Class: cassandra::datastax_repo

An optional class that will allow a suitable repository to be configured
from which packages for DataStax Community can be downloaded.

#### Parameters

This class has no parameters.

### Class: cassandra::firewall_ports

WARNING: This feature is currently experimental.

An optional class to configure incoming network ports on the host that are
relevant to the cassandra installation.  If firewalls are being managed 
already, simply do not include this module in your manifest.

IMPORTANT: The full list of what ports should be configured is assessed at
evaluation time of the configuration. Therefore if one is to use this class,
it must be the final cassandra class included in the manifest.

#### Parameters

##### `client_ports`
Only has any effect if the `cassandra` class is defined on the node.

Allow these TCP ports to be opened for traffic
coming from the client subnets
(default **[9042, 9160]**).

##### `client_subnets`
Only has any effect if the `cassandra` class is defined on the node.

An array of the list of subnets that are to allowed connection to
cassandra::native_transport_port and cassandra::rpc_port.
(default **['0.0.0.0/0']**).

##### `inter_node_ports`
Only has any effect if the `cassandra` class is defined on the node.

Allow these TCP ports to be opened for traffic
between the Cassandra nodes
(default **[7000, 7001, 7199]**).

##### `inter_node_subnets`
Only has any effect if the `cassandra` class is defined on the node.

An array of the list of subnets that are to allowed connection to
cassandra::storage_port, cassandra::ssl_storage_port and port 7199
for cassandra JMX monitoring
(default **['0.0.0.0/0']**).

##### `inter_node_ports`
Allow these TCP ports to be opened for traffic
coming from OpsCenter subnets
(default **[7000, 7001, 7199]**).

##### `public_ports`
Allow these TCP ports to be opened for traffic
coming from public subnets the port specified in `$ssh_port` will be
appended to this list
(default **[8888]**).

##### `public_subnets`
An array of the list of subnets that are to allowed connection to
cassandra::firewall_ports::ssh_port and if cassandra::opscenter has been
included, both cassandra::opscenter::webserver_port and
cassandra::opscenter::webserver_ssl_port
(default **['0.0.0.0/0']**).

##### `ssh_port`
Which port does SSH operate on
(default **22**).

##### `opscenter_ports`
Only has any effect if the `cassandra::datastax_agent` or
`cassandra::opscenter` classes are defined.

Allow these TCP ports to be opened for traffic
coming to or from OpsCenter
appended to this list
(default **[61620, 61621]**).

##### `opscenter_subnets`
An array of the list of subnets that are to allowed connection to
port 61620 for nodes built with cassandra::opscenter and 61621 for nodes
build with cassandra::datastax_agent
(default **['0.0.0.0/0']**).

### Class: cassandra::java

A class to install a reasonably sensible Java package.

#### Parameters

##### `ensure`
Is passed to the package reference for the JRE/JDK package.  Valid values are
**present** or a version
number (default **present**).

##### `jna_ensure`
Is passed to the package reference for the JNA package.  Valid values are
**present** or a version number (default **present**).

##### `jna_package_name`
If the default value of *undef* is left as it is, then a package called
jna or libjna-java will be installed on a Red Hat family or Ubuntu system
respectively.  Alternatively, one can specify a package that is available in
a package repository to the node (default **undef**).

##### `package_name`
If the default value of *undef* is left as it is, then a package called
java-1.8.0-openjdk-headless or openjdk-7-jre-headless will be installed
on a Red Hat family or Ubuntu system respectively.  Alternatively, one
can specify a package that is available in a package repository to the
node (default **undef**).

### Class: cassandra::opscenter

This class installs and manages the DataStax OpsCenter.  Leaving the defaults
as they are will provide a running OpsCenter without any authentication on
port 8888.

#### Parameters

##### `agents_agent_certfile`
This sets the agent_certfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_agent_keyfile`
This sets the agent_keyfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_agent_keyfile_raw`
This sets the agent_keyfile_raw setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_config_sleep`
This sets the config_sleep setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_fingerprint_throttle`
This sets the fingerprint_throttle setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_incoming_interface`
This sets the incoming_interface setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_incoming_port`
This sets the incoming_port setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_install_throttle`
This sets the install_throttle setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_not_seen_threshold`
This sets the not_seen_threshold setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_deb`
This sets the path_to_deb setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_find_java`
This sets the path_to_find_java setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_installscript`
This sets the path_to_installscript setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_rpm`
This sets the path_to_rpm setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_sudowrap`
This sets the path_to_sudowrap setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_reported_interface`
This sets the reported_interface setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_runs_sudo`
This sets the runs_sudo setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_scp_executable`
This sets the scp_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_executable`
This sets the ssh_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_keygen_executable`
This sets the ssh_keygen_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_keyscan_executable`
This sets the ssh_keyscan_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_port`
This sets the ssh_port setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_sys_known_hosts_file`
This sets the ssh_sys_known_hosts_file setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_user_known_hosts_file`
This sets the ssh_user_known_hosts_file setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssl_certfile`
This sets the ssl_certfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssl_keyfile`
This sets the ssl_keyfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_tmp_dir`
This sets the tmp_dir setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_use_ssl`
This sets the use_ssl setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_audit_auth`
This sets the audit_auth setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_audit_pattern`
This sets the audit_pattern setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_method`
This sets the authentication_method setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_enabled`
This sets the enabled setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value 'False'

##### `authentication_passwd_db`
This sets the passwd_db setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_timeout`
This sets the timeout setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `cloud_accepted_certs`
This sets the accepted_certs setting in the cloud section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `clusters_add_cluster_timeout`
This sets the add_cluster_timeout setting in the clusters section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `clusters_startup_sleep`
This sets the startup_sleep setting in the clusters section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `config_file`
The full path to the OpsCenter configuration file
(default **/etc/opscenter/opscenterd.conf**).

##### `definitions_auto_update`
This sets the auto_update setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_definitions_dir`
This sets the definitions_dir setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_download_filename`
This sets the download_filename setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_download_host`
This sets the download_host setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_download_port`
This sets the download_port setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_hash_filename`
This sets the hash_filename setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_sleep`
This sets the sleep setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_ssl_certfile`
This sets the ssl_certfile setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_use_ssl`
This sets the use_ssl setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ensure`
This is passed to the package reference for **opscenter**.  Valid values are
**present** or a version number
(default **present**).

##### `failover_configuration_directory`
This sets the failover_configuration_directory setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `failover_heartbeat_fail_window`
This sets the heartbeat_fail_window setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `failover_heartbeat_period`
This sets the heartbeat_period setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `failover_heartbeat_reply_period`
This sets the heartbeat_reply_period setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `hadoop_base_job_tracker_proxy_port`
This sets the base_job_tracker_proxy_port setting in the hadoop section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_admin_group_name`
This sets the admin_group_name setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_connection_timeout`
This sets the connection_timeout setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_debug_ssl`
This sets the debug_ssl setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_name_attribute`
This sets the group_name_attribute setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_search_base`
This sets the group_search_base setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_search_filter`
This sets the group_search_filter setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_search_type`
This sets the group_search_type setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ldap_security`
This sets the ldap_security setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_opt_referrals`
This sets the opt_referrals setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_protocol_version`
This sets the protocol_version setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_search_dn`
This sets the search_dn setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_search_password`
This sets the search_password setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_server_host`
This sets the server_host setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_server_port`
This sets the server_port setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ssl_cacert`
This sets the ssl_cacert setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ssl_cert`
This sets the ssl_cert setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ssl_key`
This sets the ssl_key setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_tls_demand`
This sets the tls_demand setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_tls_reqcert`
This sets the tls_reqcert setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_uri_scheme`
This sets the uri_scheme setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_user_memberof_attribute`
This sets the user_memberof_attribute setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_user_search_base`
This sets the user_search_base setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_user_search_filter`
This sets the user_search_filter setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_level`
This sets the level setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_log_length`
This sets the log_length setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_log_path`
This sets the log_path setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_max_rotate`
This sets the max_rotate setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_resource_usage_interval`
This sets the resource_usage_interval setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `package_name`
The name of the OpsCenter package
(default **opscenter**).

##### `provisioning_agent_install_timeout`
This sets the agent_install_timeout setting in the provisioning section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `provisioning_keyspace_timeout`
This sets the keyspace_timeout setting in the provisioning section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `provisioning_private_key_dir`
This sets the private_key_dir setting in the provisioning section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_alert_on_repair_failure`
This sets the alert_on_repair_failure setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_cluster_stabilization_period`
This sets the cluster_stabilization_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_error_logging_window`
This sets the error_logging_window setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_incremental_err_alert_threshold`
This sets the incremental_err_alert_threshold setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_incremental_range_repair`
This sets the incremental_range_repair setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_incremental_repair_tables`
This sets the incremental_repair_tables setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_ks_update_period`
This sets the ks_update_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_log_directory`
This sets the log_directory setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_log_length`
This sets the log_length setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_err_threshold`
This sets the max_err_threshold setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_parallel_repairs`
This sets the max_parallel_repairs setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_pending_repairs`
This sets the max_pending_repairs setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_rotate`
This sets the max_rotate setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_min_repair_time`
This sets the min_repair_time setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_min_throughput`
This sets the min_throughput setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_num_recent_throughputs`
This sets the num_recent_throughputs setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_persist_directory`
This sets the persist_directory setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_persist_period`
This sets the persist_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_restart_period`
This sets the restart_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_single_repair_timeout`
This sets the single_repair_timeout setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_single_task_err_threshold`
This sets the single_task_err_threshold setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_snapshot_override`
This sets the snapshot_override setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `request_tracker_queue_size`
This sets the queue_size setting in the request_tracker section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `security_config_encryption_active`
This sets the config_encryption_active setting in the security section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `security_config_encryption_key_name`
This sets the config_encryption_key_name setting in the security section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `security_config_encryption_key_path`
This sets the config_encryption_key_path setting in the security section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `service_enable`
Enable the OpsCenter service to start at boot time.  Valid values are true
or false
(default: **true**)

##### `service_ensure`
Ensure the OpsCenter service is running.  Valid values are running or stopped
(default: **running**)

##### `service_name`
The name of the service that runs the OpsCenter software (default
**opscenterd**).

##### `spark_base_master_proxy_port`
This sets the base_master_proxy_port setting in the spark section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_initial_sleep`
This sets the initial_sleep setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_interval`
This sets the interval setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_report_file`
This sets the report_file setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_ssl_key`
This sets the ssl_key setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_default_api_timeout`
This sets the default_api_timeout setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_max_metrics_requests`
This sets the max_metrics_requests setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_node_detail_refresh_delay`
This sets the node_detail_refresh_delay setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_storagemap_ttl`
This sets the storagemap_ttl setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_interface`
This sets the interface setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value '0.0.0.0'

##### `webserver_log_path`
This sets the log_path setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_port`
This sets the port setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value '8888'

##### `webserver_ssl_certfile`
This sets the ssl_certfile setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_ssl_keyfile`
This sets the ssl_keyfile setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_ssl_port`
This sets the ssl_port setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_staticdir`
This sets the staticdir setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_sub_process_timeout`
This sets the sub_process_timeout setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_tarball_process_timeout`
This sets the tarball_process_timeout setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*


### Class: cassandra::opscenter::pycrypto

On the Red Hat family of operating systems, if one intends to use encryption
for configuration values then the pycrypto library is required.  This class
will install it for the user.  See
http://docs.datastax.com/en/opscenter/5.2//opsc/configure/installPycrypto.html
for more details.

This class has no effect when included on nodes that are not in the Red Hat
family.

#### Parameters

##### `ensure`
This is passed to the package reference for **pycrypto**.  Valid values are
**present** or a version number
(default **present**).

##### `manage_epel`
If set to true, the **epel-release** package will be installed
(default **false**).

##### `package_name`
The name of the PyCrypto package
(default **pycrypto**).

##### `provider`
The name of the provider of the pycrypto package
(default **pip**).

##### `reqd_pckgs`
Packages that are required to install the pycrypto package
(default **['python-devel', 'python-pip' ]**).

### Class: cassandra::optutils

A class to install the optional Cassandra tools package.

#### Parameters

##### `ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

##### `package_name`
If the default value of *undef* is left as it is, then a package called
cassandra22-tools or cassandra-tools will be installed
on a Red Hat family or Ubuntu system respectively.  Alternatively, one
can specify a package that is available in a package repository to the
node
(default **undef**).

### Defined Type cassandra::opscenter::cluster_name

With DataStax Enterprise, one can specify a remote keyspace for OpsCenter
to store metric data (this is not available in DataStax Community).

#### Parameters

##### `cassandra_seed_hosts`
This sets the seed_hosts setting in the cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_api_port`
This sets the api_port setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_bind_interface`
This sets the bind_interface setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_connection_pool_size`
This sets the connection_pool_size setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_connect_timeout`
This sets the connect_timeout setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_cql_port`
This sets the cql_port setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_keyspace`
This sets the keyspace setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_local_dc_pref`
This sets the local_dc_pref setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_password`
This sets the password setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_retry_delay`
This sets the retry_delay setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_send_rpc`
This sets the send_rpc setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_ca_certs`
This sets the ssl_ca_certs setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_client_key`
This sets the ssl_client_key setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_client_pem`
This sets the ssl_client_pem setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_validate`
This sets the ssl_validate setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_used_hosts_per_remote_dc`
This sets the used_hosts_per_remote_dc setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_username`
This sets the username setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.1/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

### Defined Type cassandra::firewall_ports::rule

Simply a defined type to be used as a macro for setting host based firewall
rules.  This is not really supposed to be used by a user (who should use the
API provided by cassandra::firewall_ports instead) but is documented
here for completeness.

#### Parameters

##### `title`
A text field that contains the protocol name and CIDR address of a subnet.

##### `port`
The number(s) of the port(s) to be opened.

### Defined Type cassandra::opscenter::setting

Simply a defined type to be used as a macro for settings in the OpsCenter
configuration file.  This is not really supposed to be used by a user (who
should use the API provided by cassandra::opscenter instead) but is documented
here for completeness.

#### Parameters

##### `service_name`
The name of the service to be notified if a change is made to the
configuration file.  Typically this would by **opscenterd**.

##### `path`
The path to the configuration file.  Typically this would by
**/etc/opscenter/opscenterd.conf**.

##### `section`
The section in the configuration file to be added to (e.g. **webserver**).

##### `setting`
The setting within the section of the configuration file to changed
(e.g. **port**).

##### `value`
The setting value to be changed to (e.g. **8888**).

## Limitations

Tested on the Red Hat family versions 6 and 7, Ubuntu 12.04 and 14.04,
Debian 7 Puppet (CE) 3.7.5 and DSC 2.

## Contributers

Contributions will be gratefully accepted.  Please go to the project page,
fork the project, make your changes locally and then raise a pull request.
Details on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

### Additional Contributers

* Yanis Guenane (GitHub [@spredzy](https://github.com/Spredzy)) provided the
Cassandra 1.x compatible template
(see [#11](https://github.com/locp/cassandra/pull/11)).

* Amos Shapira (GitHub [@amosshapira](https://github.com/amosshapira)) fixed
a bug in the requirements metadata that caused a problem with Puppetfile
(see [#34](https://github.com/locp/cassandra/pull/34)).
