# frozen_string_literal: true

require 'spec_helper'

describe 'nuodb::install' do
  let :facts do
    {
      os: { family: 'Debian' },
      osfamily: 'Debian',
      operatingsystem: 'Ubuntu',
      architecture: 'x86_64',
      lsbdistcodename: 'xenial'
    }
  end

  let :params do
    {
      package_download_url: 'http://yourdomain.com/nuodb'
    }
  end

  it do
    is_expected.to contain_class('nuodb')
    is_expected.to contain_class('nuodb::params')
  end

  context 'install on Debian/Ubuntu' do
    it do
      is_expected.to contain_package('wget')
        .that_comes_before('Exec[download_nuodb]')
      is_expected.to contain_exec('download_nuodb')
        .with_command('/usr/bin/wget -q -O /tmp/nuodb-ce_2.6.0.4_amd64.deb http://yourdomain.com/nuodb/nuodb-ce_2.6.0.4_amd64.deb')
        .with_creates('/tmp/nuodb-ce_2.6.0.4_amd64.deb')
      is_expected.to contain_package('nuodb')
        .with_ensure('installed')
        .with_provider('dpkg')
        .with_source('/tmp/nuodb-ce_2.6.0.4_amd64.deb')
    end
  end

  context 'install on RedHat/CentOS' do
    let :facts do
      {
        os: { family: 'RedHat' },
        osfamily: 'RedHat',
        operatingsystem: 'CentOS',
        architecture: 'x86_64',
        operatingsystemrelease: '7',
        operatingsystemmajrelease: '7'
      }
    end

    it do
      is_expected.to contain_exec('download_nuodb')
        .that_comes_before('Package[nuodb]')
        .with_command('/usr/bin/wget -q -O /tmp/nuodb-ce-2.6.0.4.x86_64.rpm http://yourdomain.com/nuodb/nuodb-ce-2.6.0.4.x86_64.rpm')
        .with_creates('/tmp/nuodb-ce-2.6.0.4.x86_64.rpm')
      is_expected.to contain_package('nuodb')
        .with_ensure('installed')
        .with_provider('rpm')
        .with_source('/tmp/nuodb-ce-2.6.0.4.x86_64.rpm')
    end
  end

  context 'with alternative source' do
    let :params do
      {
        package_alt_source: '/mnt/packages/nuodb'
      }
    end

    it do
      is_expected.not_to contain_exec('download_nuodb')
      is_expected.to contain_package('nuodb')
        .with_ensure('installed')
        .with_provider('dpkg')
        .with_source('/mnt/packages/nuodb/nuodb-ce_2.6.0.4_amd64.deb')
    end
  end

  context 'with alternative package name and custom provider' do
    let :params do
      {
        package_provider: 'rpm',
        package_alt_name: 'nuodb-ce-3.0.0.0-beta1.x86_64.rpm'
      }
    end

    it do
      is_expected.to contain_exec('download_nuodb')
      is_expected.to contain_package('nuodb')
        .with_ensure('installed')
        .with_provider('rpm')
        .with_source('/tmp/nuodb-ce-3.0.0.0-beta1.x86_64.rpm')
    end
  end
end
