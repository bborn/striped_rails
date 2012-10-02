module StripedRails
  class CreditCardsController < BaseController
    def new
    end

    def create
      @user = current_user.model
      @user.attributes = params[:user]

      respond_to do |format|
        if @user.update_credit_card
          format.html { redirect_to profile_path, notice: 'Credit Card was successfully added.' }
          format.json { render json: @user, status: :created, location: @user }
        else
          format.html { render action: "new" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end