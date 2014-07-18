require 'trello'

include Trello

Trello.configure do |config|

  #Application Key
  config.developer_public_key = ENV['TRELLO_DEVELOPER_KEY']

  #Auth token granted to a user
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

boards = {
  "board 1" => ENV['TRELLO_BOARD_ID_1'],
  "board 2" => ENV['TRELLO_BOARD_ID_2'],
  "board 3" => ENV['TRELLO_BOARD_ID_3'],
}

class MyTrello
  def initialize(widget_id, board_id)
    @widget_id = widget_id
    @board_id = board_id
  end

  def widget_id()
    @widget_id
  end

  def board_id()
    @board_id
  end

  def status_list()
    status = Array.new
    Board.find(@board_id).lists.each do |list|
      status.push({label: list.name, value: list.cards.size})
    end
    status
  end
end

@MyTrello = []
boards.each do |widget_id, board_id|
  begin
    @MyTrello.push(MyTrello.new(widget_id, board_id))
  rescue Exception => e
    puts e.to_s
  end
end

SCHEDULER.every '5s', :first_in => 0 do |job|
  @MyTrello.each do |board|
    status = board.status_list()
    send_event(board.widget_id, { :items => status })
  end
end
