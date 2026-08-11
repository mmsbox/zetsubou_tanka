class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @posts = current_user.posts.order(created_at: :desc)
  end
end
