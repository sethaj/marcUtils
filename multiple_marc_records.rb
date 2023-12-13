#!/usr/bin/env ruby

require 'marc'
require 'nokogiri'
require 'csv'
require 'tempfile'
require 'fileutils'
require 'byebug'

# We're seeing cases where a single book will have multiple marc records.
# It's usually a duplicate file but named after a differnt ISBN, so both an ebook ISBN and hardcover ISBN
# An example is:
# https://doi.org/10.3998/mpub.799908
#
# [iad1-shared-e1-10]$ grep -wl 10.3998/mpub.799908 *.mrc
# 9780472029372.mrc    # ebook ISBN
# 9780472071968.mrc    # hardcover ISBN
#
# It's incorrect to have multiple marc records. There should be a single marc record that has the ISBNs for each format in it.
# It looks like multiple marc records are messing up marc generation in fulcimen.
#
# This is for HELIO-4550

# Go through a directory of individual .mrc records and get DOIs
# If there's a DOI in multiple marc records, report it.
marc_dir = ARGV[0] || "/home/sethajoh/fulcrum-ftp/MARC_from_Cataloging/UMPEBC"

dois = {}
record_count = 0
Dir.glob(marc_dir + "/*mrc") do |file|
  next unless File.exist? file
  begin
    reader = MARC::Reader.new(file)
    record = reader.first
    record_count += 1
    # UMPEBC has dois in 024 "a" but not 035
    # bigten has them in 035 "a" but not 024
    # There's also always 856 "u" but I think that might have something to do with umich mirlyn (or whatever it is now)
    # So I don't know. I'm just looking eyeballing the marc xml so maybe binary will be different (but I really hope not that would be worse)
    doi = if !record["024"].nil? && !record["024"]["a"].nil?
            record["024"]["a"]
          elsif !record["035"]["a"].nil? && !record["024"]["a"].nil?
            record["035"]["a"]
          else
            "missing doi!"
          end

    dois[doi] = [] unless dois[doi]
    dois[doi] << file

  rescue StandardError => e
    puts "error on #{file}: #{e}"
  end
end

puts "There are #{record_count} total .mrc records"
puts "There are #{dois.count} total unique DOIs/books"


multi_marc = 0
dois.each do |doi, files|
  if files.count > 1
    # puts "#{doi}\t#{files.join("\n")}"
    multi_marc += 1
  end
end

puts"#{multi_marc} books have the same DOI in multiple marc records"

# Check whether the DOIs with multiple marc records are
# 1. in KBART files
# 2. in aggregate marc xml files

kbart_folder = "/home/sethajoh/fulcrum-ftp/ftp.fulcrum.org/UMPEBC/KBART/"
aggregate_marc_folder = "/home/sethajoh/fulcrum-ftp/ftp.fulcrum.org/UMPEBC/MARC"

dois.each do |doi, files|
  if files.count > 1
    result = `cd #{kbart_folder}; grep -wl #{doi} *.csv`
    kbarts = result.split("\n")
    products = []
    kbarts.each do |kbart|
      products << kbart.gsub(/_\d\d\d\d-\d\d-\d\d\.csv$/, "")
    end

    # now look in the marcs and make sure the DOI is there too
    products.each do |product|
      result = `cd #{aggregate_marc_folder}; grep -wl #{doi} #{product}*.xml 2>/dev/null`
      # You get back a "" if there are no results
      if result.empty?
        puts "#{doi} from #{files.map{|file| File.basename(file)}} does not exist in #{product}"
      end
    end
  end
end

# For UMPEBC it turns out this isn't really a problem. I mean yes, it's weird that so many books have multiple marc records, but it
# doesn't seem to totally break heliotropium.
# The output:
#
# ➜  marcUtils git:(master) ✗ ruby multiple_marc_records.rb
# There are 2420 total .mrc records
# There are 1999 total unique DOIs/books
# 409 books have the same DOI in multiple marc records
# 10.3998/mpub.799908 from ["9780472071968.mrc", "9780472029372.mrc"] does not exist in UMPEBC_2013
# 10.3998/mpub.17356 from ["0472112058clothalk.paper.mrc", "9780472112050.mrc"] does not exist in UMPEBC_2011PRE
# 10.3998/mpub.17356 from ["0472112058clothalk.paper.mrc", "9780472112050.mrc"] does not exist in UMPEBC_COMPLETE



