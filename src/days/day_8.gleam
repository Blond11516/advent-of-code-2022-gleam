import gleam/list
import gleam/map
import gleam/string
import gleam/int
import gleam/result

pub fn pt_1(input: String) {
  let forest =
    input
    |> parse()

  forest
  |> map.to_list()
  |> list.filter(fn(tree) { is_visible(tree.0, tree.1, forest) })
  |> list.length()
}

pub fn pt_2(_input: String) {
  1
}

fn parse(input: String) -> map.Map(#(Int, Int), Int) {
  assert Ok(forest) =
    input
    |> string.split("\n")
    |> list.index_map(parse_line)
    |> list.reduce(map.merge)

  forest
}

fn parse_line(x: Int, line: String) -> map.Map(#(Int, Int), Int) {
  line
  |> string.to_graphemes()
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, 99))
  |> list.index_map(fn(y, height) { #(#(x, y), height) })
  |> map.from_list()
}

fn is_visible(coordinates: #(Int, Int), height, forest) -> Bool {
  is_visible_in_line(coordinates, height, forest) || is_visible_in_column(
    coordinates,
    height,
    forest,
  )
}

fn is_visible_in_line(coordinates: #(Int, Int), height, forest) -> Bool {
  let #(left, right) =
    forest
    |> map.to_list()
    |> list.filter(fn(tree) {
      let #(#(x, y), _) = tree

      x == coordinates.0 && y != coordinates.1
    })
    |> list.partition(fn(tree) {
      let #(#(_, y), _) = tree
      y < coordinates.1
    })

  let is_visible_left = list.all(left, fn(tree) { tree.1 < height })
  let is_visible_right = list.all(right, fn(tree) { tree.1 < height })
  is_visible_left || is_visible_right
}

fn is_visible_in_column(coordinates: #(Int, Int), height, forest) -> Bool {
  let #(top, bottom) =
    forest
    |> map.to_list()
    |> list.filter(fn(tree) {
      let #(#(x, y), _) = tree

      x != coordinates.0 && y == coordinates.1
    })
    |> list.partition(fn(tree) {
      let #(#(x, _), _) = tree
      x < coordinates.0
    })

  let is_visible_top = list.all(top, fn(tree) { tree.1 < height })
  let is_visible_bottom = list.all(bottom, fn(tree) { tree.1 < height })
  is_visible_top || is_visible_bottom
}
