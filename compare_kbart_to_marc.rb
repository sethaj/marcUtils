#!/usr/bin/env ruby

require 'marc'
require 'nokogiri'
require 'csv'
require 'tempfile'
require 'fileutils'
require 'byebug'

# usage:
# ruby compare_kbart_to_marc.rb /path/to/kbart.csv /path/to/marc.xml

# Fulcrum style kbarts from 2023 needed
# DOI indentifier in both kbart and marc needed
# csv kbart and xml marc are used

def verify_kbart_header(kbart_header)
  # current as of 2023-10-17
  header = %w[
    publication_title
    print_identifier
    online_identifier
    date_first_issue_online
    num_first_vol_online
    num_first_issue_online
    date_last_issue_online
    num_last_vol_online
    num_last_issue_online
    title_url
    first_author
    title_id
    embargo_info
    coverage_depth
    notes
    publisher_name
    publication_type
    date_monograph_published_print
    date_monograph_published_online
    monograph_volume
    monograph_edition
    first_editor
    parent_publication_title_id
    preceding_publication_title_id
    access_type
  ]

  errors = []
  kbart_header.each_with_index do |col, index|
    if col != header[index]
      errors << "#{index}\tkbart header #{col} does not match #{header[index]}"
    end
  end

  errors
end

def fix_unparseable_marc(temp_file, marc_file_path)
  # I'm seeing parser errors. I don't know how that can be, but stuff like:
  #
  # UMPEBC_Complete.xml:1373: parser error : PCDATA invalid Char value 31
  #<record><leader>03665nam a2200421 i 4500</leader><controlfield tag='003'>a MiU<
  #                                                                         ^

  # It's actually: "\u001Fa MiU" not "a MiU" so... tricky. https://unicodeplus.com/U+001F

  # I think no spaces should be on 003. And it looks like OCLC (for instance) doesn't even use 003.
  # Why is there a "a " in there? Why not just "MiU"? There's probably a reason, but it's I guess not legal marc?
  # We have "MiU" in https://www.loc.gov/marc/organizations/org-search.php but there's no "\u001Fa MiU". Maybe it's a mistake?
  # I'm just going to make it "MiU" because I don't know.

  # A comment in fulcimen originally by Bill says:
  # "MARC-XML doesn't allow non-alphanumerics in the leader by spec so the MARC::XMLWriter turns them into Zs
  # but I guess it's totally fine in binary marc. Great."
  # 
  # Sounds like there are historical issues with this problem.
  
  # There are maybe 4 records like this in UMPEBC_COMPLETE.xml so not many really.

  # AND THEN in a different version of UMPEBC_COMPLETE.xml there's another parse error due the 001 field which looks like:
  # <controlfield tag='001'>\u001Fa10.3998/dh.12172434.0001.001</controlfield>
  #
  # So there's another \u001Fa inserted kind of randomly in another field. I can't even look at the xml in a browser due to this error.
  # https://ftp.fulcrum.org/UMPEBC/MARC/UMPEBC_COMPLETE.xml

  # So it seems to me that there's a problem with how fulcimen writes xml generally? It seems to be slipping the character 
  # "\u001Fa" randomly sometimes? Sigh.

  content = File.readlines(marc_file_path)
  content.each do |line|
    # line = line.gsub("<controlfield tag='003'>\u001Fa MiU<", "<controlfield tag='003'>MiU<") if /<controlfield tag='003'>\u001Fa MiU/.match?(line)
    # line = line.gsub("<controlfield tag='001'>\u001Fa", "<controlfield tag='001'>") if /<controlfield tag='001'>\u001Fa/.match?(line)
    line = line.gsub("\u001Fa", "") if /\u001Fa/.match?(line)
    temp_file.puts line
  end
  temp_file.close
  temp_file
end

kbart_path = ARGV[0]
marc_path = ARGV[1]
raise "no kbart at #{kbart_path}" unless File.exist?(kbart_path)
raise "no marc at #{marc_path}" unless File.exist?(marc_path)

kbart = CSV.read(kbart_path)
errors = verify_kbart_header(kbart.shift)
raise "kbart headers don't match:\n#{errors.join("\n")}" unless errors.empty?


temp_file = Tempfile.new("foo")
temp_file = fix_unparseable_marc(temp_file, marc_path)
FileUtils.mv(temp_file.path, marc_path)
temp_file.unlink

marc = MARC::XMLReader.new(marc_path, parser: "nokogiri")

marc_dois = []
marc_count = 0
marc.each do |record|
  marc_dois << record["024"]["a"]
  marc_count += 1
end

puts "There are #{kbart.count - 1} kbart rows"
puts "There are #{marc_count} marc rows"

kbart_dois = []

kbart.each do |row|
  kbart_dois << row[11]
end

kbart_dois.each do |kbart_doi|
  next if marc_dois.include?(kbart_doi)
  puts "Missing from MARC XML: https://doi.org/#{kbart_doi}"
end





