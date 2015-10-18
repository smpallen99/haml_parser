defmodule Helpers.Test do
  use ExUnit.Case
  import Helpers

  test "extract_first '.test Some content'" do
    assert extract_first('.test Some content') == 
    ['.test', 'Some content']
  end

  test "gen_div [id: 'my-id']', '[class: 'my-class']" do
    result = gen_div([id: 'my-id'], [class: 'my-class'])
    |> List.to_string
    assert String.contains?(result, ~s(id="my-id"))
    assert String.contains?(result, ~s(class="my-class"))
  end
  
end
