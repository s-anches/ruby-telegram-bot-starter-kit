require './models/user'
require './lib/message_sender'
require 'google/apis/sheets_v4'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user
  attr_reader :logger

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id)
    @google = options[:google]
    @spreadsheet_id = options[:spreadsheet_id]
    @logger = AppConfigurator.new.get_logger
  end

  def respond
    on /^\/start/ do
      answer_with_greeting_message
    end

    on /^\/stop/ do
      answer_with_farewell_message
    end

    on /^\/google/ do
      google
    end

    on /^\/update/ do
      spreadsheet_id = "1yimoy-TikQiTtKrtAqzyTPRbW4pi36E5aJ-HnpcKOKE"

      range = 'Ответы на форму (1)!A1:E'

      response = @google.get_spreadsheet_values(spreadsheet_id, range)
      header = response.values.first.map(&:to_s)
      response.values.drop(1)
      puts 'No data found.' if response.values.empty?

      response.values.each do |row|
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "#{row[0]}, #{row[1]}, #{row[2]}, #{row[3]}, #{row[4]}"
        )
      end

      # value_input_option = "USER_ENTERED"
      # data = [
      #   {
      #     range: "Лист1!A12:C13",
      #     majorDimension: "ROWS",
      #     values: [["This is A12", "This is C12"], ["This is A13", "This is C13"]]
      #   }, {
      #     range: "Лист1!D15:E16",
      #     majorDimension: "COLUMNS",  # сначала заполнять столбцы, затем ряды (т.е. самые внутренние списки в values - это столбцы)
      #     values: [["This is D15", "This is D16"], ["This is E15", "=5+5"]]
      #   },
      # ]
      #
      # batch_update_values = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(
      #     data: data,
      #     value_input_option: value_input_option)
      #
      # response = @google.batch_update_values(spreadsheet_id, batch_update_values)
      # puts "#{response.total_updated_cells} cells updated."
      # logger.debug "Respone: #{response}"
    end

    on /^\/create/ do
      spreadsheet_id = @spreadsheet_id
      # range = 'Лист1!A1:E'

      value_input_option = "USER_ENTERED"
      data = [
        {
          range: "Лист1!A12:C13",
          majorDimension: "ROWS",
          values: [["This is A12", "This is C12"], ["This is A13", "This is C13"]]
        }, {
          range: "Лист1!D15:E16",
          majorDimension: "COLUMNS",  # сначала заполнять столбцы, затем ряды (т.е. самые внутренние списки в values - это столбцы)
          values: [["This is D15", "This is D16"], ["This is E15", "=5+5"]]
        },
      ]

      batch_update_values = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(
          data: data,
          value_input_option: value_input_option)

      response = @google.batch_update_values(spreadsheet_id, batch_update_values)
      # header = response.values.first.map(&:to_s)
      # response.values.drop(1)
      # puts 'No data found.' if response.values.empty?
      puts "#{response.total_updated_cells} cells updated."
      logger.debug "Respone: #{response}"
      # response.values.each do |row|
      #   bot.api.send_message(
      #     chat_id: message.chat.id,
      #     text: "#{row[0]}, #{row[1]}, #{row[2]}, #{row[3]}, #{row[4]}"
      #   )
      # end
    end

    on /^\/options (.+)/ do |arg|
      answer_with_message("Options sended:")
      answer_with_message("#{arg}")
    end

    on /^\/args (.+) (.+)/ do |arg, arg2|
      answer_with_message("Args sended:")
      answer_with_message("#{arg}")
      answer_with_message("#{arg2}")
    end

    on /^\/three (.+) (.+) (.+)/ do |arg, arg2, arg3|
      answer_with_message("Args sended:")
      answer_with_message("#{arg}")
      answer_with_message("#{arg2}")
      answer_with_message("#{arg3}")
    end
  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      when 3
        yield $1, $2, $3
      end
    end
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def google
    spreadsheet_id = @spreadsheet_id
    range = 'Лист1!A1:E'

    response = @google.get_spreadsheet_values(spreadsheet_id, range)
    header = response.values.first.map(&:to_s)
    response.values.drop(1)
    puts 'No data found.' if response.values.empty?

    response.values.each do |row|
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "#{row[0]}, #{row[1]}, #{row[2]}, #{row[3]}, #{row[4]}"
      )
    end
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end
end
