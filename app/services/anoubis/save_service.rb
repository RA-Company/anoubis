##
# Service for store data into the file
class Anoubis::SaveService < Anoubis::ApplicationService
  ##
  # Store data to file
  # @param file_name [String] Name of file
  # @param text [String] Saved text
  def call(file_name, text)
    file = File.open(file_name, "w")
    file.write(text)
    file.close
  end
end