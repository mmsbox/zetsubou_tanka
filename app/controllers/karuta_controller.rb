class KarutaController < ApplicationController
  def show
    deck = Post.karuta_deck
    @deck_size = deck.size
    @cards = deck.size >= Post::KARUTA_MIN_CARDS ? deck.sample(Post::KARUTA_ROUND_SIZE) : []
    @karuta_stats = current_user.karuta_results.stats if user_signed_in?
  end
end
