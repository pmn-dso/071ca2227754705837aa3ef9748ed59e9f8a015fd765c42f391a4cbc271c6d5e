
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

class wiki {
  file { "/var/www/${site_name}":
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    path    => "/var/www/${site_name}",
    recurse => true;
  }
  file { "copie-conf-vhost-${site_name}":
    before  => Exec['conf-vhost'],
    ensure  => 'present',
    owner   => 'www-data',
    group   => 'www-data',
    source  => '/etc/apache2/sites-available/000-default.conf',
    path    => "/var/www/${site_name}/${site_name}.conf";
  }
  exec { "activation-vhost-${site_name}":
    require => Exec['link-vhost'],
    command => "a2ensite ${site_name}",
    path    => ['/usr/bin', '/usr/sbin',],
    notify => Service['apache2']
  }
  exec { 'conf-vhost':
    command => "sed -i 's/html/${site_name}/g' /var/www/${site_name}/${site_name}.conf && sed -i 's/#ServerName www.example.com/ServerName ${site_name}.wiki/g' /var/www/${site_name}/${site_name}.conf",
    path    => ['/usr/bin', '/usr/sbin',];
  }
  exec { 'link-vhost':
    require => Exec['conf-vhost'],
    command => "ln -s /var/www/${site_name}/${site_name}.conf /etc/apache2/sites-available/${site_name}.conf",
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
  $site_name = ['politique']
  include hosting
  include dokuwiki
  include wiki
  include vhost
}

node 'server1' {
  $site_name = ['recettes']
  include hosting
  include dokuwiki
  include wiki
  include vhost
}

