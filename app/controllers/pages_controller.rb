class PagesController < ApplicationController
  def index
  end

  def about
  end

  def pusher_auth
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id],{
      :user_id => rand(1..1000000),
      :user_info => {
        :name => 'blah'
      }
    })
    render :json => response
  end

end
