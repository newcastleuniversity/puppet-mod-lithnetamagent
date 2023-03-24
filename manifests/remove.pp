# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lithnetamagent::remove
class lithnetamagent::remove {
  $packagename = lookup('lithnetamagent::packagename')

  service { 'LithnetAccessManagerAgent' :
    ensure => 'stopped',
    enable => 'false',
  }

  package { 'LithnetAccessManagerAgent' :
    ensure => 'absent',
    name   => $packagename,
  }

  file { '/etc/LithnetAccessManagerAgent.conf' :
    ensure => 'absent',
  }

  case $facts['os']['family'] {
    'RedHat' : {
      # Install the Lithnet RPM repo
      # Note: Lithnet don't GPG sign their packages so gpgcheck is disabled
      yumrepo { 'lithnet-am-repo':
        ensure  => 'absent',
        baseurl => "https://packages.lithnet.io/linux/rpm/prod/repos/rhel/${facts['os']['release']['major']}",
      }
    }
    'Debian' : {
      include apt

      $realosname = downcase($facts['os']['name'])

      apt::source { 'Lithnet' :
        ensure   => 'absent',
        location => "https://packages.lithnet.io/linux/deb/prod/repos/${realosname}",
      }
    }
    # If we've ended up here, then this module doesn't currently support the OS
    default : {
      notify { 'Remove the Lithnet source yourself' : }
    }
  }
}
