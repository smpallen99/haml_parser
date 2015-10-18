defmodule Helpers.Test do
  use ExUnit.Case
  import Helpers

  test "extract_first '.test Some content'" do
    assert extract_first('.test Some content') == 
    ['.test', 'Some content']
  end
  
end
