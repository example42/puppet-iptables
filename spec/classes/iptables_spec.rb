require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables' do
  let(:node) { 'iptables.example42.com' }
  let(:facts) { { :operatingsystem => 'ubuntu' } }
  let(:params) { { :safe_ssh => 'true' } }
  
  describe 'Test standard installation' do
    it { should contain_package('iptables').with_ensure('present') }
  end
  
  describe 'Test IPv6' do
    it { should include_class('iptables::concat') }
    it { should include_class('iptables::concat_v6') }
  end
end
