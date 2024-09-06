module RailsTracepointStack
  module Filter
    class RbConfig
      def self.ruby_lib_path
        @ruby_lib_path ||= ::RbConfig::CONFIG["rubylibdir"]
      end
    end
  end
end
