class testRule {
  include iptables
  
  rule { 'test':
    source        => '0.0.0.0/0',
    v6source      = '',
    destination   => '0.0.0.0/0',
    v6destination => '',
    port          => '123',
  }
}