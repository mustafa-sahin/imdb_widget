class HomeController < ApplicationController

  def index
  end
  
  def find
    public_url = params[:address].empty? ? "http://www.imdb.com/user/ur27065058/ratings" : params[:address]   
    doc = Nokogiri::HTML(open(public_url))
    @user_href = "http://www.imb.com" << doc.css("div#main").css("div.article").css("h3").css("a").first["href"]
    @user_name = doc.css("div#main").css("div.article").css("h3").css("a").first.text
    ids = find_ids_and_features(doc) # ids = [[title_id1, director_url1], [title_id2, director_url2], ...]
    @movies = {}
    i = 0
    ids.each do |tt|
      movie = Imdb::Movie.new(tt[0])
      star1_url = "http://www.imdb.com/"<< movie.cast_member_ids[0]
      star2_url = "http://www.imdb.com/"<< movie.cast_member_ids[1]
      star3_url = "http://www.imdb.com/"<< movie.cast_member_ids[2]
      movie_url = "http://www.imdb.com/tt" << tt[0]
      @movies[i] = {:id => movie.id, :url => movie_url, :title => movie.title, :poster => movie.poster, :plot => movie.plot,
                    :rating => movie.rating, :year => movie.year, :length => movie.length, :director => movie.director[0],
                    :director_url => tt[1], :star1 => movie.cast_members[0], :star2 => movie.cast_members[1],
                    :star3 => movie.cast_members[2], :star1_url => star1_url, :star2_url => star2_url, :star3_url => star3_url}
      i += 1
    end
  end
  
  def find_ids_and_features(doc)
    ids = []
    list_items = doc.css("div .list_item").each do |item|
      check_if_episode = item.css("div.info").css("div.episode")
      if check_if_episode.empty? # movie
        parse_title_id = item.css("div.image").css("a").first
        title_id = parse_title_id["href"].split("tt")[1].split("/")[0]
        parse_director_url = item.css("div.info").css("div.secondary").first
        if parse_director_url.text.include? "Director" # some items don't show director info on IMDb rating list, pass them.
          director_url = "http://www.imdb.com" << parse_director_url.css("a").first["href"]
          parse_stars_urls = item.css("div.info").css("div.secondary")[1]
          if parse_stars_urls.text.include? "Star" # some items don't show star info, so pass them, too.
            ids << [title_id, director_url]
          end
        end
        return ids if ids.size == 5 # just fetching first five movies for widget
      end
    end
    ids
  end
  
end
