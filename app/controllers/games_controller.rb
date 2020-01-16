require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @userinput = params[:input]
    @grid = params[:grid]
    session[:score] = session[:score] || 0

    if included?(@userinput.upcase, @grid)
      if english_word?(@userinput)
        @output = "Congratulations! #{@userinput.upcase} is a valid English word!"
        session[:score] += compute_score(@userinput)

      else
        @output = "Sorry but #{@userinput.upcase} does not seem to be a valid English word!"
      end
    else
      @output = "Sorry but #{@userinput.upcase} cannot be built out of #{@grid}"
    end
    @score = session[:score]
    # The word cant be built out of the original grid
    # The word is valid according to the grid, but is not a valid English word
    # The word is valid according to the grid and is an English word
  end

  def reset_session
    session[:score] = 0
    redirect_to new_path
  end

  private

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt)
    attempt.size * 2.0
  end
end
