require 'google/apis/sheets_v4'
require 'googleauth'

# require './lib/database_connector'

class GoogleConnect
  def configure
    get_connect
  end

  def get_connect
    # Connect to Google
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = 'Ruby Test APP'
    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open('config/client_secret.json'),
      scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY)

    service
  end

  def get_spreadsheet_id
    YAML::load(IO.read('config/secrets.yml'))['spreadsheet_id']
  end
end
