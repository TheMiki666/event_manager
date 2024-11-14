

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

#Asignment 1
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

contents.each do |row|
  id=row[0]

  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  phone = clean_phone_number(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
  
end
