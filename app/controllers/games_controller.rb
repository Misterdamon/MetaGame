class GamesController < ApplicationController

  GAME_NOT_FOUND = "No Game Found"

  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
    @returned_game = GiantBombAdapter.new(@game.game_name).search.parsed_response["results"][0]["description"]
    
    render '/games/show'
  end

  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end

  def search
    #refactor for multiple game
    @game = Game.find(:all, :conditions => ['game_name LIKE ?', "%#{params['search']}%"]).first 
    redirect_to groups_path if @game == nil 
    if session[:group_id]
      @group = Group.find(session[:group_id])
      @group.games << @game
      redirect_to group_path(session[:group_id])
    else
      @user = User.find(session[:id])
      @user.games << @game
      redirect_to root_path
    end
  end
end

