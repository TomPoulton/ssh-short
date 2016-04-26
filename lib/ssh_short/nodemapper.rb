module SshShort

  class NodeMapper

    def initialize
      @node_map_file = SshShort::NODEMAP_FILE
      @node_map = NodeMapper.read_node_map(@node_map_file)
    end

    def is_alias?(input)
      aliases = get_aliases
      aliases.include? input
    end

    # returns nil if no matching node is found
    def get_node(host_or_alias)
      if is_alias? host_or_alias
        get_node_by_alias host_or_alias
      else
        get_node_by_host host_or_alias
      end
    end

    def update_node(node)
      if alias_changed? node
        existing_node_with_alias = get_node_by_alias(node[:alias])
        if existing_node_with_alias
          puts "Moving alias #{node[:alias]} from #{existing_node_with_alias[:host]} to #{node[:host]}"
          existing_node_with_alias.delete :alias
          upsert_node existing_node_with_alias
        end
      end

      upsert_node node

      NodeMapper.save_node_map(@node_map_file, @node_map)
      @node_map
    end

    def get_aliases
      @node_map.collect { |node| node[:alias] }.compact
    end

    class << self
      def read_node_map(node_map_file)
        File.exist?(node_map_file) ? YAML.load_file(node_map_file) : []
      end

      def save_node_map(node_map_file, node_map)
        File.open(node_map_file, 'w') { |fo| fo.puts node_map.to_yaml }
      end
    end

    private

    def alias_changed?(node)
      return false unless node[:alias]
      old_node = get_node_by_host node[:host]
      old_node ? old_node[:alias] != node[:alias] : true
    end

    def upsert_node(node)
      existing_node = get_node_by_host node[:host]
      if existing_node
        @node_map.delete existing_node
      end
      @node_map.push node
    end

    def get_node_by_alias(node_alias)
      nodes = @node_map.find_all { |node| node[:alias] == node_alias }
      # abort "Error: More than one Node has alias #{node_alias} in Node Map" if (nodes.count > 1)
      nodes[0]
    end

    def get_node_by_host(host)
      nodes = @node_map.find_all { |node| node[:host] == host }
      # abort "Error: More than one Node has host #{host} in Node Map" if (nodes.count > 1)
      nodes[0]
    end

  end

end
