class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    session_mem = false
    @all_ratings = Movie.uniq.pluck(:rating).sort
    @is_active_title = params[:id] == "title_header" ? "hilite" : ""
    @is_active_date = params[:id] == "release_date" ? "hilite" : ""

    if params[:ratings].blank? && !session[:ratings].blank?
        params[:ratings] = session[:ratings]
        session_mem = true
    end
    session[:ratings] = params[:ratings]

    if params[:id].blank? && !session[:id].blank?
        params[:id] = session[:id]
        session_mem = true
    end
    session[:id] = params[:id]
    
    if session_mem
      flash.keep
      redirect_to movies_path(:id => params[:id], :ratings => params[:ratings])
    end
    
    order_by = params[:id] == "title_header" ? "title" : params[:id] == "release_date" ? "release_date" : "" 
    @rating_checked = Hash.new(true)
    @check_box_checked = Hash.new()
    
    if !params[:ratings].blank?
      find_by = params[:ratings].keys.reject {|rating| !@all_ratings.include?(rating)}
      @all_ratings.each do |rating|
        @check_box_checked[rating] = 1
        unless params[:ratings].has_key?(rating)
          @rating_checked[rating] = false
          @check_box_checked.delete(rating)
          end
        end
      @movies = Movie.where(rating: find_by).order(order_by)
      else
      @movies = Movie.order(order_by)
      end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
