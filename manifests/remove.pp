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
}
