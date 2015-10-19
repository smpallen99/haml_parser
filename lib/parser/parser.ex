defmodule Parser.Parser do
  require Logger


  def parse([[]]), do: ""

  def parse(list) do
    {:ok, result} = :haml_parser.parse(List.flatten list)
    # Enum.reduce list, "", fn(x, acc) ->
    #   res = parse_line(x)
    #   acc <> "#{res}\n"
    # end
    result
  end

  def parse_line(tokens) do
    {:ok, result} = :haml_parser.parse(tokens)
    result
  end

end
