require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables::rule' do
  let(:title) { 'iptable1' }
  let(:node) { 'iptable.example42.com' }
  let(:facts) { { :operatingsystem => 'ubuntu' } }
  let(:params) {
    { 'source'        => '0/0',
      'v6source'      => '',
      'destination'   => '0/0',
      'v6destination' => '',
      'protocol'      => 'tcp',
      'port'          => '',
    }
  }
  
  it { should contain_notify("test1") }
  
end
