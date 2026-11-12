class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :reject_password_reset, if: -> { devise_controller? && controller_name == "passwords" && !password_reset_available? }

  helper_method :password_reset_available?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # 📮 パスワード再設定メールを送れる環境か（本番はメール送信の設定がある場合のみ）
  def password_reset_available?
    Rails.configuration.x.password_reset_available
  end

  # メールが送れないのに「送信しました」と表示しないよう、再設定ページ自体を閉じる
  def reject_password_reset
    redirect_to new_user_session_path, alert: "パスワードの再設定は現在受け付けておりませぬ。"
  end
end
