package { 
  
  'php7.3':
    ensure  => 'installed';

  'apache2':
    ensure => 'present';

}

file { '/usr/src/dokuwiki.tgz':
  ensure         => 'present',
  source         => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
  path           => '/usr/src/dokuwiki.tgz',
  checksum_value => '8867b6a5d71ecb5203402fe5e8fa18c9';

  '/var/www/politique':
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    path    => '/var/www/politique',
    recurse => true;

  '/var/www/recettes':
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    path    => '/var/www/recettes',
    recurse => true;

  'copie-conf-vhost-politique':
    before  => Exec['conf-vhost'],
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    source  => '/etc/apache2/sites-available/000-default.conf',
    path    => '/var/www/politique/politique.conf';

  'copie-conf-vhost-recettes':
    before  => Exec['conf-vhost'],
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    source  => '/etc/apache2/sites-available/000-default.conf',
    path    => '/var/www/recettes/recettes.conf';
}

exec { 'extraction-dokuwiki':
  require => File['/usr/src/dokuwiki.tgz'],
  cwd     => '/usr/src',
  command => 'tar -xzvf dokuwiki.tgz',
  creates => '/usr/src/dokuwiki',
  path    => ['/usr/bin', '/usr/sbin',];

  'deplacement de dokuwiki':
    require => Exec['extraction-dokuwiki'],
    cwd     => '/usr/src/',
    command => 'mv dokuwiki-2020-07-29/ dokuwiki',
    path    => ['/usr/bin', '/usr/sbin',];
  
  'conf-vhost':
    command => 'sed -i \'s/html/politique/g\' /var/www/politique/politique.conf && sed -i \'s/#ServerName www.example.com/ServerName politique.wiki/g\' /var/www/politique/politique.conf && sed -i \'s/html/recettes/g\' /var/www/recettes/recettes.conf && sed -i \'s/#ServerName www.example.com/ServerName recettes.wiki/g\' /var/www/recettes/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin'];

  'link-vhost':
    require => Exec['conf-vhost'],
    command => 'ln -s /var/www/politique/politique.conf /etc/apache2/sites-available/politique.conf && ln -s /var/www/recettes/recettes.conf /etc/apache2/sites-available/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin',];

  'activation-vhost-politique':
    require => Exec['link-vhost'],
    command => 'a2ensite politique',
    path    => ['/usr/bin', '/usr/sbin',],
    notify => Service['apache2'];

  'activation-vhost-recettes':
    require => Exec['link-vhost'],
    command => 'a2ensite recettes',
    path    => ['/usr/bin', '/usr/sbin',],
    notify => Service['apache2'];

}

service { 'apache2':
  ensure => running;
}
