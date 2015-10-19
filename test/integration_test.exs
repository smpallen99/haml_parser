defmodule HamlParser.Integration.Test do
  use ExUnit.Case
  require Logger

  test "parses #id-1.test.other" do
    source = "#id-1.test.other"
    {:ok, tokens, _} = source |> String.to_char_list |> :haml_lexer.string
    {:ok, parsed} = :haml_parser.parse(tokens)

    result = Parser.Compile.build_html(parsed)

    assert String.contains?(result, ~s(id="id-1"))
    assert String.contains?(result, ~s(class="test other"))
  end

  test "parses #id-1.test.other Some Text" do
    source = "#id-1.test.other Some Text"
    {:ok, tokens, _} = source |> String.to_char_list |> :haml_lexer.string
    {:ok, parsed} = :haml_parser.parse(tokens)

    result = Parser.Compile.build_html(parsed)
    Logger.debug "result...: #{inspect result}"
    assert String.contains?(result, ~s(id="id-1"))
    assert String.contains?(result, ~s(class="test other"))
    assert String.contains?(result, ~s(>Some Text</div>))
  end

  @haml """
%span(ng-class="testing you" id="test")
%span(ng-class="ou" id="tt")

  """

  test "build simple file" do
    result = @haml
    |> Parser.Tokenizer.tokenize
    |> Parser.Parser.parse
    |> Parser.Compile.build_html

    assert "<span id=\"test\" ng-class=\"testing you\">\n</span>\n<span id=\"tt\" ng-class=\"ou\">\n</span>\n" == result
  end
end
