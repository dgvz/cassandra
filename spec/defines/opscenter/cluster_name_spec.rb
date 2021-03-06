require 'spec_helper'
describe 'cassandra::opscenter::cluster_name' do
  let(:pre_condition) { [
    'define ini_setting($ensure = nil,
       $path,
       $section,
       $key_val_separator       = nil,
       $setting,
       $value                   = nil) {}'
  ] }

  context 'Test that settings can be set.' do
    let(:title) { 'MyCluster' }
    let :params do
      {
        :cassandra_seed_hosts => 'host1,host2',
      }
    end

    it {
      should contain_file('/etc/opscenter/clusters').with({
        'ensure' => 'directory',
      })
    }

    it {
      should contain_ini_setting('MyCluster:cassandra_seed_hosts').with({
        'ensure'  => 'present',
        'section' => 'cassandra',
        'setting' => 'seed_hosts',
        'value'   => 'host1,host2',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_api_port').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_bind_interface').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_connection_pool_size').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_connect_timeout').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_cql_port').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_keyspace').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_local_dc_pref').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_password').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_retry_delay').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_send_rpc').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_ssl_ca_certs').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_ssl_client_key').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_ssl_client_pem').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_ssl_validate').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_used_hosts_per_remote_dc').with({
        'ensure'  => 'absent',
      })
    }

    it {
      should contain_ini_setting('MyCluster:storage_cassandra_username').with({
        'ensure'  => 'absent',
      })
    }
  end
end
