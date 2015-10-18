defmodule Helpers do
  require Logger

  def extract_token({_token, _line, value}), do: value
  def to_atom(':' ++ atom), do: List.to_atom(atom)
  def extract_first(list) do
    string = List.to_string list
    [_ | rest] = Regex.scan(~r/^([^\s]+)\s+(.+)/, string)
    |> Enum.at(0)
    rest 
    |> Enum.map(&(String.to_char_list &1))
  end

  def gen_tag({_token, _line, tag}) do
    '<#{tag}></#{tag}>'
  end
  def gen_attrs({token, _line, tag}) do
    '#{token}="#{tag}"'
  end
  def gen_div({token, _line, tag}) do
    '<div #{token}="#{tag}"></div>'
  end
  def gen_div(first, second) do
    Logger.debug "gen_div: '#{inspect first}', '#{inspect second}'"
    attrs = build_attrs(first ++ second)
    '<div #{attrs}></div>'
     
  end

  def div_attr({token, _line, tag}) do
    [{token, tag}]
  end
  def extract_tokens({token, _line, tag}) do
    Logger.debug "extract_tokens 1"
    {token, tag}
  end
  def extract_tokens([item]) do
    Logger.debug "extract_tokens 2"
    item
  end

  defp build_attrs(list) do
    # Logger.debug "... #{inspect list}"
    Enum.reduce(list, %{}, fn({k, v}, acc) ->
      update_in acc, [k], fn(x) -> 
        if is_nil(x), do: "#{v}", else: "#{x} #{v}"
      end
    end)
    |> Map.to_list 
    |> Enum.reduce("", fn({k,v}, acc) -> 
      acc <> "#{k}=\"#{v}\" "
    end)
  end
end
