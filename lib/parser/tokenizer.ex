defmodule Parser.Tokenizer do
  
  def tokenize(haml) when is_binary(haml) do
    Regex.split(~r/\n/, haml, trim: true) |> tokenize #|> filter # |> tokenize_identation |> index
  end

  def tokenize([]), do: []
  def tokenize(list) do
    {_, result} = Enum.reduce list, {1, []}, fn(line, {line_no, acc}) -> 
      {line_no + 1, [tokenize_line(line, line_no) | acc]}
    end
    Enum.reverse result
  end

  # defp filter(list), do: Enum.filter(list, fn(x) -> x != [] end)

  def tokenize_line(line, line_no) do
    {:ok, tokens, _} = line |> String.to_char_list |> :haml_lexer.string(line_no)
    tokens
  end
end
