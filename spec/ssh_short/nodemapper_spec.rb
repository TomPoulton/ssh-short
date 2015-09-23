require 'spec_helper'
require 'ssh_short/nodemapper'

module SshShort
  NODEMAP_FILE = nil
end

describe SshShort::NodeMapper do

  let(:nodemapper) { SshShort::NodeMapper.new }
  let(:nodemap) {
    [
        {:host => '10.0.0.1', :alias => 'alice', :key => 'key_for_alice.pem' },
        {:host => '10.0.0.2', :alias => 'bob', :key => 'key_for_bob.pem' },
        {:host => '10.0.0.3', :key => 'key_for_03.pem' },
    ]
  }

  before(:each) do
    allow(File).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(nodemap)
  end

  describe 'is_alias?' do

    it 'returns true if the alias is in the nodemap' do
      result = nodemapper.is_alias? 'alice'
      expect(result).to eq true
    end

    it 'returns false if the alias is not in the nodemap' do
      result = nodemapper.is_alias? 'non-ex'
      expect(result).to eq false
    end

    it 'returns false if the alias is nil' do
      result = nodemapper.is_alias? nil
      expect(result).to eq false
    end

  end

  describe 'get_node' do

    it 'returns a hash' do
      node = nodemapper.get_node('10.0.0.1')
      expect(node).to be_a Hash
    end

    it 'returns the node matching the host' do
      host = '10.0.0.1'
      node = nodemapper.get_node(host)
      expect(node[:alias]).to eq 'alice'
    end

    it 'returns the node matching the alias' do
      node_alias = 'bob'
      node = nodemapper.get_node(node_alias)
      expect(node[:host]).to eq '10.0.0.2'
    end

    it 'returns nil when node does not exist' do
      node = nodemapper.get_node('non-ex')
      expect(node).to eq nil
    end

  end

  describe 'update_node' do

    # Keep the node map simple for these tests
    let(:nodemap) {
      [ {:host => '10.0.0.1', :alias => 'alice', :key => 'key_for_alice.pem'} ]
    }

    before(:each) do
      allow(SshShort::NodeMapper).to receive(:save_node_map).and_return(nil)
      allow(nodemapper).to receive(:puts).and_return(nil)
    end

    it 'returns the updated node map' do
      # This is just so we can get the array for testing,
      # although it might be useful in the future?
      node = nodemap[0]
      updated_nodemap = nodemapper.update_node(node)
      expect(updated_nodemap).to eq nodemap
    end

    it 'adds a new node to the map' do
      node = {:host => '10.0.0.2', :key => 'key_for_bob.pem'}
      updated_nodemap = nodemapper.update_node(node)
      expect(updated_nodemap.count).to eq 2
      expect(updated_nodemap[1]).to eq node
    end

    it 'updates an existing node' do
      node = {:host => '10.0.0.1', :alias => 'alice', :key => 'new_key.pem'}
      updated_nodemap = nodemapper.update_node(node)
      expect(updated_nodemap.count).to eq 1
      expect(updated_nodemap[0]).to eq node
    end

    context 'when updating the user' do

      let(:node) {
        node = nodemap[0].clone
        node[:user] = 'new-user'
        node
      }
      subject(:updated_nodemap) { nodemapper.update_node(node) }

      it 'updates to user' do
        expect(updated_nodemap[0][:user]).to eq 'new-user'
      end

      it 'preserves the alias' do
        expect(updated_nodemap[0][:alias]).to eq 'alice'
      end

    end

    context 'when the alias already exists on another node' do

      let(:node) { {:host => '10.0.0.6', :alias => 'alice', :key => 'key_for_6.pem'} }
      subject(:updated_nodemap) { nodemapper.update_node(node) }

      it 'adds the alias to the new node' do
        expect(updated_nodemap[1][:alias]).to eq 'alice'
      end

      it 'removes the alias from the old node' do
        expect(updated_nodemap[0][:alias]).to eq nil
      end

      it 'prints info message' do
        allow(nodemapper).to receive(:puts).and_call_original
        expect {
          nodemapper.update_node(node)
        }.to output(/Moving alias alice from .*1 to .*6/).to_stdout
      end

    end

  end

  describe 'get_aliases' do

    it 'returns all aliases as array' do
      aliases = nodemapper.get_aliases
      expect(aliases).to eq ['alice', 'bob']
    end

    context 'when there are no aliases' do

      let(:nodemap) {
        [
            {:host => '10.0.0.1', :key => 'key_for_alice.pem' },
            {:host => '10.0.0.2', :key => 'key_for_bob.pem' },
        ]
      }

      it 'returns an empty array' do
        aliases = nodemapper.get_aliases
        expect(aliases).to eq []
      end

    end

  end

  describe 'read_node_map' do

    it 'loads the node array from YAML' do
      allow(File).to receive(:exist?).and_return(true)
      expect(YAML).to receive(:load_file).once.and_return([])
      SshShort::NodeMapper.read_node_map(nil)
    end

    it 'returns an empty array if file does not exist' do
      allow(File).to receive(:exist?).and_return(false)
      result = SshShort::NodeMapper.read_node_map(nil)
      expect(result).to eq([])
    end

  end

end
