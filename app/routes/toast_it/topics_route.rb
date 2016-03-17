module Sinatra
  module Web
    module Routing
      module TopicsRoute
        def self.registered(app)

          ['/toast-it', '/toast-it/topics', '/toast-it/top'].each do |path|
            app.get path do
              @user = current_user if logged_in?
              @topics = Topic.top_topics
              haml :'toast/index'
            end
          end

          app.get '/toast-it/new' do
            @user = current_user if logged_in?
            @topics = Topic.new_topics
            haml :'toast/index'
          end

          app.get '/toast-it/topics/new' do
            if logged_in?
              haml :'toast/topics/new'
            else
              session[:redir] = request.path_info
              redirect '/login'
            end
          end

          app.post '/toast-it/topics' do
            if logged_in?
              topic = Topic.new(params)
              if topic.save
                current_user.topics << topic
                redirect "/toast-it/topics/#{topic.id}"
              else
                "error"
              end
            else
              session[:redir] = request.path_info
              redirect '/login'
            end
          end

          app.get '/toast-it/topics/:id' do
            @topic = Topic.find_by_id(params[:id])
            if @topic
              if logged_in?
                # binding.pry
                @user = current_user
                @liked = @topic.liked?(@user)
              end
              haml :'toast/topics/show'
            else
              "Requested topic not found"
            end
          end

          app.post '/toast-it/topics/:id' do
            if logged_in?
              comment = Comment.new(params[:comment])
              if comment.save && topic = Topic.find_by_id(params[:id])
                current_user.comments << comment
                topic.comments << comment
                redirect "/toast-it/topics/#{topic.id}"
              else
                "error"
              end
            else
              session[:redir] = request.path_info
              redirect '/login'
            end
          end

          app.get '/toast-it/topics/:id/edit' do
            if logged_in?
              @topic = Topic.find_by_id(params[:id])
              user = current_user
              if @topic && @topic.user == user
                # binding.pry
                @liked = @topic.liked?(user)
                haml :'toast/topics/edit'
              end
            else
              "Requested topic not found"
            end
          end

          app.put '/toast-it/topics/:id/edit' do
            if logged_in?
              topic = Topic.find_by_id(params[:id])
              if topic.user == current_user && topic.update(params[:topic])
                redirect "/toast-it/topics/#{topic.id}"
              else
                "error"
              end
            else
              session[:redir] = request.path_info
              redirect '/login'
            end
          end

        end
      end
    end
  end
end
