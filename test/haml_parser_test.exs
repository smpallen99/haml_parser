defmodule HamlParser.Test do
  use ExUnit.Case 
  require Logger

  # test "parses [{:tag, 1, 'select'}]" do
  #   {:ok, result} = :haml_parser.parse([{:tag, 1, 'select'}])
  #   assert '<select></select>' == result
  # end
   
  # test "parses [{:id, 1, 'my-id'}]" do
  #   {:ok, result} = :haml_parser.parse([{:id, 1, 'my-id'}])
  #   assert '<div id="my-id"></div>' == result
  # end
  test "parses [{:class, 1, 'my-class'}]" do
    {:ok, result} = :haml_parser.parse([{:class, 1, 'my-class'}])
    assert [%{tag: "div", indent: 0, line_number: 1, attributes: ~s(class="my-class")}] == result
  end
  test "parses [{:id, 1, 'my-id}, {:class, 1, 'my-class'}]" do
    {:ok, result} = :haml_parser.parse([{:id, 1, 'my-id'}, {:class, 1, 'my-class'}])
    [%{tag: "div", attributes: attributes}] = result

    assert String.contains?(attributes, ~s(id="my-id"))
    assert String.contains?(attributes, ~s(class="my-class))
  end

  test "parses [{:id, 1, 'my-id}, {:class, 1, 'my-class'}, {:class, 1, 'other'}]" do
    attrs = [{:id, 1, 'my-id'}, {:class, 1, 'my-class'}, {:class, 1, 'other'}]
    {:ok, result} = :haml_parser.parse(attrs)
    [%{tag: "div", attributes: attributes}] = result

    assert String.contains?(attributes, ~s(id="my-id"))
    assert String.contains?(attributes, ~s(class="my-class other"))
  end

  test "parses [{:id, 1, 'id'}, {:tag_content, 1, 'Some content'}, {:class, 1, 'cls'}]" do
    tokens = [{:id, 1, 'id'}, {:tag_content, 1, 'Some content'}, {:class, 1, 'cls'}]
    {:ok, result} = :haml_parser.parse(tokens)
    [%{tag: "div", attributes: attributes, content: content}] = result
    Logger.debug "result 3: #{inspect result}"

    assert String.contains?(attributes, ~s(id="id"))
    assert String.contains?(attributes, ~s(class="cls"))
    assert String.contains?(content, ~s(Some content))
  end
end
