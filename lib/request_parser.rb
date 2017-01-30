require 'apprentice_rota'
require 'error_command'
require 'foreman_command'
require 'menu'
require 'set_menu_command'
require 'get_menu_command'
require 'set_order_command'
require 'get_order_command'
require 'get_all_orders_command'
require 'reminder'
require 'place_order_guest'
require 'get_all_guests'

class RequestParser
  def initialize()
    @menu = Menu.new
    @apprentice_rota = ApprenticeRota.new({"id" => "Will", "id2" => "Fabien"})
    @commands = [SetMenuCommand.new(@menu), GetMenuCommand.new(@menu), Reminder.new, GetAllOrdersCommand.new, GetAllGuests.new, SetOrderCommand.new]
  end

  def parse(data)
    request = data[:user_message]

    for command in @commands
      if command.applies_to(request)
        if command.kind_of? Reminder or command.kind_of? SetOrderCommand
          command.prepare(data) 
        end
        return command
      end
    end

    if request.start_with?("order:") && request.split.size > 1
      GetOrderCommand.new(request)
    elsif request.start_with?("foreman")
      ForemanCommand.new(@apprentice_rota)
    elsif get_string_betwee_dash(request) && get_string_after_collon(request)
      PlaceOrderGuest.new(
        get_string_after_collon(request),
        get_string_betwee_dash(request),
        data[:user_id]
      )
    else
      ErrorCommand.new
    end
  end

  private

  def get_string_betwee_dash(message)
    message[/(?<=\-)(.+?)(?=\-)/]
  end

  def get_string_after_collon(message)
    message[/(?<=\:\s)(.+?)$/]
  end
end
