require 'YAML'

module SshShort

  class KeySet

    def initialize(keys_dir)
      @keys_dir = keys_dir
    end

    def prompt_for_key
      key_names = find_keys.collect { |key| File.basename key }
      key_names.unshift 'id_rsa'

      puts 'Select a key:'
      key_names.each_with_index { |key_name, i| puts "#{i}) #{key_name}" }

      key_selection = STDIN.gets.to_i
      abort "#{key_selection} is not a valid key" if (key_selection >= key_names.count)

      key_names[key_selection]
    end

    def get_key(key_name)
      if key_name.eql?('id_rsa')
        key = File.expand_path('~/.ssh/id_rsa')
      else
        keys = find_keys.select { |path| File.basename(path) == key_name }
        abort "Error: More than one key found called #{key_name}" if keys.count > 1
        key = keys.first
      end
      # key = File.expand_path(key)
      abort "Error: Cannot find #{key}" unless File.exist? key
      key
    end
    
    def find_keys
      abort "Error: Cannot find keys directory at #{@keys_dir}" unless File.exist? @keys_dir
      
      # Recursively search directory, including following symlinks
      search_string = "#{File.expand_path(@keys_dir)}/**{,/*/**}/*"
      
      keys = Dir.glob(search_string).select { |e| File.file? e }
      abort "Error: No keys found in #{@keys_dir}" unless keys.count > 0
      
      keys
    end

  end

end
