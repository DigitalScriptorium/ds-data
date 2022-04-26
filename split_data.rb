#!/usr/bin/env ruby

# Restrict arguments to a specified class.
require 'optparse'
require 'csv'
require 'yaml'
require 'logger'

LOGGER = Logger.new STDOUT
LOGGER.level = (Logger::DEBUG || ENV['DS_LOGLEVEL'])

OUT_DIR              = File.expand_path '../member-data', __FILE__
QID_DEFAULT         = 'holding_institution'
AS_RECORDED_DEFAULT = 'holding_institution_as_recorded'
DEFAULT_CONFIG      = File.expand_path '../config.yml', __FILE__

options = {
  qid:         QID_DEFAULT,
  as_recorded: AS_RECORDED_DEFAULT,
}

##
# Validate the headers and data
def validate_csv csv, qid_col:, as_recorded_col:
  errors = []
  errors << validate_headers(csv, qid_col: qid_col, as_recorded_col: as_recorded_col)
  errors << validate_data(csv, qid_col: qid_col, as_recorded_col: as_recorded_col)
  errors.compact!
  return if errors.empty?
  raise %Q{Errors encountered:\n#{errors.join "\n"}}
end

def validate_data csv, qid_col:, as_recorded_col:
  missing_qid     = []
  missing_name    = []
  row_index = 0
  CSV.foreach csv, headers: true do |row|
    row_index += 1
    missing_qid << row_index if row[qid_col].to_s.strip.empty?
    missing_name << row_index if row[as_recorded_col].to_s.strip.empty?
  end

  return if missing_qid.empty? && missing_name.empty?
  "Rows missing #{qid_col}: #{missing_qid.size}; and #{as_recorded_col}: #{missing_name.size}"
end

def validate_headers csv, qid_col:, as_recorded_col:
  headers = CSV.readlines(csv).first
  missing = [qid_col, as_recorded_col].flat_map { |header|
    headers.include?(header) ? [] : header
  }

  return if missing.empty?

  "Could not find required column(s) -- #{missing.join ', '}"
end

def read_institutions csv, qid_col:, as_recorded_col:
  data = {}
  CSV.foreach csv, headers: true do |row|
    qid  = row[qid_col]
    next if qid.to_s.strip.empty?
    next if data[qid_col]
    as_recorded = row[as_recorded_col]
    next if as_recorded.to_s.strip.empty?
    data[qid] = as_recorded
  end
  data
end

def check_config config, csv, qid_col:, as_recorded_col:
  csv_institutions = read_institutions csv, qid_col: qid_col, as_recorded_col: as_recorded_col
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
  LOGGER.error "CSV has institutions not in the config."
  LOGGER.error "Complete the following lines and add them to config.yml"
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
    dupes << "QID: #{qid}, occurrences: #{count}" if count > 1
  end
  dirs.each do |dir, count|
    dupes << "Directory: #{dir}, occurrences: #{count}" if count > 1
  end
  return if dupes.empty?
  LOGGER.error "Invalid config.yml; the following values are duplicated:"
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

  opts.on '--verbose', 'Be verbose' do |verbose|
    options[:verbose] = verbose
  end

  opts.parse!
end
qid_col = options[:qid]
name_col = options[:as_recorded]


# read the config and fail if it's not present
abort "Cannot find find config file #{DEFAULT_CONFIG}" unless File.exist? DEFAULT_CONFIG
config = YAML.load_file DEFAULT_CONFIG

csv = ARGV.shift
abort "Please provide a CSV file" unless csv
abort "Cannot find CSV file: '#{csv}'" unless File.exist? csv

begin
  validate_config config
  validate_csv csv, qid_col: qid_col, as_recorded_col: name_col
  check_config config, csv, qid_col: qid_col, as_recorded_col: name_col

  header      = CSV.readlines(csv).first
  out_base    = File.basename csv, '.csv'
  rows_by_qid = {}
  CSV.foreach csv, headers: true do |row|
    qid = row[qid_col]
    (rows_by_qid[qid] ||= []) << row
  end

  config.each do |inst|
    next unless rows_by_qid.include? inst[:qid]
    dir          = inst[:directory]
    inst_out_dir = File.join OUT_DIR, dir
    out_file     = File.join inst_out_dir, "#{out_base}-#{dir}.csv"
    Dir.mkdir inst_out_dir unless Dir.exist? inst_out_dir
    if File.exist? out_file
      if options[:clobber]
        LOGGER.warn { "Overwriting existing file: #{out_file}" }
      else
        LOGGER.warn { "File exists; skipping: #{out_file}" }
        next
      end
    end
    CSV.open out_file, 'wb' do |csv|
      csv << header
      rows_by_qid[inst[:qid]].each { |row| csv << row }
    end
    LOGGER.info { "Wrote: #{out_file}" }
  end
rescue StandardError => e
  LOGGER.fatal e
  LOGGER.error e.backtrace if options[:verbose]
end
