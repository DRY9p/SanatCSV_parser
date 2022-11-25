# frozen_string_literal: true

require 'csv'
require 'json'

# Модуль реализует форматирование CSV файла выгружаемого из программного продукта Санаториум
module Parser
  @@positions = []
  @@hash_of_position = {}

  def self.positions
    @@positions
  end

  def self.hash_of_position
    @@hash_of_position
  end

  # Метод возвращает табличное представление CSV для чтения по строке или столбцу

  def self.to_table(path)
    CSV.parse(File.read(path), headers: true)
  end

  # Метод форматирует строки CSV файла и добавляет их в массив
  def self.encode_csv(path, index, *buffer)
    File.open(path, 'rb:UTF-16LE').each do |line|
      encode_line = line.encode('UTF-8')
      formatted_line = encode_line.gsub(/[",\t]/, '"' => '', ',' => '.', "\t" => ',')

      buffer << CSV.parse(formatted_line).flatten!(1)
    end

    buffer.delete_at(0) if index.positive?

    buffer.each { |item| positions << item }

    buffer.size
  end

  # Восвращает массив строк позиций csv файла
  # 1 аргумент - номер столбца
  def self.get_pos_col(num, *buffer)
    positions.each { |item| buffer << item[num] }

    buffer
  end

  def self.encode_csv_rus(combined_pos, *encode_lines)
    combined_pos.each { |line| encode_lines << line.gsub(',', ';') }

    encode_lines
  end

  # Метод возвращающий хэш всех позиций "get_hash"
  def self.get_hash(convert_csv_positions)
    all_pos_table = to_table(convert_csv_positions)
    all_pos_table.each { |column| hash_of_position[column[0]] = column[1] }

    hash_of_position
  end

  # Метод возвращает массив индентификаторов каждой позиции в отчете счета детально
  def self.compare_id(csv_path, rows, log_file)
    hash = get_hash(csv_path)

    column_pos = get_pos_col(2)
    column_pos.each_with_index do |pos, index|
      rows << hash.key(pos)

      if hash.key(pos).nil? && index.positive?
        log_file.print "Позиция \'#{index + 1}\' не добавлена\n\"#{pos}\", отсутвует id в файле #{csv_path}\n"

        positions.delete_at(index)
      end
    end

    rows
  end

  # Метод добавлет в каждую строку идентификатор каждой позиции/место выгрузки
  # Для формирования правильного хэдера в данном коммите значение column[0] = 'ColumnName'
  def self.paste_column(column, extra_column, *edit_pos)
    [column, extra_column].map { |obj| obj.delete_at(1) }

    positions.each_with_index do |line, index|
      line.insert(0, column[index], extra_column[index])

      edit_pos << line.to_csv.gsub('﻿', '')
    end

    edit_pos
  end
end
