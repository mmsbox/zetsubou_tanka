require "test_helper"

class KarutaResultsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def valid_params
    { karuta_result: { level: "kami", player_score: 5, cpu_score: 4, otetsuki: 1, card_count: 8 } }
  end

  test "ログイン中は戦績を記録して称号を返す" do
    sign_in users(:one)

    assert_difference -> { users(:one).karuta_results.count }, 1 do
      post karuta_results_url, params: valid_params, as: :json
    end
    assert_response :created
    assert_equal "神をも退けし名人", response.parsed_body.dig("rank", "title")
  end

  test "点数が不正なら記録しない" do
    sign_in users(:one)
    params = valid_params.deep_merge(karuta_result: { player_score: 8 })

    assert_no_difference -> { KarutaResult.count } do
      post karuta_results_url, params: params, as: :json
    end
    assert_response :unprocessable_content
  end

  test "未ログインでは記録できない" do
    assert_no_difference -> { KarutaResult.count } do
      post karuta_results_url, params: valid_params, as: :json
    end
    assert_response :unauthorized
  end
end
