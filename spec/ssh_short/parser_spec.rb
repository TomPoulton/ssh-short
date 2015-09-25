require 'spec_helper'
require 'ssh_short/parser'

describe SshShort::Parser do

  describe 'parse_config' do

    let(:config) {
      {
          :default_user => 'ec2-user',
          :ip_mask => '10.72.0.0',
          :keys_dir => '~/.ssh/accuity'
      } }

    before(:each) do
      stub_const('SshShort::CONFIG_FILE', 'config')
      allow(SshShort::Parser).to receive(:config_file_exists?).and_return(true)
      allow(YAML).to receive(:load_file).and_return(config)
    end

    it 'returns a hash' do
      config = SshShort::Parser.parse_config
      expect(config).to be_a Hash
    end

    it 'parses config keys as symbols' do
      config = SshShort::Parser.parse_config
      config.each { |k, v|
        expect(k).to be_a Symbol
      }
    end

    context 'when config file does not exist' do

      before(:each) do
        allow(SshShort::Parser).to receive(:config_file_exists?).and_return(false)
      end

      it 'aborts with error message' do
        expect {
          expect {
            SshShort::Parser.parse_config
          }.to raise_error SystemExit
        }.to output(/Cannot find config file/).to_stderr
      end
    end

    context 'when keys_dir is null' do

      before(:each) do
        config.delete :keys_dir
      end

      it 'aborts with error message' do
        expect {
          expect {
            SshShort::Parser.parse_config
          }.to raise_error SystemExit
        }.to output(/Keys directory must be specified/).to_stderr
      end
    end

  end

  describe 'parse_input' do

    let(:standard_args) {
      ['6']
    }
    let(:config) {
      { :ip_mask => '10.0.0.0', :default_user => 'user' }
    }

    before(:each) do
    end

    it 'applies mask to ip' do
      options = SshShort::Parser.parse_input(config, standard_args)
      expect(options[:node]).to eq '10.0.0.6'
    end

    it 'uses all sections of input ip' do
      options = SshShort::Parser.parse_input(config, ['1.2.3.4'])
      expect(options[:node]).to eq '1.2.3.4'
    end

    it 'uses input as host when input is not ip' do
      options = SshShort::Parser.parse_input(config, ['frank'])
      expect(options[:node]).to eq 'frank'
    end

    context 'when no user is provided' do

      it 'leaves the user unset' do
        options = SshShort::Parser.parse_input(config, standard_args)
        expect(options).to_not include(:user)
      end

    end

    context 'when a user is provided' do

      let(:user_args) { ['6', '-u', 'new-user'] }

      it 'extracts the user' do
        options = SshShort::Parser.parse_input(config, user_args)
        expect(options[:user]).to eq 'new-user'
      end

      it 'removes the user args' do
        options = SshShort::Parser.parse_input(config, user_args)
        expect(user_args).to_not include '-u'
        expect(user_args).to_not include 'new-user'
      end
    end

    context 'when a new alias is provided' do

      let(:alias_args) { ['6', '-a', 'fred'] }

      it 'extracts the alias' do
        options = SshShort::Parser.parse_input(config, alias_args)
        expect(options[:alias]).to eq 'fred'
      end

      it 'removes the alias args' do
        options = SshShort::Parser.parse_input(config, alias_args)
        expect(alias_args).to_not include '-a'
        expect(alias_args).to_not include 'fred'
      end
    end

    it 'skips key prompt when -k flag is not set' do
      options = SshShort::Parser.parse_input(config, standard_args)
      expect(options[:force_key_prompt]).to eq false
    end

    context 'when -k flag is set' do

      let(:key_args) { ['6', '-k'] }

      it 'forces key prompt' do
        options = SshShort::Parser.parse_input(config, key_args)
        expect(options[:force_key_prompt]).to eq true
      end

      it 'removes -k flag from args' do
        options = SshShort::Parser.parse_input(config, key_args)
        expect(key_args).to_not include '-k'
      end
    end

    context 'when --list flag is set' do

      let(:key_args) { ['--list'] }

      it 'sets the action to :list_aliases' do
        options = SshShort::Parser.parse_input(config, key_args)
        expect(options[:action]).to eq :list_aliases
      end

      it 'removes --list flag from args' do
        SshShort::Parser.parse_input(config, key_args)
        expect(key_args).to_not include '--list'
      end
    end

  end

end
