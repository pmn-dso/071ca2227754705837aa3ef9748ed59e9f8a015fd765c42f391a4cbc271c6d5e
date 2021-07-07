# Étape 2
package {

  'php7.3':
    ensure => 'present',
    name   => 'php7.3';

  'apache2':
    ensure => 'present';
}

# Étape 3

exec { 
  'wget-dokuwiki':
    cwd     => '/usr/src',
    command => '/usr/bin/wget -O /usr/src/dokuwiki.tgz https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz';
}

# Étape 4

exec { 
  'Extraction-dokuwiki':
    cwd     => '/usr/src',
    command => 'tar -xzvf dokuwiki.tgz',
    creates => '/usr/src/dokuwiki',
    path    => ['/usr/bin', '/usr/sbin',],
}
