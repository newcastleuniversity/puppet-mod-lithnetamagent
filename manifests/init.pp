# lithnetamagent
#
# Main class
#
# @summary This module manages the Lithnet Access Manager agent package.
#
# @example Declaring the class
#   include lithnetamagent
#
# @param register_agent
#   Register the agent with an AMS server
#
# @param ams_server
#   Specify hostname of AMS server
#
# @param reg_key
#   Agent registration key
class lithnetamagent (
  Boolean          $register_agent = false,
  Optional[String] $ams_server     = undef,
  Optional[String] $reg_key        = undef,
) {
  # Check that we're running on a supported platform
  if $facts['os']['family'] == 'RedHat' and !($facts['os']['release']['major'] in ['7','8','9']) {
    fail("Current os.release.major is ${::facts['os']['release']['major']} and must be 7, 8 or 9")
  }
  if $facts['os']['name'] == 'Ubuntu' and !($facts['os']['release']['major'] in ['18.04','20.04','22.04']) {
    fail("Current os.release.major is ${::facts['os']['release']['major']} and must be 18.04, 20.04, or 22.04")
  }

  $packagename = lookup('lithnetamagent::packagename')

  case $facts['os']['family'] {
    'RedHat' : {
      # Install the Lithnet RPM repo
      # Note: Lithnet don't GPG sign their packages so gpgcheck is disabled
      yumrepo { 'lithnet-am-repo':
        baseurl  => "https://packages.lithnet.io/linux/rpm/prod/repos/rhel/${facts['os']['release']['major']}",
        descr    => 'Lithnet Access Manager agent',
        enabled  => 1,
        gpgcheck => 0,
        before   => Package['LithnetAccessManagerAgent'],
      }
    }
    'Debian' : {
      include apt

      $realosname = downcase($facts['os']['name'])

      apt::source { 'Lithnet' :
        location => "https://packages.lithnet.io/linux/deb/prod/repos/${realosname}",
        release  => $facts['os']['distro']['codename'],
        repos    => 'main',
        key      => {
          'id'     => '934961BD53874339F0967F33ADEDD2EEFBF6C33B',
          'source' => 'https://packages.lithnet.io/keys/lithnet.asc',
        },
        before   => Package['LithnetAccessManagerAgent'],
      }
    }
    # If we've ended up here, then this module doesn't currently support the OS
    default : { fail("Unsupported OS ${facts['os']['family']}.") }
  }
  # If I'm here, I've configured a repo and not fallen into the default fail().

  # Install the Lithnet Access Manager agent package
  package { 'LithnetAccessManagerAgent':
    ensure => 'installed',
    name   => $packagename,
  }

  # If "register_agent" is true, try to register the agent
  if($register_agent and $ams_server and $reg_key) {
    exec { 'agent-register':
      command => "/opt/LithnetAccessManagerAgent/Lithnet.AccessManager.Agent --server ${ams_server} --registration-key ${reg_key}",
      unless  => "/usr/bin/grep -iq ${ams_server} /etc/LithnetAccessManagerAgent.conf",
      user    => 'root',
      require => Package['LithnetAccessManagerAgent'],
      notify  => Service['LithnetAccessManagerAgent'],
    }

    service { 'LithnetAccessManagerAgent':
      ensure => 'running',
      enable => true,
    }
  }
}
