class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def current_user
		if session[:id]
			User.find(session[:id])
		else
			false
		end
	end

	def current_steam_user
		session[:current_user]
	end
end
