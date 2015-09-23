module SshShort

  class Connection

    def self.connect(ip_address, username, key_path)
      key_name = File.basename key_path
      puts "Connecting as #{username} to #{ip_address} using #{key_name}"
      system "ssh -i #{key_path} #{username}@#{ip_address}"
    end

    def self.push(ip_address, username, key_path, source, target)
      key_name = File.basename key_path
      puts "Pushing #{source} to #{ip_address} at #{target} as #{username} using #{key_name}"
      system "scp -r -i #{key_path} #{source} #{username}@#{ip_address}:#{target}"
    end

    def self.pull(ip_address, username, key_path, source, target)
      key_name = File.basename key_path
      puts "Pulling #{source} from #{ip_address} as #{username} to #{target} using #{key_name}"
      system "scp -r -i #{key_path} #{username}@#{ip_address}:#{source} #{target}"
    end

  end
end
