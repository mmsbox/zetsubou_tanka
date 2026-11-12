require "test_helper"

class KarutaControllerTest < ActionDispatch::IntegrationTest
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
end
