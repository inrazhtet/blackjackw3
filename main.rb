require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_VALUE = 21
DEALER_MIN = 17

helpers do
  def calculate_total(cards)
    arr = cards.map {|a| a[1]}
    total = 0
    arr.each do |a|
      #Calculate Total Value
      if a == "A"
        total +=11      
      else  
        a.to_i == 0 ? total +=10 : total += a.to_i
      end
    end

    arr.select{|a| a =="A"}.count.times do
        total -=10 if total > BLACKJACK_VALUE
    end
    total
  end

  def card_swap(card)
    suit = case card [0]
              when 'H' then 'hearts'
              when 'C' then 'clubs'
              when 'D' then 'diamonds'
              when 'S' then 'spades' 
           end
    value = card[1]
    if (['A','J','Q','K'].include? (value))
      value = case value
                when 'A' then 'ace'
                when 'J' then 'jack'
                when 'Q' then 'queen'
                when 'K' then 'king' 
              end
      end
  "<img src='/images/cards/#{suit}_#{value}.jpg' class='cards_cover'>"
  end
end

def win!(msg)
  session[:userMoney] = session[:userMoney].to_i + session[:userBet].to_i
  @success = "#{session[:userName]} wins! #{msg} Current capital holding is #{session[:userMoney]}."
end

def lose!(msg)
  session[:userMoney] = session[:userMoney].to_i - session[:userBet].to_i
  @error = "#{session[:userName]} loses! #{msg} Current capital holding is #{session[:userMoney]}."
end

def tie!(msg)
  session[:userMoney]
  @success = "#{session[:userName]} ties with Dealer! #{msg} Current capital holding is #{session[:userMoney]}."
end

before do
  @player_hit_or_stay = true
end

get '/' do
  redirect '/setname' 
end

get '/setname' do
  erb :setname

end

post '/setname' do
  if params[:userName].empty?
    @error = "You need to fill in your name!"
    halt erb(:setname)
  elsif params[:userMoney].empty?
    @error = "You need to show the total amount of money with you!"
    halt erb(:setname)
  end

  session[:userName] = params[:userName] 
  session[:userMoney] = params[:userMoney].to_i
  redirect '/game/bet'
end

get '/game/bet' do
  erb :bet
end

post '/game/bet' do
session[:userBet] = params[:userBet].to_i

  if(session[:userBet].to_i > session[:userMoney].to_i)
    @error = "Umm.. you don't have that much money!" 
    halt erb(:bet)
  else (session[:userMoney].to_i < 0)
    @error = "Sir, you ran out of money!"
    halt erb(:refill)
  end
  redirect '/game'
end

get '/game/refill' do
  erb :refill
end

post '/game/refill' do
  if params[:userMoney].empty?
    @error = "Please write in how much you want to borrow. Interest is at 5%!"
    halt erb(:setname)
  end
   session[:userMoney] = params[:userMoney]
   redirect 'game/bet' 
end


get '/game' do
session[:userBet] = params[:userBet].to_i

if(session[:userBet] > session[:userMoney])

  @error = "Umm.. you don't have that much money!" 
  halt erb(:bet)
else (session[:userMoney] < 0)
  @error = "Sir, you ran out of money!"
  redirect '/game/refill'
end
  #Noting whose turn it is
  session[:turn] = session[:userName]

  if session[:userMoney] < 0
    @error = "Sir, you have ran out of money"
    halt erb(:refill)
  end

  suits = ['H','C','D','S']
  values = ['2','3','4','5','6','7','8','9','10','A','J','Q','K']
  #initialize player and dealer cards
  session[:pcards] = []
  session[:dcards] = []

  #set up decks
  session[:decks] = suits.product(values).shuffle!
  #distribute cards
  2.times do
    session[:dcards] << session[:decks].pop
    session[:pcards] << session[:decks].pop
  end

  player_score = calculate_total(session[:pcards])



  if (player_score == BLACKJACK_VALUE)
    win!("BLACKJACK!")
    @player_hit_or_stay = false
  end

  erb :game
end

post '/game/player/hit' do
  session[:pcards] << session[:decks].pop
  player_score = calculate_total(session[:pcards])
  dealer_score = calculate_total(session[:dcards])

  if (player_score > BLACKJACK_VALUE)
    lose!("#{session[:userName]} has #{player_score}. Dealer has #{dealer_score}.")
    @player_hit_or_stay = false
  elsif (player_score == BLACKJACK_VALUE)
    win!("BLACKJACK!")
    @player_hit_or_stay = false
  else
    @player_hit_or_stay = true
  end
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:userName]} has chosen to stay!"
  redirect '/game/dealer'
end 

get '/game/dealer' do 
  session[:turn] = "dealer"
  @player_hit_or_stay = false
  dealer_score = calculate_total(session[:dcards])
  player_score = calculate_total(session[:pcards])

  if dealer_score > BLACKJACK_VALUE
    win!("Dealer score is #{dealer_score}. #{session[:userName]} has player_score.")
  elsif dealer_score == BLACKJACK_VALUE
    lose!("Dealer hit BLACKJACK!")
  elsif dealer_score >= DEALER_MIN
      redirect '/game/dealer/compare'
  else dealer_score < DEALER_MIN
      @dealer_hit = true
  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dcards] << session[:decks].pop  
  redirect '/game/dealer'
end

get '/game/dealer/compare' do
  player_score = calculate_total(session[:pcards])
  dealer_score = calculate_total(session[:dcards])

  if player_score > dealer_score
    win!("Player score is #{player_score} & Dealer has #{dealer_score}.")
  elsif player_score < dealer_score
    lose!("Player score is #{player_score} & Dealer has #{dealer_score}.")
  else 
    tie!("#{session[:userName]} score is #{player_score} & Dealer has #{dealer_score}.")
  end
  erb :game
end

get '/game/over' do
  erb :gameover
end


# abstract out repetitive methods
# have a start over (yes) or (no) feature
#have constants
# hide the first card


#Set your starting capital
#Save it in cookie
#Place your bet.
#If I lose, I subtract from it.
#If I win, I add to it.
#If I run out of money, 
#Go back to put in more money Or Exit

# get '/helloworld'  do
# 	"Hello World!!"
# end

# get '/ztemplate' do
#   erb :ztemplate
# end

# get '/nested_template' do
#   erb :"user/profile"
# end

# get '/nothere' do
#   redirect '/helloworld'
# end

# get '/form' do
#   erb :subform
# end

# post '/zaction' do
#   puts params['username']
# end