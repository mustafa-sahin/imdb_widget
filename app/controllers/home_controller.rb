class HomeController < ApplicationController

  def index
  end
  
  def find
    public_url = params[:address].empty? ? "http://www.imdb.com/user/ur27065058/ratings" : params[:address]
    
    @doc = Nokogiri::HTML(open(public_url))
    @anchors = @doc.css("div .image").css("a").first(5)
    @ttIds = []
    
    @anchors.each do |a|
      @ttIds << a["href"].split("tt")[1].split("/")[0]
    end
    
  end
end
