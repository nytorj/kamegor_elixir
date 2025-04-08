defmodule KamegorWeb.ChangesetJSON do
  @doc """
  Renders changeset errors for the "error.json" template.
  """
  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  # Fallback for other templates (if any were defined)
  # def render(template, assigns) do
  #   # Handle other templates or raise error
  # end

  defp translate_error({msg, opts}) do
    # You can make this fancier by adding translation logic using Gettext
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
