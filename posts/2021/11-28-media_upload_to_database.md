==title==
How to upload multimedia files to and display them from your database in a Phoenix project

==author==
Cornelia Kelinske

==description==
When I decided to store multimedia uploads for a small personal Phoenix project directly in my database and to display them from there, I found only scattered information on how to achieve this online. This post provides a comprehensive guide, all in one place. 


==tags==
coding

==body==

# 1. Project background


I am currently working on a personal project that revolves around a Phoenix video/image-sharing app.
Nothing crazy, nothing new. There are a lot of similar projects out there and I had, at least for the most part, no
problems finding reference material and resources to answer my questions along the way.
There were, however, two major sticking points: media file upload and media file display.


# 2. The sticking points


Unlike the projects that I used as reference for my own, I neither wanted to share videos or images via hyperlink in my .eex template nor did I want to use a third-party cloud storage provider, such as Amazon. My thought was: why not treat users' multimedia files just like all other user data? Why not store them directly in the database and then retrieve and display them from there in my .(h)eex templates?

I was able to find bits and pieces of information on how to achieve this scattered across various threads and blog posts, but there was no comprehensive guide addressing both steps: 1. uploading multimedia files from a web app into the database and 2. displaying those files via the .(h)eex templates.

While step 1 was relatively easy, it took me a while to figure out the right format for the image and video display in my .eex template, and then, after I switched over to Phoenix 1.6, to find a way to do the same in my .heex template. 

Since I believe that storing multimedia files directly in the database is a good solution for small-scale projects, I would like to save those who attempt to do the same thing some time. Please find below the comprehensive guide I wish I had had.


# 3. Prerequisites


Before we get down to the nitty-gritty, let's make sure we are on the same page. I am assuming that you have set up your Phoenix project including your repo and your uploads and user schemas.  
For reference, my project has an accounts context for my user schema and a content context for my upload schema. Accordingly, my `/lib/my_project folder` has the following structure:

```
├── lib
│   ├── my_project
│   │   ├── accounts
│   │   │   ├── profile.ex
│   │   │   └── user.ex
│   │   ├── accounts.ex
│   │   ├── application.ex
│   │   ├── content
│   │   │   └── upload.ex
│   │   ├── content.ex
│   │   └── repo.ex
│   ├── my_project.ex

```
And then I have the usual suspects: controllers, views, templates in the `/lib/my_project_web` folder.


# 4. Upload schema

The first step was to define my uploads schema in my `upload.ex` file. What's notable in this regard is that I am storing the  image/video file as binary data.

I also added module attributes specifying valid image types and valid video types as well as a combination of both. In order to be able to use the valid image and video types in my templates, I created corresponding functions returning the valid file types.
I am using my `changeset/2` function to verify that the file type of the file the user wants to upload is included in the valid file types.

```
defmodule MyProject.Content.Upload do
  
  use Ecto.Schema
  import Ecto.Changeset
  
  @valid_image_types ["image/jpeg", "image/jpg", "image/png"]
  @valid_video_types ["video/mp4", "video/quicktime"]
  @valid_file_types @valid_image_types ++ @valid_video_types

  def valid_image_types, do: @valid_image_types
  def valid_video_types, do: @valid_video_types
  def valid_file_types, do: @valid_file_types

  schema "uploads" do
    field :description, :string
    field :file, :binary
    field :file_type, :string
    field :title, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:file, :file_type, :title, :description])
    |> validate_required([:file, :file_type, :title, :description],
      message: "This box must not be empty!"
    )
    |> validate_inclusion(:file_type, @valid_file_types, message: "Wrong file type!")
  end
end
```
And just to be extra thorough: my `content.ex` file includes a `create_upload/1` function, which I will not elaborate on, since it is one of the functions that the Phoenix generator generates by default.


# 5. Upload controller

The upload controller was where things started to get interesting:

```
defmodule MyProjectWeb.UploadController do
  use MyProjectWeb, :controller
  
  alias MyProject.Content
  alias MyProject.Content.Upload  

  [...]

  def create(conn, %{"upload" => upload}) do
    user = conn.assigns.current_user

    with {:ok, params, _path} <- parse_upload_params(upload),
         {:ok, upload} <- Content.create_upload(user, params) do
      conn
      |> put_flash(:info, "File uploaded successfully.")
      |> redirect(to: Routes.upload_path(conn, :show, upload))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Oops, something went wrong!")
        |> render("new.html", changeset: changeset)

      {:error, :file_not_uploaded} ->
        conn
        |> put_flash(:error, "Please select a file!")
        |> redirect(to: Routes.upload_path(conn, :new))

      {:error, :cannot_read_file} ->
        conn
        |> put_flash(:error, "Cannot read file!")
        |> redirect(to: Routes.upload_path(conn, :new))
      
    end
  end

  defp parse_upload_params(upload) do
    with %{
           "title" => title,
           "description" => description,
           "upload" => %Plug.Upload{path: path, content_type: content_type}
         } <- upload,
         {:ok, binary} <- File.read(path) do
      {:ok,
       %{
         "file" => binary,
         "title" => title,
         "description" => description,
         "file_type" => content_type
       }, path}
    else
      map when is_map(map) -> {:error, :file_not_uploaded}
      {:error, _} -> {:error, :cannot_read_file}
    end
  end

end

```

