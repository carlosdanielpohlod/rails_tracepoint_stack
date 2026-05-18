require "spec_helper"
require "json"

RSpec.describe RailsTracepointStack::Duration::Output do
  describe "#show_top_files" do
    before do
      allow(File)
        .to receive(:open)
        .with("log-boot-4.txt", "r")
        .and_return(
          StringIO.new(
            {file: "file1", duration: 1}.to_json + "\n" +
            {file: "file1", duration: 2}.to_json + "\n" +
            {file: "file2", duration: 1}.to_json + "\n" +
            {file: "file2", duration: 1}.to_json + "\n" +
            {file: "file2", duration: 1}.to_json + "\n" +
            {file: "file3", duration: 1}.to_json + "\n" +
            {file: "file4", duration: 1}.to_json + "\n" +
            {file: "file5", duration: 1}.to_json + "\n" +
            {file: "file5", duration: 1}.to_json + "\n" +
            {file: "file5", duration: 1}.to_json + "\n" + 
            {file: "file6", duration: 1}.to_json + "\n" +
            {file: "file7", duration: 1}.to_json + "\n" +
            {file: "file8", duration: 1}.to_json + "\n" +
            {file: "file9", duration: 1}.to_json + "\n" +
            {file: "file10", duration: 1}.to_json + "\n" +
            {file: "file11", duration: 1}.to_json + "\n"
          )
        )
    end

    it "prints the top 10 files with their total duration" do
      expect { described_class.new.show_top_files }
        .to output(
          <<~OUTPUT
              1. File: file1 - Total Duration: 3 seconds
              2. File: file2 - Total Duration: 3 seconds
              3. File: file5 - Total Duration: 3 seconds
              4. File: file3 - Total Duration: 1 seconds
              5. File: file4 - Total Duration: 1 seconds
              6. File: file6 - Total Duration: 1 seconds
              7. File: file7 - Total Duration: 1 seconds
              8. File: file8 - Total Duration: 1 seconds
              9. File: file9 - Total Duration: 1 seconds
              10. File: file10 - Total Duration: 1 seconds
          OUTPUT
        ).to_stdout
    end
  end
end
