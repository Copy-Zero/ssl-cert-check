# csv gem testing
require 'csv'
require 'net/http'
require 'openssl'
require 'tty-progressbar'

# begin functions
def get_days_remaining(validity_date)
  time_remaining = validity_date - Time.now
  days_remaining = time_remaining / 86_400
  days_remaining.to_i
end

def format_expiry_date(validity_date)
  # %b is month in 3 letters
  validity_date.strftime('%d-%b-%Y')
end

def get_cert_data(host_name, port)
  # connect to HTTPS site and return the cert object
  # wrap this in error handling for connection failures
  uri = URI::HTTPS.build(host: host_name, port: port)
  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true)
  response.peer_cert.not_after
end

def refresh_cert_dates(ssl_certs)
  # create progress bar and values
  qty_certs = ssl_certs.length
  today = Time.new.strftime('%d-%b-%Y')
  puts "Sites Loaded: #{qty_certs}"
  bar = TTY::ProgressBar.new('updating... [:bar]', total: qty_certs)
  # get new cert dates for each hostname
  refreshed_dates = ssl_certs.map do |row|
    bar.advance
    # use progress bar
    # puts "Checking Hostname: #{row[:hostname]}..."
    expiry_date = get_cert_data(row[:hostname], row[:port])
    row[:last_checked] = today
    row[:expiry_date] = format_expiry_date(expiry_date)
    row[:days_remaining] = get_days_remaining(expiry_date)
    row
  end
  refreshed_dates
end

# =============== Begin main script ===================
# create an array that will contain hashes of each hostname and cert data
ssl_checks = []

# load CSV file
# data will be an array of hashes for each URL
CSV.foreach('data.csv', headers: true, header_converters: :symbol) do |row|
  headers ||= row.headers
  ssl_checks << row.to_h
end

updated_ssl_checks = refresh_cert_dates(ssl_checks)
# p updated_ssl_checks.first.keys

# =================== Wrap up and write data ================
# rebuild headers
update_headers = updated_ssl_checks.first.keys
# write new data to CSV file
CSV.open('data.csv', 'w') do |csv|
  # re-add headers
  csv << update_headers
  # loop through and write row data
  updated_ssl_checks.each do |row|
    csv << row.values
  end
end
