defmodule Defcon.Stash do
  @moduledoc false

  @path "/tmp/defcon-stash"

  def load_for(uuid) do
    with :ok <- File.mkdir_p("#{@path}"),
         {:ok, content} <- File.read("#{@path}/#{uuid}.json"),
         {:ok, payload} <- Jason.decode(content) do
      payload
    else
      _ -> :empty
    end
  end

  def save_for(uuid, payload) do
    with :ok <- File.mkdir_p("#{@path}"),
         {:ok, content} <- Jason.encode(payload),
         {:ok, file} <- File.open("#{@path}/#{uuid}.json", [:write]),
         :ok <- IO.binwrite(file, content) do
      :ok
    else
      _ ->
        :error
    end
  end
end
