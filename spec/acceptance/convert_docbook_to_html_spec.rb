require 'rake'
require 'nokogiri'
require_relative '../helpers/environment_helpers'
Rake.load_rakefile(File.expand_path('../../../Rakefile', __FILE__))

describe 'converting any number of directories containing xml files to html' do
  around_in_xml_tmpdir(ENV)

  it 'creates an .html.erb file for each xml file, preserving directory structure' do
    convert('spec/fixtures/docbook_test_files')

    expect(File.exist?(
      "#{output_dir}/spec/fixtures/docbook_test_files/docbook_1.html.erb"
    )).to be_truthy
  end

  it 'correctly populates the .html.erb file with the appropriate content' do
    convert('spec/fixtures/docbook_test_files')
    file_contents = File.read("#{output_dir}/spec/fixtures/docbook_test_files/docbook_1.html.erb")

    expect(file_contents).to match(/^<!DOCTYPE html>/)
  end

  it 'adds xi:include references to the final document' do
    convert('spec/fixtures/docbook_test_files')
    file_contents = File.read("#{output_dir}/spec/fixtures/docbook_test_files/docbook_1.html.erb")

    expect(file_contents).to match(/<h1>Troubleshooting Spark<\/h1>/)
  end

  it 'converts all instances of "Hortonworks" to "Pivotal"' do
    convert('spec/fixtures/docbook_test_files')
    file_contents = File.read("#{output_dir}/spec/fixtures/docbook_test_files/docbook_1.html.erb")

    expect(file_contents).to match(/---\ntitle: Pivotal Data Platform\n---/)
  end

  it 'adds a frontmatter containing the document title to the final HTML output' do
    convert('spec/fixtures/docbook_test_files')
    file_contents = File.read("#{output_dir}/spec/fixtures/docbook_test_files/docbook_1.html.erb")

    expect(file_contents).to match(/---\ntitle: Pivotal Data Platform\n---/)
  end

  it 'outputs no book-level title, relying on the frontmatter and a middleman layout to render it -- sorry.' do
    convert('spec/fixtures/docbook_test_files')
    file_contents = File.read("#{output_dir}/spec/fixtures/docbook_test_files/docbook_1.html.erb")

    expect(file_contents).to_not have_h1_title
  end

  def output_dir
    ENV['XML_OUTPUT_DIR']
  end

  def convert(*args)
    Rake::Task[:convert].execute(args)
  end

  private

  RSpec::Matchers.define :have_h1_title do |expected|
    match do |actual|
      Nokogiri::HTML(actual).css('header > h1').any?
    end
  end
end

