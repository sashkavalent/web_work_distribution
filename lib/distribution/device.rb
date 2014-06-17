class Device < Struct.new(:id, :name, :service_count, :work_amount)

  def service_period
    ((Date::MONTHNAMES.count - 1) / service_count).to_i
  end
end
