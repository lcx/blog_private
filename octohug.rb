#!/usr/bin/env ruby
# frozen_string_literal: true

# octohug.rb
#
# Converts Octopress posts to Hugo format
#   - Converts YAML header to TOML format
#   - Converts categories and tags to Hugo format
#   - Replaces include_code with file contents
#   - Generates slug from filename and date
#
# Usage: ruby octohug.rb <octopress_file> [options]
#
# Based on: http://codebrane.com/blog/2015/09/10/migrating-from-octopress-to-hugo/

require 'optparse'
require 'fileutils'

# Simple titleize implementation (no external gem needed)
class String
  SMALL_WORDS = %w[a an and as at but by for in of on or the to].freeze

  def titleize
    words = split
    words.map.with_index do |word, index|
      if index.zero? || !SMALL_WORDS.include?(word.downcase)
        word.capitalize
      else
        word.downcase
      end
    end.join(' ')
  end
end

class OctopressToHugoConverter
  HEADER_DELIMITER = '---'
  HUGO_HEADER_DELIMITER = '+++'

  def initialize(input_file, output_dir, code_dir: 'source/downloads/code')
    @input_file = input_file
    @output_dir = output_dir
    @code_dir = code_dir
  end

  def convert
    unless File.exist?(@input_file)
      warn "Error: Input file '#{@input_file}' not found"
      return false
    end

    content = File.read(@input_file)
    filename_without_date = extract_filename_without_date

    return false unless filename_without_date

    hugo_content = process_content(content, filename_without_date)
    write_hugo_file(filename_without_date, hugo_content)

    true
  end

  private

  def extract_filename_without_date
    basename = File.basename(@input_file)
    match = basename.match(/^\d{4}-\d{2}-\d{2}-(.*)\.m(?:arkdown|d)$/)

    unless match
      warn "Error: Filename '#{basename}' doesn't match expected pattern (YYYY-MM-DD-title.md)"
      return nil
    end

    match[1]
  end

  def process_content(content, filename_without_date)
    lines = content.lines
    output_lines = []

    state = {
      in_header: false,
      header_seen: false,
      in_categories: false,
      in_tags: false,
      categories: [],
      tags: [],
      date: nil
    }

    lines.each do |line|
      line = line.chomp
      processed = process_line(line, state, filename_without_date)
      output_lines << processed if processed
    end

    # Close any open arrays at end of file
    output_lines << finalize_arrays(state)

    output_lines.compact.join("\n")
  end

  def process_line(line, state, filename_without_date)
    # Header delimiter
    if line == HEADER_DELIMITER
      return handle_header_delimiter(state)
    end

    # Inside header
    if state[:in_header]
      return process_header_line(line, state, filename_without_date)
    end

    # Content area - handle include_code
    if line.include?('include_code')
      return process_include_code(line)
    end

    line
  end

  def handle_header_delimiter(state)
    result = nil

    if state[:in_header]
      # Closing header - finalize arrays first
      result = finalize_arrays(state)
      state[:in_header] = false
    else
      state[:in_header] = true
      state[:header_seen] = true
    end

    # Return delimiter and any finalized content
    if result && !result.empty?
      "#{result}\n#{HUGO_HEADER_DELIMITER}"
    else
      HUGO_HEADER_DELIMITER
    end
  end

  def process_header_line(line, state, filename_without_date)
    # Categories start
    if line.match?(/^categories:/)
      state[:in_categories] = true
      state[:in_tags] = false
      return nil
    end

    # Tags start
    if line.match?(/^tags:/)
      state[:in_tags] = true
      state[:in_categories] = false
      return nil
    end

    # Category/tag item
    if match = line.match(/^- (.*)/)
      item = match[1].gsub(/['"]/, '')
      if state[:in_categories]
        state[:categories] << item
      elsif state[:in_tags]
        state[:tags] << item
      end
      return nil
    end

    # If we hit another key, close categories/tags
    if line.match?(/^\w+:/) && (state[:in_categories] || state[:in_tags])
      result = finalize_arrays(state)
      state[:in_categories] = false
      state[:in_tags] = false
      return [result, process_header_key(line, state, filename_without_date)].compact.join("\n")
    end

    process_header_key(line, state, filename_without_date)
  end

  def process_header_key(line, state, filename_without_date)
    case line
    when /^date:\s*(.+)/
      date_value = $1.split.first # Get just the date part
      state[:date] = date_value
      slug = "#{date_value.tr('-', '/')}/#{filename_without_date}"
      "date = \"#{date_value}\"\nslug = \"#{slug}\""

    when /^title:\s*/
      # Generate title from filename for URL consistency
      title = filename_without_date.tr('-', ' ').titleize
      "title = \"#{title}\""

    when /^description:\s*(.+)/
      "description = #{$1}"

    when /^keywords:\s*(.+)/
      keywords = $1.gsub('"', '').split(',').map(&:strip)
      formatted = keywords.map { |k| "\"#{k}\"" }.join(', ')
      "keywords = [#{formatted}]"

    when /^published:\s*false/
      'published = false'

    when /^(?:layout|author|comments|slug|wordpress_id):/
      # Skip these fields
      nil

    else
      # Pass through other lines (empty lines, unknown fields)
      line.empty? ? nil : line
    end
  end

  def finalize_arrays(state)
    result = []

    if state[:categories].any?
      formatted = state[:categories].map { |c| "\"#{c}\"" }.join(', ')
      result << "Categories = [#{formatted}]"
      state[:categories] = []
    end

    if state[:tags].any?
      formatted = state[:tags].map { |t| "\"#{t}\"" }.join(', ')
      result << "Tags = [#{formatted}]"
      state[:tags] = []
    end

    result.empty? ? nil : result.join("\n")
  end

  def process_include_code(line)
    # Parse include_code directive
    # Formats:
    #   {% include_code [Title] lang:language path/to/file %}
    #   {% include_code [Title] path/to/file %}
    parts = line.split

    # Get the file path (second to last element, before closing %})
    file_path = parts[-2]
    full_path = File.join(@code_dir, file_path)

    if File.exist?(full_path)
      code_content = File.read(full_path)
      code_content = code_content.gsub('<', '&lt;').gsub('>', '&gt;')
      "<pre><code>\n#{code_content}</code></pre>"
    else
      warn "Warning: Code file '#{full_path}' not found"
      line # Return original line if file not found
    end
  end

  def write_hugo_file(filename_without_date, content)
    FileUtils.mkdir_p(@output_dir)
    output_path = File.join(@output_dir, "#{filename_without_date}.md")

    File.write(output_path, content)
    puts "Converted: #{@input_file} -> #{output_path}"
  end
end

# Batch converter for directories
class BatchConverter
  def initialize(input_dir, output_dir, code_dir: 'source/downloads/code')
    @input_dir = input_dir
    @output_dir = output_dir
    @code_dir = code_dir
  end

  def convert_all
    pattern = File.join(@input_dir, '*.{md,markdown}')
    files = Dir.glob(pattern)

    if files.empty?
      warn "No markdown files found in #{@input_dir}"
      return
    end

    puts "Converting #{files.length} files..."

    files.each do |file|
      converter = OctopressToHugoConverter.new(file, @output_dir, code_dir: @code_dir)
      converter.convert
    end

    puts "Done!"
  end
end

# CLI
if __FILE__ == $PROGRAM_NAME
  options = {
    output_dir: 'content/post',
    code_dir: 'source/downloads/code',
    batch: false
  }

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} <input_file_or_dir> [options]"

    opts.on('-o', '--output DIR', 'Output directory for Hugo posts (default: content/post)') do |dir|
      options[:output_dir] = dir
    end

    opts.on('-c', '--code-dir DIR', 'Directory containing code snippets (default: source/downloads/code)') do |dir|
      options[:code_dir] = dir
    end

    opts.on('-b', '--batch', 'Batch convert all files in input directory') do
      options[:batch] = true
    end

    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit
    end
  end

  parser.parse!

  if ARGV.empty?
    puts parser
    exit 1
  end

  input_path = ARGV[0]

  if options[:batch] || File.directory?(input_path)
    BatchConverter.new(input_path, options[:output_dir], code_dir: options[:code_dir]).convert_all
  else
    converter = OctopressToHugoConverter.new(input_path, options[:output_dir], code_dir: options[:code_dir])
    unless converter.convert
      exit 1
    end
  end
end