module RailsTracepointStack
  module Filter
    class GemPath
      # Bundler gives the tightest answer, but it is not always there: a plain
      # `ruby -e` or an irb session against an installed gem has no bundle, and
      # asking Bundler then raises instead of filtering. Falling back to every
      # installed gem is wider than needed and still filters out the code the
      # developer did not write.
      def self.full_gem_path
        @full_gem_path ||= bundled_gem_paths || gem_install_roots
      end

      def self.bundled_gem_paths
        return nil unless defined?(::Bundler)

        ::Bundler.load.specs.map(&:full_gem_path)
      rescue
        nil
      end

      # Without a bundle there is no resolved list to ask for, but everything
      # installed lives under these roots, which is all the filter needs.
      def self.gem_install_roots
        Gem.path.map { |dir| File.join(dir, "gems") }
      end
    end
  end
end
