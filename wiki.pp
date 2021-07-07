# Étape 2
package {

  'php7.3':
    ensure => 'present',
    name   => 'php7.3';

  'apache2':
    ensure => 'present';
}

# Étape 3

file { 
  '/usr/src/dokuwiki.tgz':
    ensure         => 'present',
    source         => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
    path           => '/usr/src/dokuwiki.tgz',
    checksum_value => '8867b6a5d71ecb5203402fe5e8fa18c9',
}

#exec { 
#  'wget-dokuwiki':
#    cwd     => '/usr/src',
#    command => '/usr/bin/wget -O /usr/src/dokuwiki.tgz https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz';
#}

# Étape 4

exec { 
  'Extraction-dokuwiki':
    cwd     => '/usr/src',
    command => 'tar -xzvf dokuwiki.tgz',
    creates => '/usr/src/dokuwiki',
    path    => ['/usr/bin', '/usr/sbin',],
}

file {
  'deplacement de dokuwiki':
    ensure => 'present',
    source => '/usr/src/dokuwiki-2020-07-29',
    path   => '/usr/src/dokuwiki';
}
