# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'time'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

def find_best_hour(reg_dates)
  reg_hours = reg_dates.map(&:hour)
  count_reg_hour = Hash.new(0)
  reg_hours.each do |hour|
    count_reg_hour[hour] += 1
  end
  max_count = count_reg_hour.max_by { |_key, value| value }[1]
  (count_reg_hour.filter { |_key, value| value == max_count }).keys
end

def find_best_wday(reg_dates)
  reg_wday = reg_dates.map(&:wday)
  count_reg_wday = Hash.new(0)
  reg_wday.each do |wday|
    count_reg_wday[wday] += 1
  end
  max_count = count_reg_wday.max_by { |_key, value| value }[1]
  (count_reg_wday.filter { |_key, value| value == max_count }).keys
end

def to_s_weekday(num)
  weekday = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
  weekday[num]
end

reg_dates = contents.map do |value|
  target = Time.strptime(value[:regdate], '%Y/%d/%I %H:%M')
  Time.mktime(target.year + 2000, target.month, target.day, target.hour, target.min)
end
puts "Hours of the day the most people registered: #{find_best_hour(reg_dates).join(', ')}"
puts "Weekday the most people registered: #{(find_best_wday(reg_dates).map do |value|
  to_s_weekday(value)
end).join(', ')}"
