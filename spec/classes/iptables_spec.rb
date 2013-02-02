require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables' do
  let(:node) { 'iptables.example42.com' }
  let(:facts) { { :operatingsystem => 'ubuntu' } }
    
  describe 'Test iptables without' do
    it { should include_class('iptables::concat') }
    it { should_not include_class('iptables::concat_v6') }
  end
  
  describe 'Test iptables with v6 switched on' do
    let(:params) { { :enable_v6 => 'true' } }
    it { should include_class('iptables::concat') }
    it { should include_class('iptables::concat_v6') }
  end
end
