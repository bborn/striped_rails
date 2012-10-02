window.SubscriptionManager = class SubscriptionManager
  constructor: ->
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
    @setupForm()
    
  setupForm: ->
    $('#subscribe').submit =>
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        @processCard()
        false
      else
        true
  
  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, @handleStripeResponse)
  
  handleStripeResponse: (status, response) ->
    if status == 200
      $('#user_card_token').val(response.id)
      $('#subscribe')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('input[type=submit]').attr('disabled', false)