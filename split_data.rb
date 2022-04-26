#!/usr/bin/env ruby

# Restrict arguments to a specified class.
require 'optparse'
require 'csv'
require 'yaml'
require 'logger'


OUT_DIR              = File.expand_path '../member-data', __FILE__
QID_DEFAULT         = 'holding_institution'
AS_RECORDED_DEFAULT = 'holding_institution_as_recorded'
DEFAULT_CONFIG      = File.expand_path '../config.yml', __FILE__

options             = {
  qid:         QID_DEFAULT,
  as_recorded: AS_RECORDED_DEFAULT,
}

logger = Logger.new STDOUT
logger.level = Logger::INFO

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

  c_msg = %Q{Overwrite existing CSVs}
  opts.on '-c', '--clobber', c_msg do |clobber|
    options[:clobber] = clobber
  end

  opts.parse!
end

# read the config and fail if it's not present
abort "Cannot find find config file #{DEFAULT_CONFIG}" unless File.exist? DEFAULT_CONFIG
config = YAML.load_file DEFAULT_CONFIG
csv = ARGV.shift


abort "Please provide a CSV file" unless csv
abort "Cannot find CSV file: '#{csv}'" unless File.exist? csv


qid_col = options[:qid]
name_col = options[:as_recorded]

validate_config config
validate_csv csv, options
check_config config, csv, options

CSV_NAME_PATTERN = %r{(\d{4}-\d{2}-\d{3})(.*)\.csv}
csv =~ CSV_NAME_PATTERN
file_date = $1
file_detail = $2
out_base = "#{file_date}#{file_detail}"
out_base = File.basename(csv, '.csv') if out_base.strip.empty?

header = CSV.readlines(csv).first
lines_by_qid = {}
CSV.foreach csv, headers: true do |row|
  qid = row[qid_col]
  (lines_by_qid[qid] ||= []) << row
end

config.each do |inst|
  next unless lines_by_qid.include? inst[:qid]
  dir          = inst[:directory]
  inst_out_dir = File.join OUT_DIR, dir
  out_file     = File.join inst_out_dir, "#{out_base}-#{dir}.csv"
  Dir.mkdir inst_out_dir unless Dir.exist? inst_out_dir
  if File.exist? out_file
    if options[:clobber]
      logger.warn { "Overwriting existing file: #{out_file}" }
    else
      logger.warn { "File exists; skipping: #{out_file}"}
      next
    end
  end
  CSV.open out_file, 'wb' do |csv|
    csv << header
    lines_by_qid[inst[:qid]].each { |row| csv << row }
  end
  logger.info { "Wrote: #{out_file}" }
end