Let's look at the upload. Our initial upload in the `create/2` function is what the user inputs into the "new upload" form under `/uploads/new` and what is subsequently sent through the form to the upload controller. It looks like this:

```
%{
"description" => "Some description",
"title" => "Some title",
"upload" => %Plug.Upload{
content_type: "image/jpeg",
filename: "IMG_5560.jpg",
path: "/tmp/plug-1639/multipart-1639441487-618453998432105-6"
}
```

What is most important in this map is our "upload" key-value pair. As we can see above, thanks to `Plug`, the data from the user's file input is represented in a `Plug.Upload` struct. In short, `Plug.Upload` stores the uploaded files in a temporary directory while the process requesting the files is alive. Afterwards, the files are deleted from said directory (see the [hexdocs](https://hexdocs.pm/plug/Plug.Upload.html) for more information on `Plug.Upload`).

In order not to blow my `create/2` function entirely out of proportion and to separate my concerns, I have moved the logic for processing my upload into the private `parse_upload_params/1` function. There, I pattern match on the `Plug.Upload` struct to obtain the path to where the uploaded file is stored in the temporary directory. I can then use said path as the argument in the `File.read/1` function which - in a successful scenario - will return a tuple with `:ok` and the binary that contains the contents of whatever the path leads to, i.e. in our case the image/video data in binary format.

This means that at this point we have all the parameters required for our uploads schema and, in the success case, `parse_upload_params/1` will return an `:ok`-tuple with those parameters and the - now no longer important - path. 
These params, along with the user (that we obtain through `conn.assigns.current_user` at the beginning of the `create/2` function), are then passed into `Content.create_upload/1` by the `create/2` function in our upload controller and stored in the database.

At this point, we have achieved the first step, namely, storing multimedia data in binary format in our database.

 
# 6. Upload template (Phoenix 1.5)

When I first started on my project, I was still using Phoenix 1.5 and the second step, i.e. displaying the multimedia data stored in the database in my template, was technically straightforward. In order to display the multimedia data in my .eex templates, I had to convert the binary data to base64-encoded data. Luckily, Elixir includes the `Base` module which provides a number of data encoding and decoding functions including `encode64/2`. The hardest part of this step was doing the research and finding the right code combination that I had to use in my templates in order to get the image/video source set up correctly. I tried a few things, and finally found that the following works (I used this code in my `upload/show.html.eex` file):

Image:
``` 
<img src="data:<%= @upload.file_type %>;base64,<%= Base.encode64(@upload.file)%>"> 
```

Video:
```
<video width="320" height="240" autoplay controls>
  <source src="data:video/mp4;base64,<%= Base.encode64(@upload.file)%>" />
</video>
```


# 7. Upload view and template (Phoenix 1.6)

All was good until I switched my application over to Phoenix 1.6 and the .heex templates did not allow me to interpolate my Elixir code inside the tags. I found that to be very frustrating. Eventually, I figured out the following workaround:

`Phoenix.HTML` provides the `sigil_E` macro for safe EEx syntax inside source files (see the [hexdocs](https://hexdocs.pm/phoenix/0.11.0/Phoenix.HTML.html) documentation). So I ended up creating a `display_image/1` and a `display_video/1` function in my `upload_view.ex` file, which respectively made use of the `sigil_E` macro to basically create the same code I used previously in the Phoenix 1.5 .eex template and which I was then able to call from inside the .heex template:

/upload_view.ex:

```
def display_image(%Upload{file: file, file_type: file_type}) do
  ~E"<img src=data:<%= file_type %>;base64,<%= Base.encode64(file) %>>"
end

def display_video(%Upload{file: file}) do
  ~E"""
    <video width="320" height="240" autoplay controls>
      <source src="data:video/mp4;base64,<%= Base.encode64(file) %>" />
    </video>
  """
end
```

/upload/show.html.eex:

```
 <p>
    <%= if @upload.file_type in Upload.valid_image_types do %>     
      <%= display_image(@upload) %>
    <% else %>
      <%= display_video(@upload) %>
    <% end %>
  </p>
```


# 8. But will it scale?!


Probably not. I am considering this to be a solution for small, personal projects, which is not meant to scale. It's a neat approach when you are just starting to work on something and don't want to enter into any commitment with third-party providers (yet) or when you know that your project will indeed remain a small one.




