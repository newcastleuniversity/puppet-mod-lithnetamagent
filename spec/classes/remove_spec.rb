# frozen_string_literal: true

require 'spec_helper'

describe 'lithnetamagent::remove' do
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
      it { is_expected.to contain_package('LithnetAccessManagerAgent').with('ensure' => 'absent') }
      it { is_expected.to contain_file('/etc/LithnetAccessManagerAgent.conf').with('ensure' => 'absent') }
    end
  end
end
