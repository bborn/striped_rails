$ ->
  if $('meta[name="stripe-key"]').length
    window.subscription_manager = new window.SubscriptionManager