class InvoiceDecorator
  def initialize(invoice)
    @invoice = invoice
  end

  def greeting
    if @invoice.attempted && @invoice.paid
      "Thank you for your payment!"
    elsif @invoice.attempted
      "Payment Over Due. Please update your credit card information as soon possible."
    else
      "Information Only. No action required."
    end
  end

  def starting_balance
    number_to_currency(@invoice.starting_balance)
  end

  def subscription_name
    @invoice.lines.subscriptions[0].plan.name
  end

  def subscription_amount
    number_to_currency(@invoice.lines.subscriptions[0].amount)
  end

  def additional_charges(format)
    if @invoice.lines.respond_to?(:invoiceitems)
      @invoice.lines.invoiceitems.each do |item|
        if format == :text
          "#{item.description}: #{number_to_currency(item.amount)}"
        else
          "<p><strong>#{item.description}:</strong> #{number_to_currency(item.amount)}</p>".html_safe
        end
      end
      number_to_currency(@invoice.lines.invoiceitems[0].amount)
    else
      if format == :text
        "Attional Charges: None"
      else
        "<p><strong>Additional Charges:</strong> None</p>".html_safe
      end
    end
  end

  def overage
    if @invoice.lines.respond_to?(:invoiceitems)
      number_to_currency(@invoice.lines.invoiceitems[0].amount)
    else
      "None"
    end
  end

  def subtotal
    number_to_currency(@invoice.subtotal)
  end

  def discount
    if @invoice.respond_to?(:discount)
      "#{@invoice.discount.coupon.id}: #{@invoice.discount.coupon.percent_off}%"
    else
      "None"
    end
  end

  def total
    number_to_currency(@invoice.total)
  end

  def starting_balance
    number_to_currency(@invoice.starting_balance)
  end

  def amount_due
    number_to_currency(@invoice.amount_due)
  end

  def number_to_currency(number)
    c = number.to_f / 100
    "$%.2f" % c
  end

  def method_missing(method, *args)
    if args.empty?
      @invoice.send(method)
    else
      @invoice.send(method, args)
    end
  end
end