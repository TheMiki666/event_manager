

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('secret.key').strip

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

#Assignment 1
#Clean phone number
def clean_phone_number(phone_number)
  return "No valid phone" if phone_number.nil?

  clean_phone=phone_number.delete(" ().-")
  if clean_phone.length <10 || clean_phone.length>11
    clean_phone="No valid phone"
  elsif clean_phone.length==11
    if clean_phone[0]=='1'
      clean_phone=clean_phone[1..clean_phone.length-1]
    else
      clean_phone="No valid phone"
    end
  end
  clean_phone
end

#Assignment 2
#Using the registration date and time we want to find out what the peak registration hours are.

#We will not use the Time or Date methords, becauser we are having problems when trying to parse directly some of the strings
#Instead, we will try to find the hour in the string, beause we only need the hour, not the whole time
#In Assignment 3 i demonstrate that I can manage the Date class
def extract_hour(string)
  i = string.index(':')
  string[i-2..i-1].delete(' ').to_i
end

#Assignment 3
# Use Date#wday to find out the day of the week. What days of the week did most people register?
def extract_day(string)
  
#The Date class needs a little help to parse the string
  i = string.index('/')
  month=string[0..i-1].to_i
  cut =string[i+1..string.length-1]
  j = cut.index('/')
  day=cut[0..j-1].to_i
  year=cut[j+1..j+2].to_i + 2000
  date=Date.new(year, month, day)
  case date.wday
  when 0
    'Sunday'
  when 1
    'Monday'
  when 2
    'Tuesday'
  when 3
    'Wednesday'
  when 4
    'Thursday'
  when 5
    'Friday'
  when 6
    'Saturday'
  end
end

#Assignment 2 and 3
def peak_frecuency(array)
  freq = array.reduce(Hash.new(0)) { |h,v| h[v] += 1; h }
  array.max_by { |v| freq[v] }
end

def save_thank_you_letter(id, form_letter)
    
  Dir.mkdir ('output') unless Dir.exist?('output')

  filename="output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts form_letter
  end

end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
#Assignment 2
hours = []
#Assignment 3
days=[]

contents.each do |row|
  id=row[0]

  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  #Assignment 1
  phone = clean_phone_number(row[:homephone])

  #Assignment 2
  #Using the registration date and time we want to find out what the peak registration hours are.
  hours.push(extract_hour(row[:regdate]))

  #Assignment 3
  # Use Date#wday to find out the day of the week. What days of the week did most people register?
  
  days.push(extract_day(row[:regdate]))

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
  
end

puts "The peak registrations hour is #{peak_frecuency(hours)}"
puts "The peak registrations day of the week is #{peak_frecuency(days)}"
