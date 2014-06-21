require 'rubyXL'

class DevicesXLSXDriver

  DEVICE_COLUMN_NAMES = OpenStruct.new(id: "Инвентарный номер",
    name: "Наименование", service_count: "Число ТО за год",
    work_amount: "Норма трудоемкости, чел.*час.")
  END_OF_TABLE_LABEL = 'ИТОГО:'
  START_MONTH_COLUMN_NUMBER = 5

  attr_reader :months_count

  def initialize(path_to_xlsx)
    @path_to_xlsx = path_to_xlsx
    @workbook = RubyXL::Parser.parse(path_to_xlsx, skip_filename_check: true)
    @worksheet = @workbook[0]
    @table_start_line = find_line_by_text(DEVICE_COLUMN_NAMES.id)
    @table_end_line = find_line_by_text(END_OF_TABLE_LABEL)
    @table = @worksheet.get_table(DEVICE_COLUMN_NAMES.id)
    @months_count = @table[:sorted_headers].count - START_MONTH_COLUMN_NUMBER
  end

  def import
    devices = @table[:table].map do |row|

      id = row[DEVICE_COLUMN_NAMES.id]
      name = row[DEVICE_COLUMN_NAMES.name]
      service_count = row[DEVICE_COLUMN_NAMES.service_count]
      work_amount = row[DEVICE_COLUMN_NAMES.work_amount]

      if !(id.nil? || name.nil? || service_count.nil? || work_amount.nil?)
        Device.new(id, name, service_count, work_amount)
      end

    end.compact

    devices
  end

  def export_to_file(serialized_work_shedule, output_path)
    work_for_months = serialized_work_shedule[:work_for_months]
    devices_works = serialized_work_shedule[:devices_works]

    devices_works.each do |device, months_numbers|
      months_numbers.each do |number|
        @worksheet[find_line_by_text(device.id)][START_MONTH_COLUMN_NUMBER + number].change_contents(device.work_amount)
      end
    end

    last_column_number = START_MONTH_COLUMN_NUMBER + @months_count
    (START_MONTH_COLUMN_NUMBER..last_column_number).each_with_index do |column_index, month_index|
      @worksheet.add_cell(@table_end_line, column_index, work_for_months[month_index])
    end
    @workbook.write(output_path)
  end

  private

  def find_line_by_text(text)
    @worksheet.extract_data.index { |line| line.index(text) if !line.nil? }
  end

end
