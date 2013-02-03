require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables::rule' do

  let(:title) { 'iptables::rule' }
  let(:node) { 'rspec.example42.com' }

  describe 'Test rule with default args' do
    let(:params) { { 'name' => 'sample1' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample1').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp  -s 0\/0 -d 0\/0 -j ACCEPT/)
    end
  end

  describe 'Test rule with single source' do
    let(:params) { { 'name' => 'sample2', 'source' => '1.2.3.4/5' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample2').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp  -s 1\.2\.3\.4\/5 -d 0\/0 -j ACCEPT/)
    end
  end

  describe 'Test rule with multiple sources' do
    let(:params) { { 'name' => 'sample3', 'source' => ['6.7.8.9/10', '127.0.0.1/32'] } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample3').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp  -s 6\.7\.8\.9\/10 -d 0\/0 -j ACCEPT/)
      content.should match(/-A INPUT -p tcp  -s 127\.0\.0\.1\/32 -d 0\/0 -j ACCEPT/)
    end
  end

  describe 'Test rule with single destination' do
    let(:params) { { 'name' => 'sample4', 'destination' => '1.2.3.4/5' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample4').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp  -s 0\/0 -d 1\.2\.3\.4\/5 -j ACCEPT/)
    end
  end

  describe 'Test rule with multiple sources' do
    let(:params) { { 'name' => 'sample5', 'destination' => ['6.7.8.9/10', '127.0.0.1/32'] } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample5').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp  -s 0\/0 -d 6\.7\.8\.9\/10 -j ACCEPT/)
      content.should match(/-A INPUT -p tcp  -s 0\/0 -d 127\.0\.0\.1\/32 -j ACCEPT/)
    end
  end

  describe 'Test rule with custom command' do
    let(:params) { { 'name' => 'sample6', 'command' => '-R' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample6').send(:parameters)[:content]
      content.should match(/-R INPUT -p tcp  -s 0\/0 -d 0\/0 -j ACCEPT/)
    end
  end

  describe 'Test rule with custom chain' do
    let(:params) { { 'name' => 'sample7', 'chain' => 'FORWARD' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample7').send(:parameters)[:content]
      content.should match(/-A FORWARD -p tcp  -s 0\/0 -d 0\/0 -j ACCEPT/)
    end
  end

  describe 'Test rule with custom target' do
    let(:params) { { 'name' => 'sample8', 'target' => 'DROP' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample8').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp  -s 0\/0 -d 0\/0 -j DROP/)
    end
  end

  describe 'Test rule with custom protocol' do
    let(:params) { { 'name' => 'sample9', 'protocol' => 'udp' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample9').send(:parameters)[:content]
      content.should match(/-A INPUT -p udp  -s 0\/0 -d 0\/0 -j ACCEPT/)
    end
  end

  describe 'Test rule with port' do
    let(:params) { { 'name' => 'sample10', 'port' => '22' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample10').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp --dport 22 -s 0\/0 -d 0\/0 -j ACCEPT/)
    end
  end

  describe 'Test rule without destination' do
    let(:params) { { 'name' => 'sample11', 'destination' => '' } }

    it 'should generate a valid fragment' do
      content = catalogue.resource('concat::fragment', 'iptables_rule_sample11').send(:parameters)[:content]
      content.should match(/-A INPUT -p tcp  -s 0\/0 -j ACCEPT/)
    end
  end

end
