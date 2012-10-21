#!/usr/bin/env ruby -S rspec

require 'spec_helper'

provider_class = Puppet::Type.type(:network_config).provider(:redhat)
describe provider_class do

  def fixture_data(file)
    basedir = File.join(PROJECT_ROOT, 'spec', 'fixtures', 'provider', 'network_config', 'redhat_spec')
    File.read(File.join(basedir, file))
  end

  describe "when parsing" do
    subject { provider_class }

    describe 'the name' do
      let(:data) { subject.parse_file('eth0', fixture_data('eth0-dhcp'))[0] }
      it { data[:name].should == 'eth0' }
    end

    describe 'the onboot property' do
      let(:data) { subject.parse_file('eth0', fixture_data('eth0-dhcp'))[0] }
      it { data[:name].should be_true }
    end

    describe "the method property" do
      describe 'when dhcp' do
        let(:data) { subject.parse_file('eth0', fixture_data('eth0-dhcp'))[0] }
        it { data[:method].should == 'dhcp' }
      end

      describe 'when static' do
        let(:data) { subject.parse_file('eth0', fixture_data('eth0-static'))[0] }
        it {
          pending 'Requires conversion from "none" to "static"'
          data[:method].should == 'static'
        }
      end
    end

    describe 'a static interface' do
      let(:data) { subject.parse_file('eth0', fixture_data('eth0-static'))[0] }
      it { data[:ipaddress].should == '10.0.1.27' }
      it { data[:netmask].should   == '255.255.255.0' }
    end

    describe 'the options property' do
      let(:data) { subject.parse_file('eth0', fixture_data('eth0-static'))[0] }
      it { data[:options]["USERCTL"].should == 'no' }
      it { data[:options]["NM_CONTROLLED"].should == 'no' }
    end

    describe "when reading an invalid interfaces" do
      it "with a mangled key/value should fail"
    end
  end

  describe ".format_resources" do
    let(:eth0_provider) do
      stub('eth0_provider',
        :name            => "eth0",
        :ensure          => :present,
        :onboot          => :true,
        :family          => "inet",
        :method          => "static",
        :ipaddress       => "169.254.0.1",
        :netmask         => "255.255.0.0",
        :options         => { :"allow-hotplug" => true, }
      )
    end

    let(:lo_provider) do
      stub('lo_provider',
        :name            => "lo",
        :onboot          => :true,
        :"allow-hotplug" => true,
        :family          => "inet",
        :method          => "loopback",
        :ipaddress       => nil,
        :netmask         => nil,
        :options         => { :"allow-hotplug" => true, })
    end
  end
end