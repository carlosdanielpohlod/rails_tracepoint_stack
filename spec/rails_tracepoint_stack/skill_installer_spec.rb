require "spec_helper"
require "tmpdir"

RSpec.describe RailsTracepointStack::SkillInstaller do
  around do |example|
    Dir.mktmpdir { |dir| @destination = dir; example.run }
  end

  attr_reader :destination

  subject(:installer) { described_class.new(destination: destination) }

  let(:skill_path) { File.join(destination, ".claude/skills/debug-with-tracepoint/SKILL.md") }

  it "writes the skill where an agent will find it" do
    installer.install

    expect(File).to exist(skill_path)
  end

  it "creates the directories it needs" do
    expect { installer.install }.not_to raise_error
  end

  it "returns the path it wrote" do
    expect(installer.install).to eq(skill_path)
  end

  it "writes a skill with the frontmatter agents key off" do
    installer.install

    expect(File.read(skill_path)).to start_with("---\nname: debug-with-tracepoint\n")
  end

  it "documents the capture entrypoint" do
    installer.install

    expect(File.read(skill_path)).to include("RailsTracepointStack.capture")
  end

  it "leaves an existing skill alone" do
    FileUtils.mkdir_p(File.dirname(skill_path))
    File.write(skill_path, "mine")

    installer.install

    expect(File.read(skill_path)).to eq("mine")
  end

  it "reports that it skipped an existing skill" do
    FileUtils.mkdir_p(File.dirname(skill_path))
    File.write(skill_path, "mine")

    expect(installer.install).to be_nil
  end

  it "overwrites when forced" do
    FileUtils.mkdir_p(File.dirname(skill_path))
    File.write(skill_path, "mine")

    described_class.new(destination: destination, force: true).install

    expect(File.read(skill_path)).to include("RailsTracepointStack.capture")
  end
end
