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
    _tokens = [
      [{:tag, 1, 'span'}], 
      [{:ws, 2, '  '}, {:tag_content, 2, 'Some Content'}, {:id, 2, 'id'}],
    ]
    #assert ~s(<span>\n<div id="id" >Some Content</div>\n</span>\n) == Parser.Parser.parse(tokens)
  end

  test "parses multiple indentation" do
    _tokens = [
      [{:tag, 1, 'span'}], 
      [{:ws, 2, '  '}, {:tag, 2, 'select'}],
      [{:ws, 3, '    '}, {:tag_content, 3, 'Some Content'}, {:id, 3, 'id'}],
    ]
    #assert ~s(test) == Parser.Parser.parse(tokens)
  end
  test "parses complex indentation" do
    _tokens = [
      [{:tag, 1, 'span'}], 
      [{:ws, 2, '  '}, {:tag, 2, 'select'}],
      [{:ws, 3, '    '}, {:tag, 3, 'option'}],
      [{:tag, 4, 'strong'}],
    ]
    #assert ~s(test) == Parser.Parser.parse(tokens)
  end
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

  test "bracket type attributes" do
    # ~s(%span(ng-class="cls" id="id-123")
    tokens = [[{:tag, 1, 'span'}, {:"(", 1}, {:atom, 1, :ng}, {:-, 1}, 
      {:atom, 1, :class}, {:=, 1}, {:quote, 1, '"cls"'}, {:ws, 1, ' '}, 
      {:atom, 1, :id}, {:=, 1}, {:quote, 1, '"id-123"'}, {:")", 1}]]
    expected = [%{attributes: [id: "id-123", "ng-class": "cls"], indent: 0, line_number: 1, tag: "span"}]
    assert expected == Parser.Parser.parse(tokens)
  end

  test "brace type attributes" do
    # ~s(%span{ng-class: "cls", id: "id-123"})
    tokens = [
      # [{:tag, 1, 'span'}, {:"{", 1}, {:atom, 1, :ng}, {:-, 1}, {:key, 1, :class}, 
      [{:tag, 1, 'span'}, {:"{", 1}, {:dkey, 1, :class}, 
       {:quote, 1, '"cls"'}, {:",", 1}, {:ws, 1, ' '}, {:dkey, 1, :id}, 
       {:quote, 1, '"id-123"'}, {:"}", 1}]
     ]
    expected = [%{attributes: [id: "id-123", class: "cls"], indent: 0, line_number: 1, tag: "span"}]
    assert expected == Parser.Parser.parse(tokens)
  end
  test "brace type attributes dashed names" do
    # ~s(%span{ng-class: "cls", id: "id-123"})
    tokens = [[{:tag, 1, 'span'}, {:"{", 1}, {:dkey, 1, :"ng-class"}, 
      {:quote, 1, '"cls"'}, {:",", 1}, {:ws, 1, ' '}, 
      {:dkey, 1, :id}, {:quote, 1, '"id-123"'}, {:"}", 1}]]
    expected = [%{attributes: [id: "id-123", "ng-class": "cls"], indent: 0, line_number: 1, tag: "span"}]
    assert expected == Parser.Parser.parse(tokens)
  end
end
