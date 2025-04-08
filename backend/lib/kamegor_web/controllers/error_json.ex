defmodule KamegorWeb.ErrorJSON do
  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message itself.
  # You can change this behaviour by implementing a render
  # clause matching the status code:
  #
  # def render("404.json", _assigns) do
  #   %{errors: %{detail: "Not Found"}}
  # end

  # Renders the default template for other status codes.
  # If we specify a :message assign, include it in the details.
  def render(status, assigns) do
    %{
      errors: %{
        detail: assigns[:message] || Phoenix.Controller.status_message_from_template(status)
      }
    }
  end
end
