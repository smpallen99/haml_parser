defmodule Helpers.Test do
  use ExUnit.Case
  import Helpers
  require Logger

  test "gen_div [id: 'my-id']', '[class: 'my-class']" do
    [%{tag: "div", attributes: result}] = gen_div([id: 'my-id'], [class: 'my-class'])
    assert String.contains?(result, ~s(id="my-id"))
    assert String.contains?(result, ~s(class="my-class"))
  end

  test "nest flat list" do
    source = [
      %{tag: "one", indent: 0, line_number: 1},
      %{tag: "two", indent: 0, line_number: 2},
      %{tag: "three", indent: 0, line_number: 3},
    ]
    assert source == nest_list(source)
  end
  test "nest single indent" do
    source = [
      %{tag: "one", indent: 0, line_number: 1},
      %{tag: "two", indent: 2, line_number: 2},
    ]
    expected = [
      %{tag: "one", indent: 0, line_number: 1, children: [
          %{tag: "two", indent: 2, line_number: 2},
        ]},
    ]
    assert expected == nest_list(source)
  end
  test "nest outer outdent" do
    source = [
      %{tag: "one", indent: 0, line_number: 1},
      %{tag: "two", indent: 2, line_number: 2},
      %{tag: "three", indent: 0, line_number: 3},
    ]
    expected = [
      %{tag: "one", indent: 0, line_number: 1, children: [
          %{tag: "two", indent: 2, line_number: 2},
        ]},
      %{tag: "three", indent: 0, line_number: 3},
    ]
    assert expected == nest_list(source)
  end
  test "nest inner single outdent" do
    source = [
      %{tag: "one", indent: 0, line_number: 1},
      %{tag: "two", indent: 2, line_number: 2},
      %{tag: "three", indent: 4, line_number: 3},
      %{tag: "four1", indent: 6, line_number: 4},
      %{tag: "four2", indent: 6, line_number: 5},
      %{tag: "five", indent: 2, line_number: 6},
    ]
    expected = [
      %{tag: "one", indent: 0, line_number: 1, children: [
          %{tag: "two", indent: 2, line_number: 2, children: [
            %{tag: "three", indent: 4, line_number: 3, children: [
              %{tag: "four1", indent: 6, line_number: 4},
              %{tag: "four2", indent: 6, line_number: 5},
            ]},
          ]},
          %{tag: "five", indent: 2, line_number: 6},
        ]},
    ]
    result = nest_list(source)
    assert expected == result
  end

  test "unroll stack" do
    source = [
      %{tag: "three", indent: 4, line_number: 3},
      %{tag: "two", indent: 2, line_number: 2},
      %{tag: "one", indent: 0, line_number: 1},
    ]
    expected = [
      %{tag: "two", indent: 2, line_number: 2, children: [
        %{tag: "three", indent: 4, line_number: 3}
      ]},
      %{tag: "one", indent: 0, line_number: 1},
    ]
    assert expected == unroll_stack(source, 2)
  end
  test "unroll stack 2 levels" do
    source = [
      %{tag: "four2", indent: 6, line_number: 5},
      %{tag: "four1", indent: 6, line_number: 4},
      %{tag: "three", indent: 4, line_number: 3},
      %{tag: "two", indent: 2, line_number: 2},
      %{tag: "one", indent: 0, line_number: 1},
    ]
    expected = [
      %{tag: "two", indent: 2, line_number: 2, children: [
        %{tag: "three", indent: 4, line_number: 3, children: [
          %{tag: "four1", indent: 6, line_number: 4},
          %{tag: "four2", indent: 6, line_number: 5},
        ]},
      ]},
      %{tag: "one", indent: 0, line_number: 1},
    ]
    assert expected == unroll_stack(source, 2)
  end
  test "unroll stack 2 at 0 one nested" do
    source = [
      %{indent: 0, line_number: 3, tag: "three"}, 
      %{children: [%{indent: 2, line_number: 2, tag: "two"}], indent: 0, line_number: 1, tag: "one"}
    ]
    expected = [
      %{tag: "three", indent: 0, line_number: 3},
      %{tag: "one", indent: 0, line_number: 1, children: [
          %{tag: "two", indent: 2, line_number: 2},
        ]},
    ]
    assert expected == unroll_stack(source, 0)
  end

end
