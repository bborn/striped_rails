module StripedRails
  class WebhooksController < BaseController
    skip_before_filter :require_login

    def create
      @processor = WebhookProcessor.new
      @processor.process(request.body.read)

      head :ok
    end
  end
end