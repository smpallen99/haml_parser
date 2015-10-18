defmodule Helpers do
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
end
