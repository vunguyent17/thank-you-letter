# frozen_string_literal: true

puts 'Event Manager Initialized!'

# contents = File.read('event_attendees.csv')
# puts contents

# lines = File.readlines('event_attendees.csv')
# kq = lines.filter_map.with_index do |line, index|
#     line.split(',')[2] if index != 0
# end
# p kq

require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  clean_number = phone_number.to_s.tr('^0-9', '')
  return clean_number[-10..-1] if clean_number.length == 10 || (clean_number.length == 11 && clean_number[0] == '1')

  nil
end

# def legislators_by_zipcode(zip)
#   civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
#   civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
#   begin
#     legislators = civic_info.representative_info_by_address(
#       address: zip,
#       levels: 'country',
#       roles: %w[legislatorUpperBody legislatorLowerBody]
#     )
#     legislators = legislators.officials
#     legislators_name = legislators.map(&:name)
#     legislators_name.join(', ')
#   rescue StandardError
#     'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
#   end
# end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.map do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(row[:homephone])

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end
