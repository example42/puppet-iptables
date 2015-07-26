require 'spec_helper'
# require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables' do
  let(:node) { 'iptables1.example42.com' }
  let(:facts) { {
      :operatingsystem => 'ubuntu',
      :osver_maj => 12,
      :concat_basedir => '/tmp',
      :operatingsystemrelease => '12.10'
  } }
    
  it { should contain_iptables__concat_emitter('v4') }
  it { should_not contain_iptables__concat_emitter('v6') }
end

describe 'iptables' do
  let(:node) { 'iptables2.example42.com' }
  let(:facts) { {
      :operatingsystem => 'ubuntu',
      :osver_maj => 12,
      :concat_basedir => '/tmp',
      :operatingsystemrelease => '12.10'
  } }
  let(:params) { { :enable_v6 => 'true' } }
  
  it { should contain_iptables__concat_emitter('v4') }
  it { should contain_iptables__concat_emitter('v6') }
end
