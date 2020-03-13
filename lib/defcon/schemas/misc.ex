defmodule Defcon.Schemas.FilterNotLoaded do
  @moduledoc false

  defmacro __using__(attrs: attrs) do
    quote bind_quoted: [module: __CALLER__.module, attrs: attrs] do
      defimpl Jason.Encoder, for: module do
        def encode(item, opts) do
          out =
            item
            |> Map.take(unquote(attrs))
            |> Enum.filter(fn {attr, value} ->
              case value do
                %Ecto.Association.NotLoaded{} ->
                  false

                _ ->
                  if String.ends_with?(to_string(attr), "_spec") && is_nil(value) do
                    false
                  else
                    true
                  end
              end
            end)
            |> Map.new()

          Jason.Encode.map(out, opts)
        end
      end
    end
  end
end
