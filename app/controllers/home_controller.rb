class HomeController < ApplicationController
before_filter :get_xero_client
 
	def show
	@session[:xero_auth]
	end
	
	def index
  	end


        def new
            request_token = @xero_client.request_token(:oauth_callback => 'http://localhost:3000/create')
            session[:request_token] = request_token.token
            session[:request_secret] = request_token.secret

            redirect_to request_token.authorize_url
        end

        def create
            @xero_client.authorize_from_request(
                    session[:request_token], 
                    session[:request_secret], 
                    :oauth_verifier => params[:oauth_verifier] )

            session[:xero_auth] = {
                    :access_token => @xero_client.access_token.token,
		    :access_secret =>@xero_client.access_token.secret,
	            :verifier => params[:oauth_verifier]
                    }
                 
            session.delete(:request_token)
            session.delete(:request_secret)
            contacts = @xero_client.Contact.all
            flash[:success] = "Welcome to Xero"
        end

        def destroy
            session.delete(:xero_auth)
        end

    private

        def get_xero_client
            @xero_client = Xeroizer::PublicApplication.new("IE9B67H9YAK5UPHLHRJAI9TXY2N5HK", "2PKLGZHVTECFHM3SL817MSJ8N9FO3R")

            # Add AccessToken if authorised previously.
            if session[:xero_auth]
                @xero_client.authorize_from_access(
                    session[:xero_auth][:access_token],
                    session[:xero_auth][:access_key]
                    )
            end
        end
  
end
