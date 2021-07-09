

# Déclare les packages nécessaire au systeme
class dokuwiki::hosting {
  package {
    'apache2':
      ensure => present;
    'php7.3':
      ensure => present;
  }

  service {
    'apache2':
      ensure => running;
  }
}

class dokuwiki::params {
  $src_dir = "/usr/src" 
  $dokuwiki_archive = "${src_dir}/dokuwiki.tgz" 
  $dokuwiki_dir = "${src_dir}/dokuwiki-2020-07-29" 
}

class dokuwiki {
  include dokuwiki::params
  include dokuwiki::source
  include dokuwiki::hosting
}

class dokuwiki::source {
  include dokuwiki::params

  file {
    '/usr/src/dokuwiki.tgz':
      ensure => 'present',
      source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
  }

  exec {
    'dokuwiki::unarchive':
      cwd     => "${src_dir}",
      command => "tar xavf ${dokuwiki_archive}",
      creates => "${dokuwiki_dir}",
      path    => ['/bin'],
      require => File["${dokuwiki_archive}"],
  }
}

define dokuwiki::site (String $site_name, String $site_dns) {
  include dokuwiki::params

  file {
    "/var/www/${site_name}":
      ensure  => 'directory',
      owner   => 'www-data',
      group   => 'www-data',
      # mode    => '0755',
      source  => "${dokuwiki_dir}",
      recurse => true;

    "/etc/apache2/sites-available/${site_name}.conf":
      ensure  => present,
      content => template('/home/vagrant/teaching-devops-puppet-v20210628/templates/site.conf.erb'),
      require => [Package['apache2'],
      File["/var/www/${site_name}"]];

  }

  exec {
    "enable-vhost-${site_name}":
      command => "a2ensite ${site_name}",
      path    => ['/usr/bin', '/usr/sbin'],
      require => [File["/etc/apache2/sites-available/${site_name}.conf"],
                  Package['apache2']],
      notify  => Service['apache2'];
  }

  host {
    "${site_dns}":
      ip => '127.0.0.1';
  }
}

node 'control' {
}

node 'server0' {
  include dokuwiki       # les trucs génériques de dokuwiki

  dokuwiki::site {
    "siteA":
      site_name => "politique-wiki",
      site_dns  => "politique.wiki";

    "siteB":
      site_name =>  "tajineworld-com",
      site_dns  => "tajineworld.com";
  }
}

node 'server1' {
  include dokuwiki

  dokuwiki::site {
    "recettes":
      site_name => "recettes-wiki",
      site_dns  => "recettes.wiki";
  }
}
