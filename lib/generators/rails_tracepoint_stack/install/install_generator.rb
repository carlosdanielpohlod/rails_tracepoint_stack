require "rails/generators/base"
require "rails_tracepoint_stack/skill_installer"

module RailsTracepointStack
  module Generators
    # Thin wrapper over SkillInstaller so the behaviour stays testable without
    # booting Rails.
    class InstallGenerator < Rails::Generators::Base
      desc "Installs the debug-with-tracepoint skill so agents working in " \
           "this app know how to trace it"

      def install_agent_skill
        installer = RailsTracepointStack::SkillInstaller.new(
          destination: destination_root,
          force: options[:force]
        )
        written = installer.install

        if written
          say_status :create, relative_to_original_destination_root(written), :green
        else
          say_status :skip,
            "#{relative_to_original_destination_root(installer.target_path)} already exists (--force to replace)",
            :yellow
        end
      end
    end
  end
end
