class KarutaResultsController < ApplicationController
  before_action :authenticate_user!

  # 🎴 かるた1局の戦績を記録（終局時に Stimulus から JSON で送信される）
  def create
    result = current_user.karuta_results.build(result_params)

    if result.save
      rank = current_user.karuta_rank
      render json: { rank: rank&.slice(:icon, :title) }, status: :created
    else
      render json: { errors: result.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def result_params
    params.require(:karuta_result).permit(:level, :player_score, :cpu_score, :otetsuki, :card_count)
  end
end
