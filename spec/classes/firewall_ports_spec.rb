require 'spec_helper'
describe 'cassandra::firewall_ports' do
  let(:pre_condition) { [
    'class cassandra () {}',
    'define firewall ($action, $dport, $proto, $source) {}',
  ] }

  let!(:stdlib_stubs) {
    MockFunction.new('prefix') { |f|
      f.stubbed.with(['0.0.0.0/0'],
        '200_Public_').returns('200_Public_0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
        '210_InterNode_').returns('210_InterNode__0.0.0.0/0')
      f.stubbed.with(['0.0.0.0/0'],
        '220_Client_').returns('220_Client__0.0.0.0/0')
    }
    MockFunction.new('concat') { |f|
      f.stubbed().returns([8888, 22])
    }
    MockFunction.new('size') { |f|
      f.stubbed().returns(42)
    }
  }

  context 'Run with defaults.' do
    it { should compile }

    it {
      should contain_class('cassandra::firewall_ports').with({
        'client_subnets'              => ['0.0.0.0/0'],
        'inter_node_subnets'          => ['0.0.0.0/0'],
        'public_subnets'              => ['0.0.0.0/0'],
        'ssh_port'                    => 22,
        'opscenter_subnets'           => ['0.0.0.0/0']
      })
    }

    it {
      should contain_cassandra__firewall_ports__rule('200_Public_0.0.0.0/0').with({
        'ports' => [8888, 22]
      })
    }
  end
end
