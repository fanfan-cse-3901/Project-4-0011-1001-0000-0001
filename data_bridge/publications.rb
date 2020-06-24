# frozen_string_literal: true

require 'mechanize'
require 'json'

agent = Mechanize.new
page = agent.get 'http://web.cse.ohio-state.edu/~davis.1719/publications.html'

# get content form <li> tags
event_list = []
page.search('//ul/li').each do |i|
  # Reject [HTML], [PDF], link into item
  item = i.text.split("\n").reject do |c|
    c.empty? ||
      c.match(/(HTML)|(PDF)/) ||
      # referenced from: https://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
      c.match(%r{(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)})
  end

  # Add actual link into item
  i.search('a').each do |link|
    item << link['href']
  end

  # put item into event_list
  event_list << item
end

# get content form <i> tags
list_italic = []
page.search('//ul/li/i').each do |i|
  list_italic << i.text unless list_italic.include? i.text
end

# divide event_list equally
event_list_left, event_list_right = event_list.each_slice((event_list.size / 2.0).round).to_a

def json_output(arr, file_name)
  file = File.open "./data/#{file_name}.json", 'w' do |line|
    line.puts arr.to_json
  end
end

# output array to file
json_output event_list_left, 'event_list_left'
json_output event_list_right, 'event_list_right'
json_output list_italic, 'list_italic'
