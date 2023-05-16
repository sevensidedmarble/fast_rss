defmodule FastRSS do
  @moduledoc """
  Parse RSS quickly using a Rust NIF.
  """

  defmodule Native do
    @moduledoc false

    mix_config = Mix.Project.config()
    version = mix_config[:version]
    github_url = mix_config[:package][:links]["GitHub"]

    use Rustler, otp_app: :fast_rss, crate: "fastrss"

    # use RustlerPrecompiled,
    #   otp_app: :fast_rss,
    #   crate: "fastrss",
    #   base_url: "#{github_url}/releases/download/v#{version}",
    #   force_build: System.get_env("FORCE_BUILD") in ["1", "true"],
    #   version: version

    # When the NIF is loaded, it will override these functions.
    def parse_rss(_a), do: :erlang.nif_error(:nif_not_loaded)
    def parse_atom(_a), do: :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
  Parse an RSS string into a map.
  """
  @spec parse_rss(String.t()) :: {:ok, map()} | {:error, String.t()}
  def parse_rss(""), do: {:error, "Cannot parse blank string"}

  def parse_rss(rss_string) when is_binary(rss_string) do
    rss_string
    |> Native.parse_rss()
    |> map_to_tuple()
  end

  def parse_rss(_somethig_else), do: {:error, "RSS feed must be passed in as a string"}

  @doc """
  Parse an Atom string into a map.
  """
  @spec parse_atom(String.t()) :: {:ok, map()} | {:error, String.t()}
  def parse_atom(""), do: {:error, "Cannot parse blank string"}

  def parse_atom(atom_string) when is_binary(atom_string) do
    atom_string
    |> Native.parse_atom()
    |> map_to_tuple()
  end

  def parse_atom(_somethig_else), do: {:error, "RSS feed must be passed in as a string"}

  defp map_to_tuple(%{"Ok" => map}), do: {:ok, map}
  defp map_to_tuple({:ok, map}), do: {:ok, map}
  defp map_to_tuple(%{"Err" => msg}), do: {:error, msg}
  defp map_to_tuple({:error, msg}), do: {:error, msg}
end
