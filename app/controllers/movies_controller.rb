class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      
      # Setting @all_ratings to be an enumerable collection of all possible values of a movie rating (based on values provided in the DB).
      @all_ratings = Movie.select(:rating).map(&:rating).uniq
      
      if params[:sort]  # Update session[:sort]
        session[:sort] = params[:sort]
      end
        
      if params[:ratings] # Update session[:ratings]
        session[:ratings] = params[:ratings]
      end
      
      session[:ratings] ||= @all_ratings
      @ratings = session[:ratings] # Setting the parameters for ratings.
      @ratings = @ratings.keys if @ratings.respond_to?(:keys) # Display the ratings selected by the user.
        
      @sorting_on_a_column = session[:sort]
        
      # If incoming URI is lacking the right params.
      if session[:sort] != params[:sort] || session[:ratings] != params[:ratings]
        flash.keep
        redirect_to movies_path(sort: session[:sort], ratings: session[:ratings])
      end
        
      @movies = Movie.where("rating IN (?)", @ratings).order(session[:sort])
      
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end