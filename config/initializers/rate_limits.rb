# 🔐 ログイン・会員登録・パスワード再設定の総当たりを防ぐ（同じIPから3分に10回まで）
# Devise のコントローラーは自前の prepend_before_action でログイン処理を先に走らせるため、
# 回数制限はそれよりも前（prepend: true）に差し込む。開発時の再読み込みにも追従するよう to_prepare で設定する。
Rails.application.config.to_prepare do
  [ Devise::SessionsController, Devise::RegistrationsController, Devise::PasswordsController ].each do |controller|
    controller.rate_limit to: 10, within: 3.minutes, only: :create, prepend: true,
                          store: ApplicationController::RATE_LIMIT_STORE,
                          with: -> { redirect_to root_path, alert: "試行が多すぎまする。しばし時を置いてから、もう一度お試しくだされ。" }
  end
end
