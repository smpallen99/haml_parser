defmodule ParserTest do
  use ExUnit.Case
  require Logger

  test "parses single line" do
    tokens = [[{:tag, 1, 'span'}]]
    assert [%{indent: 0, line_number: 1, tag: "span"}] == Parser.Parser.parse(tokens)
  end

  test "parses multiple lines" do
    tokens = [[{:tag, 1, 'span'}], [{:tag_content, 2, 'Some Content'}, {:id, 2, 'id'}]]
    expected =[
      %{indent: 0, line_number: 1, tag: "span"}, 
      %{attributes: "id=\"id\" ", content: "Some Content", indent: 0, line_number: 2, tag: "div"}
    ] 
    assert expected == Parser.Parser.parse(tokens)
  end

  test "parses single indentation" do
    tokens = [
      [{:tag, 1, 'span'}], 
      [{:ws, 2, '  '}, {:tag_content, 2, 'Some Content'}, {:id, 2, 'id'}],
    ]
    #assert ~s(<span>\n<div id="id" >Some Content</div>\n</span>\n) == Parser.Parser.parse(tokens)
  end

  test "parses multiple indentation" do
    tokens = [
      [{:tag, 1, 'span'}], 
      [{:ws, 2, '  '}, {:tag, 2, 'select'}],
      [{:ws, 3, '    '}, {:tag_content, 3, 'Some Content'}, {:id, 3, 'id'}],
    ]
    #assert ~s(test) == Parser.Parser.parse(tokens)
  end
  test "parses complex indentation" do
    tokens = [
      [{:tag, 1, 'span'}], 
      [{:ws, 2, '  '}, {:tag, 2, 'select'}],
      [{:ws, 3, '    '}, {:tag, 3, 'option'}],
      [{:tag, 4, 'strong'}],
    ]
    #assert ~s(test) == Parser.Parser.parse(tokens)
  end
  # %div
  #   %div
  #     %div
  #     %div
  #   %div
  test "parses more complex indentation" do
    tokens = [
      [{:tag, 1, 'span'}], 
      [{:ws, 2, '  '}, {:tag, 2, 'select'}],
      [{:ws, 3, '    '}, {:tag_content, 3, 'Some Content'}, {:id, 3, 'id'}],
      [{:tag, 4, 'strong'}],
    ]
    expected = [
      %{indent: 0, line_number: 1, tag: "span", children: [
        %{indent: 2, line_number: 2, tag: "select", children: [
          %{attributes: "id=\"id\" ", content: "Some Content", indent: 4, line_number: 3, tag: "div"},
        ]}, 
      ]}, 
      %{indent: 0, line_number: 4, tag: "strong"}
    ]
    assert expected == Parser.Parser.parse(tokens)
  end

end
