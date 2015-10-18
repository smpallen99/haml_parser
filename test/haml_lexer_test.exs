defmodule Parser.HamlLexer.Test do
  use ExUnit.Case

  test "lex .cls1.cls2#my-id" do
    source = ".cls1.cls2#my-id"
    {:ok, tokens, _} = source |> String.to_char_list |> :haml_lexer.string
    assert [{:class, 1, 'cls1'}, {:class, 1, 'cls2'}, {:id, 1, 'my-id'}] == tokens
  end

  test ".my-class Hello there" do
    source = ".my-class Hello there"
    {:ok, tokens, _} = source |> String.to_char_list |> :haml_lexer.string
    assert [{:tag_content, 1, 'Hello there'}, {:class, 1, 'my-class'}] == tokens
  end

  test "%select" do
    source = "%select"
    {:ok, tokens, _} = source |> String.to_char_list |> :haml_lexer.string
    assert [{:tag, 1, 'select'}] == tokens
  end

  test "#id.cls Some content" do
    source = "#id.cls Some content"
    {:ok, tokens, _} = source |> String.to_char_list |> :haml_lexer.string
    assert [{:id, 1, 'id'}, {:tag_content, 1, 'Some content'}, {:class, 1, 'cls'}] == tokens
  end
  
end
