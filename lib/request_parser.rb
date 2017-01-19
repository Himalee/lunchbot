class RequestParser
  def parse(request)
    if menu_request?(request)
      "menu"
    elsif request == "menu?"
      "get_menu"
    elsif set_order_request?(request)
      "set_order"
    else
      "error"
    end
  end

  private

  def menu_request?(request)
    request.split.size == 3 &&
    request.include?("new menu") &&
    contain_url?(request)
  end

  def contain_url?(request)
    request[/((http|https):\/\/)?(w{3}.)?[A-Za-z0-9-]+.(com|co.uk)/]
  end

  def set_order_request?(request)
    request.start_with?("order me: ") && request.split.size > 2
  end
end
