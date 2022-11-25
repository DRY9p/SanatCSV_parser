# frozen_string_literal: true

require_relative 'modules/parser'
require 'json'

current_path = File.dirname(__FILE__)
time = Time.now
file_date = time.strftime('%Y-%m-%d')

# initialize the path of files
convert_csv_positions = "#{current_path}/CSV_Sanat/all_positions_convert.csv"
correct_csv_path = "#{current_path}/CSV_output_data/Payment_data_#{file_date}.csv"
rus_csv_path = "#{current_path}/rus_csv/Payment_data_#{file_date}.csv"

id = ['ID']
place = ['Place']

# create files for write and read
correct_csv = File.new(correct_csv_path, 'w+')
rus_csv = File.new(rus_csv_path, 'w+')
log = File.new('logs/logs.txt', 'a+')
hash = JSON.parse(File.read('paths.json'))

# "(EN)#{file_date}/#{time.strftime('%H:%M:%S')} :: Can't find the path #{file_path} or file/filename by this way\n",
hash['cashboxes'].each_with_index do |file_path, index|
  size = Parser.encode_csv(file_path, index)
  size.times { place << index }

  log.print "#{file_date} | #{time.strftime('%H:%M:%S')} | #{file_path}\n"
rescue Errno::ENOENT
  log.print "#{file_date} | #{time.strftime('%H:%M:%S')} | Не могу найти указанный путь #{file_path} или файл/имя_файла по данному пути \n"
end


id_arr = Parser.compare_id(convert_csv_positions, id, log)

combined_id = Parser.paste_column(place, id_arr)
combined_id.each { |line| correct_csv << line }

ru_combined_pos = Parser.encode_csv_rus(combined_id)
ru_combined_pos.each { |line| rus_csv << line }

log.print "Сгенерировано: #{Parser.positions.size} позиций\n",
          "\n"