# frozen_string_literal: true

require 'spec_helper'

describe 'lithnetamagent' do
  context 'Supported OS tests' do
    weuse = {
      supported_os: [
        {
          'operatingsystem'        => 'Ubuntu',
          'operatingsystemrelease' => ['18.04', '20.04', '22.04'],
        },
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['7', '8', '9'],
        },
      ],
      hardwaremodels: ['amd64', 'x86_64'],
    }
    on_supported_os(weuse).each do |_os, os_facts|
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('LithnetAccessManagerAgent') }
    end
  end
end
