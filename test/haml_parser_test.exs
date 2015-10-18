defmodule HamlParser.Test do
  use ExUnit.Case 

  test "parses [{:tag, 1, 'select'}]" do
    {:ok, result} = :haml_parser.parse([{:tag, 1, 'select'}])
    assert '<select></select>' == result
  end
   
  test "parses [{:id, 1, 'my-id'}]" do
    {:ok, result} = :haml_parser.parse([{:id, 1, 'my-id'}])
    assert '<div id="my-id"></div>' == result
  end
  test "parses [{:class, 1, 'my-class'}]" do
    {:ok, result} = :haml_parser.parse([{:class, 1, 'my-class'}])
    assert '<div class="my-class"></div>' == result
  end
  test "parses [{:id, 1, 'my-id}, {:class, 1, 'my-class'}]" do
    {:ok, result} = :haml_parser.parse([{:id, 1, 'my-id'}, {:class, 1, 'my-class'}])
    result = List.to_string result

    assert String.contains?(result, ~s(id="my-id"))
    assert String.contains?(result, ~s(class="my-class))
  end

  test "parses [{:id, 1, 'my-id}, {:class, 1, 'my-class'}, {:class, 1, 'other'}]" do
    attrs = [{:id, 1, 'my-id'}, {:class, 1, 'my-class'}, {:class, 1, 'other'}]
    {:ok, result} = :haml_parser.parse(attrs)
    result = List.to_string result

    assert String.contains?(result, ~s(id="my-id"))
    assert String.contains?(result, ~s(class="my-class other"))
  end
end
