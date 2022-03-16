defmodule TheBrogrammer.EmailBuilder do
  @moduledoc """
  Uses the passed in map to build an email that can be sent by the Swoop mailer
  """
  import Swoosh.Email

  def create_email(%{from_email: from_email, name: name, subject: subject, message: message}) do
    new()
    |> to({"Cornelia", "corneliakelinske@gmail.com"})
    |> from({name, from_email})
    |> subject(subject)
    |> html_body("<h1>#{message}</h1>")
    |> text_body("#{message}\n")
  end
end
