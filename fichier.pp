file { 
  '/tmp/hello':
    ensure  => 'present',
    content => 'Hello World',
    path    => '/tmp/hello',
    group   => 'root';
}
