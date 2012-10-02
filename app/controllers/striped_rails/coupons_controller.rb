module StripedRails
  class CouponsController < BaseController
    before_filter :require_admin
    
    def index
      @coupons = CouponDecorator.all

      respond_to do |format|
        format.html
        format.json { render json: @coupons }
      end
    end

    def edit
      @coupon = Coupon.find(params[:id])
    end

    def update
      @coupon = Coupon.find(params[:id])

      respond_to do |format|
        if @coupon.update_attributes(params[:coupon])
          format.html { redirect_to coupons_path, notice: 'Coupon was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @coupon.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end