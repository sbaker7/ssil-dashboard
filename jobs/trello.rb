require 'trello'

include Trello

Trello.configure do |config|

  #Application Key
  config.developer_public_key = ENV['TRELLO_DEVELOPER_KEY']

  #Auth token granted to a user
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

boards = ENV["TRELLO_BOARDS"].to_s.split(',')

class MyTrello
  def initialize(board_id)
    @board_id = board_id
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
boards.each do |board_id|
  begin
    @MyTrello.push(MyTrello.new(board_id))
  rescue Exception => e
    puts e.to_s
  end
end

SCHEDULER.every '5s', :first_in => 0 do |job|
  @MyTrello.each do |board|
    status = board.status_list()
    send_event(board.board_id, { :items => status })
  end
end
