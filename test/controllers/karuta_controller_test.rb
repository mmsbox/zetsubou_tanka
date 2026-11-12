require "test_helper"

class KarutaControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "札が足りないときは短歌を詠むよう案内する" do
    get karuta_url
    assert_response :success
    assert_match "まだ札にできる短歌が足りませぬ", response.body
  end

  test "札が揃っていればかるたの場を表示する" do
    phrases = %w[あかさたな いきしちにひみ うくすつぬ えけせてねへめ おこそとのほも]
    5.times do |i|
      Post.create!(error_message: "Error #{i}", tanka: phrases.map { |p| "#{p}#{i}" }.join(" "))
    end

    get karuta_url
    assert_response :success
    assert_select "[data-controller='karuta']"
    assert_select "[data-action='karuta#start']", 3
  end

  test "ログイン中は戦績と保存先URLを表示する" do
    phrases = %w[あかさたな いきしちにひみ うくすつぬ えけせてねへめ おこそとのほも]
    5.times { |i| Post.create!(error_message: "Error #{i}", tanka: phrases.map { |p| "#{p}#{i}" }.join(" ")) }
    sign_in users(:one)

    get karuta_url
    assert_response :success
    assert_match "あなたの戦績：0戦", response.body
    assert_select "[data-karuta-save-url-value='#{karuta_results_path}']"
  end
end
