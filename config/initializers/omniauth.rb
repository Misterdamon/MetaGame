# Intializes OmniAuth with API key



Rails.application.config.middleware.use OmniAuth::Builder do
	provider :steam, ENV['STEAM_WEB_API_KEY']
end

