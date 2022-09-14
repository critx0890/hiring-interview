module TransactionsHelper
  def error_message_for(transaction, field_name)
    transaction.errors.full_messages_for(field_name).map do |message|
      content_tag(:div, message, class: "error")
    end.join("").html_safe
  end
end
