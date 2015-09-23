require 'ssh_short/parser'
require 'ssh_short/nodemapper'
require 'ssh_short/keyset'
require 'ssh_short/connection'

module SshShort

  CONFIG_DIR = File.expand_path('~/.ssh-short')
  CONFIG_FILE = File.join(CONFIG_DIR, 'config.yml')
  NODEMAP_FILE = File.join(CONFIG_DIR, 'nodemap.yml')
  Dir.mkdir(CONFIG_DIR) unless File.exists?(CONFIG_DIR)

  class CLI

    def self.run(argv)
      config = SshShort::Parser.parse_config
      args = SshShort::Parser.parse_input(config, argv)
      key_set = SshShort::KeySet.new(config[:keys_dir])
      node_mapper = SshShort::NodeMapper.new

      if args[:action] == :list_aliases
        node_mapper.get_aliases.each { |node_alias| puts node_alias }
        exit
      end

      node = node_mapper.get_node args[:node]
      node ||= {:host => args[:node]}

      if node[:key].nil? or args[:force_key_prompt]
        node[:key] = key_set.prompt_for_key
      end
      node = CLI.add_options_if_present(node, args, [:alias, :user])

      node_mapper.update_node(node)
      key_path = key_set.get_key node[:key]

      case args[:action]
        when :connect
          Connection.connect node[:host], node[:user], key_path
        when :push
          Connection.push node[:host], node[:user], key_path, args[:source], args[:target]
        when :pull
          Connection.pull node[:host], node[:user], key_path, args[:source], args[:target]
        else
          abort 'Unknown action'
      end
    end

    def self.add_options_if_present(node, args, options)
      options.each { |option|
        node[option] = args[option] if args.include?(option)
      }
      node
    end

  end
end
