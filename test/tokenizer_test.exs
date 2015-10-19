defmodule Parser.Tokenizer.Test do
  use ExUnit.Case
  import Parser.Tokenizer

  test "tokenizes single line" do
    assert [[{:tag, 1, 'span'}]] == Parser.Tokenizer.tokenize("%span")
  end

  @haml """
%span
.cls#id
"""
  test "tokenizes multi line" do
    expected = [[{:tag, 1, 'span'}], [{:class, 2, 'cls'}, {:id, 2, 'id'}]]
    assert expected == Parser.Tokenizer.tokenize(@haml)
  end

@haml """
%div
  .cls Content
"""

  test "multiple with indentation" do
    expected = [[{:tag, 1, 'div'}], [{:ws, 2, '  '}, {:tag_content, 2, 'Content'}, {:class, 2, 'cls'}]]
    assert expected == Parser.Tokenizer.tokenize(@haml)
  end

  test "bracket type attributes" do
    expected = [[{:tag, 1, 'span'}, {:"(", 1}, {:atom, 1, :ng}, {:-, 1}, 
      {:atom, 1, :class}, {:=, 1}, {:quote, 1, '"cls"'}, {:ws, 1, ' '}, 
      {:atom, 1, :id}, {:=, 1}, {:quote, 1, '"id-123"'}]]
    assert expected == Parser.Tokenizer.tokenize(~s(%span(ng-class="cls" id="id-123"))
  end

  test "multiple quotes" do
    expected = [[{:atom, 1, :one}, {:=, 1}, {:quote, 1, '"two"'}, {:ws, 1, ' '}, 
      {:atom, 1, :three}, {:=, 1}, {:quote, 1, '"four"'}]]
    assert expected == tokenize(~s(one="two" three="four"))
  end
  
end
