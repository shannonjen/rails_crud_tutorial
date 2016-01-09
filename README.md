# Simple Steps Rails
The steps outlined below build a simple Rails CRUD (create, read, update, and delete) application for an album resource. Each album will have a title and an artist. 

1. At the command prompt (terminal), create a new Rails application:

	```bash
	$ rails new album_collection_app
	```
	where "album_collection_app" is the application name.

2. Change directory to `album_collection_app`.

	```bash
	$ cd album_collection_app
	```

3. Let's start by defining a root route for this application. The root route tells Rails what to do with a get request to "/". Routes are defined in the routes.rb file in the config folder. We would like our home page to list all of the albums. This is the job of an index action. Our root route will point to the index action of the AlbumsController.

	```ruby
	#config/routes.rb
	Rails.application.routes.draw do
  	root 'artists#index'
	end
	```

4. The root route above specifies a controller that we have not yet added to our application. A controller is in charge of interacting with the model and rendering a view. Let's use the command line to generate the AlbumsController.

	```bash
	$ rails g controller albums 
	```

5. Next we need to add the index action (a method) to the generated AlbumsController. The AlbumsController is a class located in the newly created albums_controller.rb in the controllers folder.  

	```ruby
	#app/controllers/albums_controller.rb
	class AlbumsController < ApplicationController
		def index
		end
	end

	```

6. Left empty, the index action of the AlbumsController will try and locate and render an index template inside of a folder called albums within the views folder. In other words, we need to add an index.html.erb file to app/views/albums. 

	```html
	<!--app/views/albums/index.html.erb--> 
	<h1>Your Album Collection</h1>
	```

7. We would like our index page to list out all of the albums in a users' collection. We need a database with an albums table and an Album model to interact with the database. The model generator will generate the model (Album class) as well as a migration that will create the table (albums) with fields (title and artist) for the model. 

	```bash
	$ rails g model Album title:string artist:string
	``` 

8. Now we need to run the migration with a rake task to create the table.

	```bash
	$ rake db:migrate
	```
	This will also generate a schema file inside of the db folder of the application. The schema represents the current state of the database. 

9. Now that we have a model and homepage, let's add a resource route for albums. The resource route defines the routes to the seven restful actions in the AlbumsController:

	*index
	*show
	*new
	*create
	*edit
	*update
	*destroy 

	We specify the routes for our app in the routes.rb file inside of the config folder. Let's add the albums resource route to config/routes.rb:

	```ruby
	#config/routes.rb
	Rails.application.routes.draw do
  	root 'artists#index'
  	resources :albums
	end
	```

11. Let's add a link to create a new album to the home page. We would like the link to lead the user to a page with a form for adding a new album with a specified title and artist to their collection. The link_to method in Rails will generate an anchor tag. We pass in two arguments. The first is the text rendered on the page "New Album" and the second is a helper method (new_album) that will generate the anchor tag's href = "/albums/new". When clicked, this anchor tag will make an HTTP GET request to the "/albums/new" URL. Since we have defined a resource route for albums in our routes.rb file, this specific request route will point to the new action of the AlbumsController. Add the link to index.html.erb
 
	```erb
	<!--app/views/albums/index.html.erb--> 
	<%= link_to "New Album" new_album_path %>
	```

12. Now we need to define the new action of the AlbumsController. This action will point to a view called new that contains a form for adding a new album. We create a new album (an instance of the Album model) to base the form off of. 

	```ruby
	#app/controllers/albums_controller.rb
	class AlbumsController < ApplicationController
	
		def index
		end

		def new
			@album = Album.new
		end

	end   
	```

13. Next we add the new.html.erb view to the views/albums folder. This will contain the form that lets a user input and submit a new album. We will use a Rails helper method called form_for to generate the form. form_for will take an Active Record object as an argument and generate a form specific to that object. Upon receiving a new Album object, form_for will set the action ("/albums") and method ("POST")attributes for the form it builds. This route points to the create action in AlbumsController.

	```erb
	<!-- views/albums/new.html.erb -->
	<h1>New Album</h1>
	<%= form_for(@album) do |f| %>
		<%=f.label :title %>
		<%=f.text_field :title %>
		<%=f.label :artist %>
		<%=f.text_field :artist %>
		<%=f.submit %>
	<% end %>
	```

