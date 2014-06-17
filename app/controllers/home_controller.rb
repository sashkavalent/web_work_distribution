class HomeController < ApplicationController
  def index
  end

  def upload
    name = params['xlsx'].original_filename
    directory = 'xlsx_files'
    path = File.join(directory, name)
    # File.open(path, "wb") { |file| file.write(params['xlsx'].read) }
    render action: :index
  end
end
