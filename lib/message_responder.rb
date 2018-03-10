require './models/user'
require './lib/message_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id)
    @google = options[:google]
    @spreadsheet_id = options[:spreadsheet_id]
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
