
class development {
  package {
    'vim':
      ensure =>  installed;
    'make':
      ensure =>  installed;
    'gcc':
      ensure =>  installed;
  }
}

class hosting {
  package {
    'apache2':
      ensure =>  installed;
    'php7.3':
      ensure =>  installed;
  }
}

class dokuwiki {
  file { '/usr/src/dokuwiki.tgz':
    ensure         => 'present',
    source         => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
    path           => '/usr/src/dokuwiki.tgz',
    checksum_value => '8867b6a5d71ecb5203402fe5e8fa18c9',
  }

  exec { 'extraction-dokuwiki':
    require => File['/usr/src/dokuwiki.tgz'],
    cwd     => '/usr/src',
    command => 'tar -xzvf dokuwiki.tgz',
    creates => '/usr/src/dokuwiki',
    path    => ['/usr/bin', '/usr/sbin',],
  }

  exec { 'deplacement de dokuwiki':
    require => Exec['extraction-dokuwiki'],
    cwd     => '/usr/src/',
    command => 'mv dokuwiki-2020-07-29/ dokuwiki',
    path    => ['/usr/bin', '/usr/sbin',],
  }
}

class politique {
  file { '/var/www/politique':
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    path    => '/var/www/politique',
    recurse => true;
  }
  file { 'copie-conf-vhost-politique':
    before  => Exec['conf-vhost'],
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    source  => '/etc/apache2/sites-available/000-default.conf',
    path    => '/var/www/politique/politique.conf';
  }
  exec { 'activation-vhost-politique':
    require => Exec['link-vhost'],
    command => 'a2ensite politique',
    path    => ['/usr/bin', '/usr/sbin',],
    notify => Service['apache2']
  }
  exec { 'conf-vhost':
    command => 'sed -i \'s/html/politique/g\' /var/www/politique/politique.conf && sed -i \'s/#ServerName www.example.com/ServerName politique.wiki/g\' /var/www/politique/politique.conf',
    path    => ['/usr/bin', '/usr/sbin',];
  }
  exec { 'link-vhost':
    require => Exec['conf-vhost'],
    command => 'ln -s /var/www/politique/politique.conf /etc/apache2/sites-available/politique.conf',
    path    => ['/usr/bin', '/usr/sbin',];
  }
}

class recettes {
  file { '/var/www/recettes':
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    path    => '/var/www/recettes',
    recurse => true;
  }

  file { 'copie-conf-vhost-recettes':
    before  => Exec['conf-vhost'],
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    source  => '/etc/apache2/sites-available/000-default.conf',
    path    => '/var/www/recettes/recettes.conf';
  }

  exec { 'activation-vhost-recettes':
    require => Exec['link-vhost'],
    command => 'a2ensite recettes',
    path    => ['/usr/bin', '/usr/sbin',],
    notify => Service['apache2']
  }

  exec { 'conf-vhost':
    command => 'sed -i \'s/html/recettes/g\' /var/www/recettes/recettes.conf && sed -i \'s/#ServerName www.example.com/ServerName recettes.wiki/g\' /var/www/recettes/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin',];
  }
  exec { 'link-vhost':
    require => Exec['conf-vhost'],
    command => '  ln -s /var/www/recettes/recettes.conf /etc/apache2/sites-available/recettes.conf',
    path    => ['/usr/bin', '/usr/sbin',];
  }
}

class vhost {
  service { 'apache2':
    ensure => running;
  }
}

node 'control' {
  include development
}

node 'server0' {
  include hosting
  include dokuwiki
  include politique
  include vhost
}

node 'server1' {
  include hosting
  include dokuwiki
  include recettes
  include vhost
}

