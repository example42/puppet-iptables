require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'iptables::concat_emitter' do
  let(:node) { 'iptables_concat.example42.com' }
  let(:facts) { { :operatingsystem => 'ubuntu', :osver_maj => 12, :concat_basedir => '/tmp', :operatingsystemrelease => '12.10'  } }
  let(:title) { 'v6' }
  let(:params) {
      { 'emitter_target'  => '/anfile',
        'is_ipv6'         => true,
      }
    }
    
  it { should contain_concat__fragment('iptables_filter_input_footer_v6').with_content("-A INPUT -p icmpv6 -j ACCEPT\n-A INPUT -m pkttype --pkt-type broadcast -j ACCEPT\n-A INPUT -m pkttype --pkt-type multicast -j ACCEPT\n-A INPUT -j LOG --log-level 4 --log-prefix \"INPUT DROP: \"\n-A INPUT -j DROP\n") }
end
