class HomeController < ApplicationController

  def index
  end
  
  def find
    public_url = params[:address].empty? ? "http://www.imdb.com/user/ur27065058/ratings" : params[:address]
    doc = Nokogiri::HTML(open(public_url))
    ids = find_ids_by_type(doc)
    @titles = []
    ids.each do |title_id|
      @titles << Imdb::Movie.new(title_id)
    end
    
  end
  
  def find_ids_by_type(doc)
    arr = []
    list_items = doc.css("div .list_item").first(50).each do |item|
      a = item.css("div.info").css("div.episode")
      if a.empty? # movie
        to_parse = item.css("div.image").css("a").first
        title_id = to_parse["href"].split("tt")[1].split("/")[0]
        arr << title_id
        return arr if arr.size == 5
      end
    end
    arr
  end
  
end
