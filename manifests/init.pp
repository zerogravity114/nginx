# Puppet module for installing and configuring nginx web server per requirements
# for Puppet Labs technical challenge

class nginx {

  case $::operatingsystem {
    'redhat' : {
      $nginx_repo = 'puppet:///modules/nginx/nginx.repo.rhel'
    }

    'centos' : {
      $nginx_repo = 'puppet:///modules/nginx/nginx.repo.cent'
    }
  }

  # nginx is not part of the RHEL repos.  So we need to add a repo
  file { '/etc/yum.repos.d/nginx.repo': 
    ensure => file,
    source => $nginx_repo,
    owner  => 'root',
    mode   => '0644',
  }

  package { 'nginx':
    ensure  => present,
    require => File['/etc/yum.repos.d/nginx.repo'], #Make sure the repo is installed first
  }

  file { '/usr/share/nginx':
    ensure => directory,
    owner  => 'root',
    mode   => '0755',
  }

  file { '/usr/share/nginx/html':
    ensure  => directory,
    owner   => 'root',
    mode    => '0755',
    require => File['/usr/share/nginx'],
  }

  file { '/etc/nginx/conf.d/default.conf':
    ensure  => file,
    owner   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/nginx/default.conf',
    require => Package['nginx'], #The installer will overwrite this file, so make sure we create it after the package is installed
  }
  
  service { 'nginx':
    enable    => true,
    ensure    => true,
    require   => Package['nginx'],
    subscribe => File['/etc/nginx/conf.d/default.conf'],
  }
  
  file { '/usr/share/nginx/html/index.html':
    ensure  => file,
    owner   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/nginx/index.html',
    require => Package['nginx'],
  }
}
