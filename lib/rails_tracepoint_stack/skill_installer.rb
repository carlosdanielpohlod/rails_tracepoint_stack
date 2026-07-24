require "fileutils"

module RailsTracepointStack
  # Copies the packaged agent skill into the host app.
  #
  # A skill living in this gem's repository only helps someone working on the
  # gem. Agents look for skills inside the project they are working on, so the
  # file has to land there for the gem to ever get picked up on its own.
  class SkillInstaller
    SKILL_PATH = ".claude/skills/debug-with-tracepoint/SKILL.md".freeze
    TEMPLATE_PATH = File.expand_path("templates/skill.md", __dir__).freeze

    attr_reader :destination, :force

    def initialize(destination: Dir.pwd, force: false)
      @destination = destination
      @force = force
    end

    # Returns the path written, or nil when a skill was already there.
    def install
      return nil if File.exist?(target_path) && !force

      FileUtils.mkdir_p(File.dirname(target_path))
      File.write(target_path, template)
      target_path
    end

    def target_path
      File.join(destination, SKILL_PATH)
    end

    private

    def template
      File.read(TEMPLATE_PATH)
    end
  end
end
