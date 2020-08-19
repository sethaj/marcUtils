#!/usr/bin/env ruby

require 'rubygems'
require 'marc'
require 'slop'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-i', '--in', 'folder with input files', required: true
    opt.string '-o', '--out', 'folder with output files', required: true
    opt.string '-p', '--pattern', 'pattern to match when selecting input files' do
      puts opts
    end
  end
rescue Slop::Error => e
  puts e
  puts "rename_MARCXML_from_001.rb: batch rename directory of MARC files (one record per file) using control number in 001"
  puts "usage: rename_MARCXML_from_001.rb -i path/to/get/input -o path/to/write/output [-p glob_pattern]"
  puts "Note: The script always uses a glob pattern of '*.xml' when operating in the input directory."
  puts "E.g. -p foo -> Input files wil be path/to/input/files/*foo*.xml"
  exit
end


file_glob = ''
if opts[:pattern]
  file_glob = "*#{opts[:pattern]}*.xml"
else
  file_glob = "*.xml"
end

glob = "#{opts[:in]}/#{file_glob}"

puts "Checking #{glob}"


Dir.glob("#{glob}").sort.each do |filename|
  reader = MARC::XMLReader.new(filename)
  for record in reader
        id = record['001'].to_s.delete_prefix('001 ')
    f = File.open("#{opts[:out]}/#{id}.xml", 'w')
    f.write(record.to_xml)
  end

end
