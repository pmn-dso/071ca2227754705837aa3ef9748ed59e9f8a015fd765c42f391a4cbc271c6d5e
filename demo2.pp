file { 
  '/tmp/hello':
    ensure  => 'present',
    content => 'Hello World',
    path    => '/tmp/hello',
    group   => 'root',
    owner   => 'root',
    mode    => '0600';
}
