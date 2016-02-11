require 'spec_helper'
require 'ssh_short/keyset'

describe SshShort::KeySet do

  let(:keys_dir) { '/path/to/keys' }
  let(:keys) { [ 'key_a.pem', 'key_b.pem', 'key_c.pem', 'key_d.pem' ] }

  subject(:key_set) { SshShort::KeySet.new keys_dir }

  before(:each) do
    allow(File).to receive(:exist?) {keys_dir}.and_return(true)
    allow(File).to receive(:file?).and_return(true)
    allow(Dir).to receive(:glob).and_return(keys)
    allow(STDIN).to receive(:gets).and_return('2')
    allow(key_set).to receive(:puts) # Stop prompt list printing to STDOUT
  end

  describe 'prompt_for_key' do

    it 'returns the name of the selected key' do
      result = key_set.prompt_for_key
      expect(result).to eq 'key_b.pem'
    end

    context 'when key 0 is selected' do

      before(:each) do
        allow(STDIN).to receive(:gets).and_return('0')
      end

      it 'returns the default key name' do
        result = key_set.prompt_for_key
        expect(result).to eq 'id_rsa'
      end

    end


  end

  describe 'get_key' do

    it 'returns the key path from the name' do
      key_name = 'key_c.pem'
      result = key_set.get_key key_name
      expect(result).to eq "#{keys_dir}/#{key_name}"
    end

    context 'when the default key name is provided' do

      it 'returns the default key path' do
        result = key_set.get_key 'id_rsa'
        expect(result).to match /.ssh\/id_rsa/
      end

    end


  end

end
