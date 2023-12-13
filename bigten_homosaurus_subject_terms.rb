#!/usr/bin/env ruby

require 'marc'
require 'nokogiri'
require 'csv'
require 'tempfile'
require 'fileutils'
require 'byebug'

# For FOPS-458 extract Homosaurus Subject Terms from marc and output a csv with:
#
#     DOI
#
#     ISBN(s)
# 
#       (if multiple, separated by semicolon)
# 
#     Homosaurus subject terms
#
#       if multiple, separated by pipe
#
# Input: the bigten gender and sexuality studies binary marc file (should be 100 books)
# Output: bigten_homosaurus_subject_terms.csv
#
# Use regular/binary marc for this. Our marc xml has been acting up...

marc_path = ARGV[0] || "/home/sethajoh/fulcrum-ftp/ftp.fulcrum.org/bigten/MARC/bigten_gender_and_sexuality_studies.mrc"

raise "no marc at #{marc_path}" unless File.exist?(marc_path)

marc = MARC::Reader.new(marc_path)

header = [
  "DOI",
  "ISBN(s)",
  "Homosaurus Subject Terms"
]

csv = CSV.generate(force_quotes: true) do |row|
  row << header

  marc.each do |record|
    # it looks like dois are in 035 a
    doi = record["035"]["a"]

    # I guess I'm going to make isbns uniform by taking out the hyphens. It's all a mixed bag, some have them some don't
    isbns = []
    record.fields.each_by_tag(["020"]) do |field|
      isbns << field["a"].gsub("-","")
    end

    # Get only the homosaurus subject terms which are 650 "a" with the subfield code "2" being "homoit"
    homoits = []
    record.fields.each_by_tag("650") do |field|
      if field["2"] && field["2"] == "homoit"
        homoits << field["a"]
      end
    end

    row <<  [
      doi,
      isbns.join(";"),
      homoits.join("|")
    ]
  end
end

File.write("bigten_homosaurus_subject_terms.csv", csv)
p "wrote: bigten_homosaurus_subject_terms.csv"