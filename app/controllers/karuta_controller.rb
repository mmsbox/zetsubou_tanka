class KarutaController < ApplicationController
  # 1局で場に並べる札の枚数
  ROUND_SIZE = 8
  # これ未満の歌しかない場合はかるたを開催しない
  MIN_CARDS = 4

  def show
    deck = Post.karuta_deck
    @deck_size = deck.size
    @cards = deck.size >= MIN_CARDS ? deck.sample(ROUND_SIZE) : []
  end
end
