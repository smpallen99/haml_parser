defmodule Parser.Compile do

  @self_closing ~w(input)

  def build_html(nodes) do
    build_node("", nodes)
  end

  def build_node(acc, nil), do: acc
  def build_node(acc, []), do: acc
  def build_node(acc, [h|t]) do
    acc  
    |> node_open(h)
    |> build_node(h[:children])
    |> node_close(h)
    |> build_node(t)
  end

  def node_open(acc, %{tag: tag, content: content} = node) do
    acc <> "<#{tag}#{attributes node}>#{content}"
  end
  def node_open(acc, %{tag: tag} = node) when tag in @self_closing do
    acc <> "<#{tag}#{attributes node}/>\n"
  end
  def node_open(acc, %{tag: tag} = node) do
    acc <> "<#{tag}#{attributes node}>\n"
  end
  def node_close(acc, %{tag: tag}) when tag in @self_closing, do: acc
  def node_close(acc, %{tag: tag}) do
    acc <> "</#{tag}>\n"
  end

  def attributes(%{attributes: nil}), do: ""
  def attributes(%{attributes: attrs}) when is_binary(attrs), do: " " <> attrs
  def attributes(%{attributes: attrs}) when is_list(attrs) do 
    Enum.reduce(attrs, "", fn({k,v}, acc) -> 
      acc <> " " <> Atom.to_string(k) <> "=" <> "\"" <> v <> "\""
    end)
  end
  def attributes(_), do: ""


  
end
