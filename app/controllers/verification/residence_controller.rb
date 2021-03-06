class Verification::ResidenceController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_attemps_left!, only: [:new, :create]
  skip_authorization_check

  def new
    @residence = Residence.new
  end

  def create
    @residence = Residence.new(residence_params.merge(user: current_user))
    if @residence.save
      redirect_to verified_user_path, notice: t('verification.residence.create.flash.success')
    else
      current_user.update(residence_verification_tries: current_user.residence_verification_tries += 1)
      render :new
    end
  end

  private

    def residence_params
      params.require(:residence).permit(:document_number, :document_type, :date_of_birth, :postal_code)
    end

    def verify_attemps_left!
      if current_user.residence_verification_tries >= 5
        redirect_to account_path, alert: t('verification.residence.alert.verify_attemps_left')
      end
    end
end