require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables::concat_emitter' do
  let(:node) { 'iptables_concat.example42.com' }
  let(:facts) { { :operatingsystem => 'ubuntu', :osver_maj => 12  } }
  let(:title) { 'v6' }
  let(:params) {
      { 'emitter_target'  => 'anfile',
        'real_icmp_port'  => '-p icmpv6',
      }
    }
    
  it { should contain_concat__fragment('iptables_filter_input_footer_v6').with(
    #'content' => '-A INPUT -p icmpv6 -j ACCEPT',
  ) }
end
