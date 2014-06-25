class HomeController < ApplicationController
  def index
  end

  def upload
    file_name = params['xlsx'].original_filename
    # directory = 'xlsx_files'
    # path = File.join(directory, name)
    session[:file_link] = nil
    devices_work_distributor = nil
    output_path = 'public/xlsx_files/' + params['xlsx'].original_filename
    begin
      devices_work_distributor = DevicesWorkDistributor.new(params['xlsx'].tempfile.path, params['deep_level'].to_i, output_path)
      devices_work_distributor.calculate_work_distribution!
      devices_work_distributor.export
      # client = Dropbox::API::Client.new(:token  => 'hz9dmkvlle04z063', :secret => 'tztktfadkhixkeb')
      # client.upload 'export.xlsx', File.read('export.xlsx')
      # session[:file_link] = client.ls.first.direct_url
    rescue Exception => e
      @message = 'Проверьте правильность формата файла.'
      render 'index'
      return
    end
    output_path = root_path + output_path
    send_data File.read(Rails.root.to_s + output_path), filename: file_name
    # render 'index'
    # redirect_to :back
  end
end
