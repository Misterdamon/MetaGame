class EventsController < ApplicationController
 
  def index
    @user = current_user if current_user
    @events = Event.all
    u_events = UserEvent.where(user_id: current_user.id) if current_user
    @user_events = []
    if current_user
      u_events.each do |event|
        result = Event.find(event.event_id)
        @user_events << result if result
      end
    end
    if @user_events
      @user_events.sort! { |date1, date2| date1.event_date <=> date2.event_date }
    end
  end

  def show
    @event = Event.find params[:id]
    @tourney = @event.tournaments.first unless @event.tournaments.empty?
    @game = Game.find_by_game_name(@event.event_game_title)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new params[:event]
    @group = Group.find session[:group_id] if session[:group_id]

    if @event.save
      @event.update_attributes(user_id: current_user.id)
      Event.assign_assoc_to_event @event, @group, current_user
      flash[:notice] = 'Event has successfully been created!'
      if @event.event_type == "Tournament"
        redirect_to new_event_tournament_path @event
      else
        redirect_to event_path @event
      end
    else
      flash[:error] = 'Something went wrong!'
      render 'events/new'
    end
  end

  def edit
    @event = Event.find params[:id]
  end

  def update
    @event = Event.find params[:id]

    if @event.update_attributes params[:event]
      if @event.event_type == Event.check_type(@event.event_type)
        redirect_to new_event_tournament_path @event
      else
        flash[:notice] = 'Event has successfully been updated!'
        redirect_to event_path @event
      end
    else
      flash[:error] = 'Something went wrong!'
      render 'events/edit'
    end
  end

  def search
    #refactor for multiple event
    @event = Event.find(:all, :conditions => ['event_name LIKE ?', "%#{params['search']}%"]).first
    if @event == nil 
      redirect_to events_path
    end
    if session[:group_id]
      @group = Group.find session[:group_id]
      @group.events << @event
      redirect_to group_path session[:group_id]
    else
      @user = User.find session[:id]
      @user.events << @event if @user
      redirect_to root_path
    end
  end

  def add_user_event
    event = Event.find params[:id]
    Event.assign_user_to_event event, current_user
    redirect_to root_path
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to events_path
  end


end
