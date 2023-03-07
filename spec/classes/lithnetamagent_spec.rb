# frozen_string_literal: true

require 'spec_helper'

describe 'lithnetamagent' do
  ubuntu = {
    supported_os: [
      {
        'operatingsystem'        => 'Ubuntu',
        'operatingsystemrelease' => ['20.04', '22.04'],
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
  settings = {
    'register_agent' => true,
    'ams_server'     => '192.168.1.100',
    'reg_key'        => 'alphabetsoup'
  }
  context 'Supported OS tests with parameters' do
    let(:params) { settings }

    on_supported_os.each do |_os, os_facts|
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('LithnetAccessManagerAgent') }
      it {
        is_expected.to contain_exec('agent-register').with(
          'command' => '/opt/LithnetAccessManagerAgent/Lithnet.AccessManager.Agent --server 192.168.1.100 --registration-key alphabetsoup',
        )
      }
    end # on_supported_os each
  end # with-params context
  context 'Ubuntu-only tests' do
    let(:params) { settings }

    on_supported_os(ubuntu).each do |_os, os_facts|
      let(:facts) { os_facts }

      it { is_expected.to contain_apt__source('Lithnet') }
    end # ubuntu each
  end # Ubuntu context
  context 'RedHat-only tests' do
    let(:params) { settings }

    on_supported_os(redhat).each do |_os, os_facts|
      let(:facts) { os_facts }

      it { is_expected.to contain_yumrepo('lithnet-am-repo') }
    end # redhat each
  end # RedHat context
end # describe
