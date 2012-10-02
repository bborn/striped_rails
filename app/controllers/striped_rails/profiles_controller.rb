module StripedRails
  class ProfilesController < BaseController
    def show
    end

    def edit
    end

    def update
      respond_to do |format|
        if current_user.update_attributes(params[:user])
          format.html { redirect_to profile_path, notice: 'Profile was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: current_user.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end