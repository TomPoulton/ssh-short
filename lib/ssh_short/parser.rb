module SshShort

  class Parser

    def self.parse_config
      abort "Error: Cannot find config file #{SshShort::CONFIG_FILE}" unless config_file_exists?
      config = YAML.load_file(SshShort::CONFIG_FILE)
      abort 'Error: Keys directory must be specified' unless config[:keys_dir]
      config[:keys_dir] = File.expand_path(config[:keys_dir])
      config
    end

    def self.config_file_exists?
      File.exist? SshShort::CONFIG_FILE
    end

    def self.parse_input(config, args)
      options = self.key_options args, {}
      options = self.alias_option args, options
      options = self.action_options args, options
      options = self.user_options args, options
      options = self.node_options args, options, config[:ip_mask]
      options
    end

    private

    def self.key_options(args, options)
      options[:force_key_prompt] = args.include? '-k'
      args.delete '-k'
      options
    end

    def self.alias_option(args, options)
      alias_index = args.index('-a')
      if alias_index
        options[:alias] = args[alias_index + 1]
        2.times { args.delete_at alias_index }
      end
      options
    end

    def self.user_options(args, options)
      user_index = args.index('-u')
      if user_index
        options[:user] = args[user_index + 1]
        2.times { args.delete_at user_index }
      end
      options
    end

    def self.action_options(args, options)
      push_pull_index = args.index('--push') || args.index('--pull')
      if args.include? '--list'
        options[:action] = :list_aliases
        args.delete '--list'
      elsif push_pull_index
        options[:action] = args[push_pull_index].gsub('-', '').to_sym
        options[:source] = args[push_pull_index + 1]
        options[:target] = args[push_pull_index + 2]
        3.times { args.delete_at push_pull_index }
      else
        options[:action] = :connect
      end
      options
    end

    def self.node_options(args, options, ip_mask)
      input = args[0]
      options[:node] = input_is_ip?(input) ? apply_ip_mask(input, ip_mask) : input
      options
    end

    def self.input_is_ip?(input)
      input ? input.match(/^[\d\.]+$/) : false
    end

    def self.apply_ip_mask(ip, ip_mask)
      return ip unless ip.match(/^[\d\.]+$/)
      sections = ip.split('.').count
      if sections < 4
        "#{ip_mask.split('.')[0..(3 - sections)].join('.')}.#{ip}"
      else
        ip
      end
    end

  end
end
