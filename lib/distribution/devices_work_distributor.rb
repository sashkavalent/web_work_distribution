require_relative 'work_shedule'
require_relative 'device'
require_relative 'devices_xlsx_driver'

class DevicesWorkDistributor

  def initialize(xlsx_path)
    @devices_xlsx_driver = DevicesXLSXDriver.new(xlsx_path)
    devices = @devices_xlsx_driver.import
    @devices = devices.sort_by!(&:work_amount).reverse!

    @work_shedule = WorkShedule.new(months_count: @devices_xlsx_driver.months_count)
  end

  def inspect
    puts 'average = ' + @work_shedule.average.to_s
    puts 'total_amount_of_work = ' + @work_shedule.sum.to_s
    puts 'sum_delta = ' + @work_shedule.sum_delta.to_s
    puts 'sum_delta / total_amount_of_work = ' + (@work_shedule.sum_delta / @work_shedule.sum.to_f * 100).to_s + '%'
    @work_shedule.inspect
  end

  def calculate_work_distribution!
    @devices.each do |device|
      @work_shedule.add_work!(best_start_month(device), device)
    end
  end

  def export
    @devices_xlsx_driver.export_to_file(@work_shedule.serialize, 'export.xlsx')
  end

  private

  def best_start_month(device)
    month_number_with_smallest_delta = 0
    delta = Float::INFINITY

    device.service_period.times do |month_number|
      temp_work_shedule = @work_shedule.clone
      temp_work_shedule.add_work!(month_number, device)
      current_delta = temp_work_shedule.sum_delta
      if current_delta < delta
        delta = current_delta
        month_number_with_smallest_delta = month_number
      end
    end

    month_number_with_smallest_delta
  end
end