14. When the user presses the submit button, the params will be sent to the create action in AlbumsController. The create action will create a new Album with the params. Rails will not let you pass in the params directly. This is because of a security feature called strong parameters. Strong parameters ensure that only specified params are submitted. Warning: we have not talked about this approach to strong parameters. We will next week. We can add a method called albums_params to our AlbumsController that specifies the expected params. We pass this method in place of the actual params. 

	```ruby
	#app/controllers/albums_controller.rb
	class AlbumsController < ApplicationController
		def index
		end

		def new
			@album = Album.new
		end

		def create
			@album = Album.new(album_params)

			if @album.save
				redirect_to @album
			else

			end
		end

		private

		def album_params
			params.require(:album).permit(:title, :artist)
		end
	end
	```
15. READ index and show: We would like to have the home page of our app list out all of the Albums and we would like each album to link to a unique page for that particular album. 

	We can query the albums for all of the records in the albums table and return all of the records as an array-like collection of Active Record objects in our index controller. We set this to an instance variable @albums for use in our index view. In the index view, we can use a .each method on @albums to cycle through the albums and list their titles. We can render each title as text for a link to a unique album page.

	Let's modify the index action and create the show action in the AlbumsController. 

	```ruby
	#app/controllers/albums_controller.rb
	class AlbumsController < ApplicationController
		def index
			@albums = Album.all
		end

		def show
			@album = Album.find(params[:id])
		end

		def new
			@album = Album.new
		end

		def create
			@album = Album.new(album_params)

			if @album.save
				redirect_to @album
			else

			end
		end

		private

		def album_params
			params.require(:album).permit(:title, :artist)
		end
	end

	``` 
16. Let's modify the index view

	```html
	<!-- app/views/albums/index.html.erb -->
	<h1>All Albums</h1>

	<%= link_to "New Album", new_album_path %>

	<% @albums.each do |album| %>
		<h2><%= link_to album.name, album %></h2>
	<% end %>
	```
17. The show view will list the album title and artist for the specified album. This page will also include a link to a page with a form to edit the specified album and a link to delete the album. Let's create the show view with these two links.

	```html
	<!-- app/views/albums/show.html.erb -->
	<h1><%= @album.title %></h1>
	<h2>Artist: <%= @album.artist %> </h2>

	<%= link_to "Edit Album", edit_album_path(@album) %>
	<%= link_to "Delete Album", album_path(@album), method: :delete %>
	```

19. We need to define the edit and update actions in the AlbumsController. The edit will set an instance variable @album of a specified album and point to the edit view, a view that will contain a form to edit a specified album (we will add the edit view in the next step). The update action will actually update the record and redirect to the newly updated album page.

	```ruby
	class AlbumsController < ApplicationController
		def index
			@albums = Album.all
		end

		def show
			@album = Album.find(params[:id])
		end

		def new
			@album = Album.new
		end

		def create
			@album = Album.new(album_params)

			if @album.save
				redirect_to @album
			else

			end
		end

		def edit
			@album = Album.find(params[:id])
		end

		def update
			@album = Album.find(params[:id])
			@album.update(album_params)
			redirect_to @album
		end

		private

		def album_params
			params.require(:album).permit(:title, :artist)
		end
	end
	```

20. Add the edit view with a form for updating an album. This form_for is identical to one in the new view. However, Rails checks to see if @album has been persisted to the table. If so, it will render the appropriate route to lead to an update action (as opposed to a new action for a newly created @album).

	```html
	<!-- app/views/albums/edit.html.erb -->
	<h1>Edit Album</h1>
	<%= form_for(@album) do |f| %>
		<%=f.label :title %>
		<%=f.text_field :title %>
		<%=f.label :artist %>
		<%=f.text_field :artist %>
		<%=f.submit %>
	<% end %>
	``` 
21. Add the destroy action to the AlbumsController. This will look up the album, destroy it, and then redirect to the index.

	```ruby
	#app/controllers/album_controller.rb
	class AlbumsController < ApplicationController
		def index
			@albums = Album.all
		end

		def show
			@album = Album.find(params[:id])
		end

		def new
			@album = Album.new
		end

		def create
			@album = Album.new(album_params)

			if @album.save
				redirect_to @album
			else

			end
		end

		def edit
			@album = Album.find(params[:id])
		end

		def update
			@album = Album.find(params[:id])
			@album.update(album_params)
			redirect_to @album
		end

		def destroy
			@album = Album.find(params[:id])
			@album.destroy
			redirect_to albums_path
		end

		private

		def album_params
			params.require(:album).permit(:title, :artist)
		end
	end
	```










