require 'sinatra'
require_relative 'my_user_model'

set :bind, '0.0.0.0'
set :port, 8080
set :session, Hash.new
set :user, User.new

enable :sessions



    get /\/users|\// do
      @all_users = settings.user.all
      erb :index
    end

    post '/users' do
      if (settings.user.create(params[:firstname], params[:lastname], params[:age], params[:email], params[:password]) == nil)
        return  "This email is already taken"
      end
    end

    post '/sign_in' do
      email = Rack::Auth::Basic::Request.new(request.env)
      if (email.provided?)
        user_data = settings.user.sign_in(email.username)
        if (user_data)
          protected!(user_data)
          session[:logged_user] = user_data['Id']
         return "You have succesfully signed in!"
       end
      end
      return "No user with this email"
    end

    put '/users' do
      user = session[:logged_user]
      if user && params[:password]
          settings.user.update(user, 'password', params[:password])
          return settings.user.get(user).to_s
      end
    end

    delete '/sign_out' do
      if session[:logged_user]
        session.delete(:logged_user)
        return "You have successfully logged out!"
      end
      return "Please log in first"
    end

    delete '/users' do
      user = session[:logged_user]
      if user
        session.delete(:logged_user)
        settings.user.destroy(user)
        return "User has been succesfully deleted!"
      end
      return "Please log in first"
    end