#!/usr/bin/env ruby

# Restrict arguments to a specified class.
require 'optparse'
require 'csv'
require 'yaml'


QID_DEFAULT         = 'holding_institution'
AS_RECORDED_DEFAULT = 'holding_institution_as_recorded'
DEFAULT_CONFIG      = File.expand_path '../config.yml', __FILE__
options             = {
  qid:         QID_DEFAULT,
  as_recorded: AS_RECORDED_DEFAULT,
}

def validate_csv csv, options
  errors = []
  errors << validate_headers(csv, options)
  errors << validate_data(csv, options)
  errors.compact!
  return if errors.empty?
  raise %Q{Errors encountered:\n#{errors.join "\n"}}
end

def validate_data csv, options
  missing_qid     = []
  missing_name    = []
  qid_col         = options[:qid]
  as_recorded_col = options[:as_recorded]
  row_index = 0
  CSV.foreach csv, headers: true do |row|
    row_index += 1
    missing_qid << row_index if row[qid_col].to_s.strip.empty?
    missing_name << row_index if row[as_recorded_col].to_s.strip.empty?
  end

  return if missing_qid.empty? && missing_name.empty?
  "Rows missing #{qid_col}: #{missing_qid.size}; and #{as_recorded_col}: #{missing_name.size}"
end

def validate_headers csv, options
  headers = CSV.readlines(csv).first
  # binding.pry
  missing = %i{qid as_recorded}.flat_map { |k|
    headers.include?(options[k]) ? [] : "#{k}: '#{options[k]}'"
  }

  return if missing.empty?

  "Could not find required column(s) -- #{missing.join ', '}"
end

def read_institutions csv, options
  data = {}
  qid_col = options[:qid]
  name_col = options[:as_recorded]
  CSV.foreach csv, headers: true do |row|
    qid  = row[qid_col]
    next if qid.to_s.strip.empty?
    next if data[qid_col]
    as_recorded = row[name_col]
    next if as_recorded.to_s.strip.empty?
    data[qid] = as_recorded
  end
  data
end

def check_config config, csv, options
  csv_institutions = read_institutions csv, options
    # binding.pry
  missing = csv_institutions.keys.map { |qid|
    next if config.any? { |inst| inst[:qid] == qid }
    [qid, csv_institutions[qid]]
  }.compact
  return if missing.empty?

  message = missing.map { |pair|
    {
      qid: pair.first,
      name: (pair[1] || 'REPLACE_WITH_INST_NAME'),
      directory: 'REPLACE_WITH_DIR_NAME'
    }
  }.to_yaml.lines[1..-1].join
  STDERR.puts "CSV has institutions not in the config."
  STDERR.puts "Complete the following lines and add them to config.yml"
  STDERR.puts
  STDERR.puts message
  STDERR.puts
  raise "Error: config.yml is missing values"
end

def validate_config config
  # QIDs and folders must be unique
  qids = Hash.new { |hash,key| hash[key] = 0 }
  dirs = Hash.new { |hash,key| hash[key] = 0 }
  config.each do |inst|
    qids[inst[:qid]] += 1
    dirs[inst[:directory]] += 1
  end
  dupes = []
  qids.each do |qid, count|
    dupes << "QID: #{qid}, couunt: #{count}" if count > 1
  end
  dirs.each do |dir, count|
    dupes << "Directory: #{dir}, couunt: #{count}" if count > 1
  end
  return if dupes.empty?
  STDERR.puts "Invalid config.yml; the following values are duplicated:"
  STDERR.puts
  STDERR.puts dupes.join "\n"
  STDERR.puts
  raise "Invalid config; see errors above"
end

ARGV.options do |opts|
  opts.banner = "Usage: #{File.basename __FILE__} [OPTIONS] CSV_TO_SPLIT"

  q_msg = %Q{Institution QID column; default: #{QID_DEFAULT}  }
  opts.on '-q', '--qid-column COLUMN', q_msg do |qid|
    options[:qid] = qid
  end

  a_msg = %Q{Institution 'as recorded' column; default: #{AS_RECORDED_DEFAULT}  }
  opts.on '-a', '--as-recorded-column COLUMN', a_msg do |as_recorded|
    options[:as_recorded] = as_recorded
  end

  opts.parse!
end

# read the config and fail if it's not present
abort "Cannot find find config file #{DEFAULT_CONFIG}" unless File.exist? DEFAULT_CONFIG
config = YAML.load_file DEFAULT_CONFIG
csv = ARGV.shift

validate_config config
validate_csv csv, options
check_config config, csv, options
