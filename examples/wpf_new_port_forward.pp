# @PDQTestWin
windows_port_forwarding { 'port forward':
  ensure     => present,
  protocol   => 'v4tov4',
  listen_on  => '*:8990',
  connect_on => "${$facts['networking']['ip']}:8988";
}

windows_port_forwarding { "${$facts['networking']['ip']}:9090":
  ensure     => present,
  protocol   => 'v4tov4',
  connect_on => '*:8988';
}
