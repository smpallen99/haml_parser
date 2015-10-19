defmodule Parser.Tokenizer.Test do
  use ExUnit.Case

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
  
end
