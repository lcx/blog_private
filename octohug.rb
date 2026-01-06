#!/usr/bin/env ruby
# frozen_string_literal: true

# octohug.rb
#
# Converts Octopress posts to Hugo format with YAML frontmatter
#   - Keeps YAML format (--- delimiters)
#   - Extracts date from filename
#   - Creates slug from filename without date
#   - Converts permalink to url
#   - Adds hardcoded author
#   - Adds draft: false
#   - Preserves original filename with date
#
# Usage: ruby octohug.rb <octopress_file> [options]

require 'optparse'
require 'fileutils'

class OctopressToHugoConverter
  HEADER_DELIMITER = '---'
  AUTHOR = 'Cristian Livadaru'

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
    file_info = extract_file_info

    return false unless file_info

    hugo_content = process_content(content, file_info)
    write_hugo_file(file_info[:original_filename], hugo_content)

    true
  end

  private

  def extract_file_info
    basename = File.basename(@input_file)
    match = basename.match(/^(\d{4})-(\d{2})-(\d{2})-(.*)\.m(?:arkdown|d)$/)

    unless match
      warn "Error: Filename '#{basename}' doesn't match expected pattern (YYYY-MM-DD-title.md)"
      return nil
    end

    year, month, day, slug = match.captures
    date = "#{year}-#{month}-#{day}"

    {
      original_filename: basename,
      date: date,
      slug: slug,
      url: "/#{year}/#{month}/#{day}/#{slug}/"
    }
  end

  def process_content(content, file_info)
    lines = content.lines
    output_lines = []

    state = {
      in_header: false,
      header_closed: false,
      in_categories: false,
      in_tags: false,
      categories: [],
      tags: [],
      title: nil,
      has_url: false
    }

    lines.each do |line|
      line = line.chomp
      result = process_line(line, state, file_info)
      output_lines.concat(Array(result)) if result
    end

    output_lines.join("\n") + "\n"
  end

  def process_line(line, state, file_info)
    # Header delimiter
    if line == HEADER_DELIMITER
      return handle_header_delimiter(state, file_info)
    end

    # Inside header
    if state[:in_header] && !state[:header_closed]
      return process_header_line(line, state, file_info)
    end

    # Content area - handle include_code
    if line.include?('include_code')
      return process_include_code(line)
    end

    line
  end

  def handle_header_delimiter(state, file_info)
    if state[:in_header]
      # Closing header - build the new frontmatter
      state[:header_closed] = true
      return build_frontmatter(state, file_info)
    else
      state[:in_header] = true
      return nil # Don't output opening delimiter yet
    end
  end

  def process_header_line(line, state, file_info)
    # Categories start
    if line.match?(/^categories:\s*$/)
      state[:in_categories] = true
      state[:in_tags] = false
      return nil
    end

    # Tags start
    if line.match?(/^tags:\s*$/)
      state[:in_tags] = true
      state[:in_categories] = false
      return nil
    end

    # Category/tag item
    if match = line.match(/^\s+-\s+(.*)/)
      item = match[1].gsub(/['"]/, '').strip
      if state[:in_categories]
        state[:categories] << item
      elsif state[:in_tags]
        state[:tags] << item
      end
      return nil
    end

    # If we hit another key, close categories/tags
    if line.match?(/^\w+:/) && (state[:in_categories] || state[:in_tags])
      state[:in_categories] = false
      state[:in_tags] = false
    end

    # Extract title
    if match = line.match(/^title:\s*["']?(.+?)["']?\s*$/)
      state[:title] = match[1]
      return nil
    end

    # Extract permalink/url
    if match = line.match(/^(?:permalink|url):\s*(.+)/)
      state[:has_url] = true
      state[:url] = match[1].strip
      return nil
    end

    # Skip these fields entirely
    if line.match?(/^(?:layout|author|date|slug|comments|wordpress_id|published):/)
      return nil
    end

    nil
  end

  def build_frontmatter(state, file_info)
    lines = []
    lines << HEADER_DELIMITER
    lines << "author: #{AUTHOR}"
    lines << "title: \"#{state[:title] || file_info[:slug].tr('-', ' ').capitalize}\""
    lines << "date: #{file_info[:date]}"

    # Use extracted URL or generate from file info
    url = state[:has_url] ? state[:url] : file_info[:url]
    lines << "url: #{url}"

    lines << "slug: #{file_info[:slug]}"

    # Categories
    if state[:categories].any?
      lines << "categories:"
      state[:categories].each do |cat|
        lines << "  - #{cat}"
      end
    end

    # Tags
    if state[:tags].any?
      lines << "tags:"
      state[:tags].each do |tag|
        lines << "  - #{tag}"
      end
    end

    lines << "draft: false"
    lines << HEADER_DELIMITER

    lines
  end

  def process_include_code(line)
    parts = line.split
    file_path = parts[-2]
    full_path = File.join(@code_dir, file_path)

    if File.exist?(full_path)
      code_content = File.read(full_path)
      code_content = code_content.gsub('<', '&lt;').gsub('>', '&gt;')
      "<pre><code>\n#{code_content}</code></pre>"
    else
      warn "Warning: Code file '#{full_path}' not found"
      line
    end
  end

  def write_hugo_file(original_filename, content)
    FileUtils.mkdir_p(@output_dir)
    # Keep original filename with date
    output_path = File.join(@output_dir, original_filename.sub(/\.markdown$/, '.md'))

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