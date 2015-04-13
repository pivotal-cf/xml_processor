require_relative 'dir_processor'

module XmlProcessor
  class Converter
    def self.build(output_dir)
      Converter.new(
        output_dir,
        [
          XmlProcessor::Processes::XylemeXmlProcessor.new(output_dir),
          XmlProcessor::Processes::NonXmlProcessor.new(output_dir)
        ],
      )
    end

    def initialize(output_dir, processors)
      @output_dir = output_dir
      @processors = processors
    end

    def run(dirs)
      dirs.each do |dir|
        DirProcessor.new(dir, output_dir).call(processors)
      end
    end

    private

    attr_reader :output_dir, :processors
  end
end

