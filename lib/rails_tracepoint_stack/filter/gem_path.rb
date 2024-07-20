module RailsTracepointStack
  module Filter
    class GemPath
      def self.full_gem_path
        @full_gem_path ||= Bundler.load.specs.map(&:full_gem_path)
      end
    end
  end
end
