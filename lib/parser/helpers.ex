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

  def gen_tag({_token, line, tag}) do
    [%{tag: "#{tag}", line_number: line, indent: 0}]
  end
  def gen_attrs({token, _line, tag}) do
    '#{token}="#{tag}"'
  end
  def gen_div({token, line, tag}) do
    [%{tag: "div", indent: 0, line_number: line, attributes: "#{token}=\"#{tag}\""}]
    # '<div #{token}="#{tag}"></div>'
  end
  def gen_div(first, second) do
    Logger.debug "gen_div: '#{inspect first}', '#{inspect second}'"

    attrs = first ++ second

    line = Keyword.get(attrs, :line_number)
    attrs = Keyword.delete(attrs, :line_number)

    {attrs, content} = case Keyword.get(attrs, :tag_content) do
      nil -> {attrs, ""}
      value -> {Keyword.delete(attrs, :tag_content), value}
    end
    attrs =  Keyword.delete(attrs, :ws)
    |> build_attrs

    [%{tag: "div", indent: 0, line_number: line, attributes: attrs, content: _to_string(content)}]
    # '<div #{attrs}>#{content}</div>'
  end

  def div_attr({token, line, tag}) do
    [{token, tag}, {:line_number, line}]
  end
  def extract_tokens({token, _line, tag}) do
    Logger.debug "extract_tokens 1"
    {token, tag}
  end
  def extract_tokens([item]) do
    Logger.debug "extract_tokens 2"
    item
  end
  def leading_ws({_token, _line, tag}) do
    [indent: Enum.count(tag)]
  end
  def add_indent(indent, [tag | tail]) do
    # Logger.debug "add_indent indent: #{inspect indent}, tag: #{inspect tag}, tail: #{inspect tail}"
    [Enum.into(indent, tag)|tail]
  end
  # def add_indent(indent, tag) do
  #   Logger.debug "add_indent indent: #{inspect indent}, tag: #{inspect tag}"
  #   Enum.into(indent, tag)
  # end

  def render_page(page) do
    # Logger.debug "page: #{inspect page}"
    # Enum.reduce page, [], fn(item, acc) -> 
    #   case acc do
    #     [] -> [item]
    #     [h|t] -> 
    # end
    nest_list page
  end

  def nest_list(list), do: nest_list(list, nil, [])
  def nest_list([], _, acc) do 
    Logger.debug "next_list0: acc: #{inspect acc}"
    unroll_stack(acc, 0)
    |> Enum.reverse
  end
  def nest_list([%{indent: ind1} = h|t], incr, [%{indent: ind2}|_] = acc )  when ind1 < ind2 do
    # Logger.debug "next_list2: ind1: #{ind1}, tag: #{h[:tag]}, "
    incr = if ind2 == 0, do: ind1, else: incr

    new_acc = [h | unroll_stack(acc, ind1)]
    # Logger.debug "next_list2: acc: #{inspect new_acc}"
    # Logger.debug "next_list2: t: #{inspect t}"
    nest_list t, incr, new_acc
  end
  def nest_list([%{indent: indent} = h|t], incr, acc) do
    # Logger.debug "nest_list: indent: #{indent},  acc: #{inspect acc}, t: #{inspect t}"
    nest_list t, incr, [h|acc]
  end

  def unroll_stack([h|t], indent) do
    _unroll_stack(t, [h], indent)
    # Enum.reverse _unroll_stack(t, [h], indent)
  end
  def _unroll_stack([], children, _), do: children
  def _unroll_stack([%{indent: 0}|_] = acc, [%{indent: 0}|_] = children, _) do
    Logger.debug "ur0: acc: #{inspect acc}, children: #{inspect children}"
    children ++ acc
  end
  def _unroll_stack([%{indent: 0} = h|t], children, _) do
    Logger.debug "ur1: h: #{inspect h}, children: #{inspect children}"
    [put_in(h, [:children], children)|t]
  end
  def _unroll_stack([%{indent: ind} = h|t], [%{indent: ind}|_] = children, indent) do
    Logger.debug "ur2: ind: #{indent}, h: #{inspect h}, children: #{inspect children}"
    _unroll_stack(t, [h|children], indent)
  end
  def _unroll_stack([%{indent: ind1} = h|t], [%{indent: ind2}|_] = children, indent) do
    Logger.debug "ur3: ind: #{indent}, indent: #{indent}, h: #{inspect h}, children: #{inspect children}"
    new_h = put_in(h, [:children], children)
    if (ind1 > indent), do: _unroll_stack(t, [new_h], indent), else: [new_h|t]
  end

  defp build_attrs(list) do
    Logger.debug "... #{inspect list}"
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
  defp _to_string(list) when is_list(list), do: List.to_string(list)
  defp _to_string(binary) when is_binary(binary), do: binary
end
