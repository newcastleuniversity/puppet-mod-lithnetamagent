# frozen_string_literal: true

require 'spec_helper'

describe 'lithnetamagent::remove' do
  ubuntu = {
    supported_os: [
      {
        'operatingsystem'        => 'Ubuntu',
        'operatingsystemrelease' => ['18.04', '20.04', '22.04'],
      },
    ],
  }
  redhat = {
    supported_os: [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['7', '8', '9'],
      },
      {
        'operatingsystem'        => 'CentOS',
        'operatingsystemrelease' => ['7'],
      },
    ],
  }
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_service('LithnetAccessManagerAgent').with(
          'ensure' => 'stopped',
          'enable' => 'false',
        )
      }
      it { is_expected.to contain_file('/etc/LithnetAccessManagerAgent.conf').with('ensure' => 'absent') }
    end
  end
  context 'Ubuntu-only tests' do
    on_supported_os(ubuntu).each do |_os, os_facts|
      let(:facts) { os_facts }

      it {
        is_expected.to contain_apt__source('Lithnet').with(
          'ensure'   => 'absent',
          'location' => 'https://packages.lithnet.io/linux/deb/prod/repos/ubuntu',
        )
      }
      it {
        is_expected.to contain_package('LithnetAccessManagerAgent').with(
          'name'   => 'lithnetaccessmanageragent',
          'ensure' => 'absent',
        )
      }
    end # ubuntu each
  end # Ubuntu context
  context 'RedHat-only tests' do
    on_supported_os(redhat).each do |_os, os_facts|
      let(:facts) { os_facts }

      it {
        is_expected.to contain_yumrepo('lithnet-am-repo').with(
          'ensure'  => 'absent',
          'baseurl' => %r{https://packages.lithnet.io/linux/rpm/prod/repos/rhel},
        )
      }
      it {
        is_expected.to contain_package('LithnetAccessManagerAgent').with(
          'name' => 'LithnetAccessManagerAgent',
          'ensure' => 'absent',
        )
      }
    end # redhat each
  end # RedHat context
end
