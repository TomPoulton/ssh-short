require 'YAML'

module SshShort

  class KeySet

    def initialize(keys_dir)
      @keys_dir = keys_dir
    end

    def prompt_for_key
      abort "Error: Cannot find keys directory at #{@keys_dir}" unless File.exist? @keys_dir
      keys = Dir.glob("#{@keys_dir}/*").select{ |e| File.file? e }
      abort "Error: No keys found in #{@keys_dir}" unless keys.count > 0

      key_names = keys.collect { |key| File.basename key }

      puts 'Select a key:'
      key_names.each_with_index { |key_name, i| puts "#{i}) #{key_name}" }

      key_selection = STDIN.gets.to_i
      abort "#{key_selection} is not a valid key" if (key_selection >= key_names.count)

      key_names[key_selection]
    end

    def get_key(key_name)
      key = "#{@keys_dir}/#{key_name}"
      abort "Error: Cannot find #{key}" unless File.exist? key
      key
    end

  end

end
