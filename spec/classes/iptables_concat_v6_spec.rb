require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables::concat_v6' do
  let(:node) { 'iptables_concat_v6.example42.com' }
  let(:facts) { { :operatingsystem => 'ubuntu', :osver_maj => 12  } }
    
  it { should contain_concat__fragment('iptables_filter_input_footer_v6').with(
    #'content' => '-A INPUT -p icmpv6 -j ACCEPT',
  ) }
end
