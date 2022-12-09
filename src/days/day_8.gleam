import gleam/list
import gleam/map
import gleam/string
import gleam/int
import gleam/result
import gleam/order

pub fn pt_1(input: String) {
  let forest =
    input
    |> parse()

  forest
  |> map.to_list()
  |> list.filter(fn(tree) { is_visible(tree.0, tree.1, forest) })
  |> list.length()
}

pub fn pt_2(input: String) {
  let forest =
    input
    |> parse()

  forest
  |> map.to_list()
  |> list.map(fn(tree) { calculate_scenic_score(tree.0, tree.1, forest) })
  |> list.reduce(int.max)
  |> result.unwrap(0)
}

type Tree =
  #(#(Int, Int), Int)

fn parse(input: String) -> map.Map(#(Int, Int), Int) {
  assert Ok(forest) =
    input
    |> string.split("\n")
    |> list.index_map(parse_line)
    |> list.reduce(map.merge)

  forest
}

fn parse_line(y: Int, line: String) -> map.Map(#(Int, Int), Int) {
  line
  |> string.to_graphemes()
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, 99))
  |> list.index_map(fn(x, height) { #(#(x, y), height) })
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
  let #(left, right) = partition_tree_line(coordinates, forest)

  let is_visible_left = list.all(left, fn(tree) { tree.1 < height })
  let is_visible_right = list.all(right, fn(tree) { tree.1 < height })
  is_visible_left || is_visible_right
}

fn is_visible_in_column(coordinates: #(Int, Int), height, forest) -> Bool {
  let #(top, bottom) = partition_tree_column(coordinates, forest)

  let is_visible_top = list.all(top, fn(tree) { tree.1 < height })
  let is_visible_bottom = list.all(bottom, fn(tree) { tree.1 < height })
  is_visible_top || is_visible_bottom
}

fn partition_tree_line(
  coordinates: #(Int, Int),
  forest,
) -> #(List(Tree), List(Tree)) {
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
}

fn partition_tree_column(
  coordinates: #(Int, Int),
  forest,
) -> #(List(Tree), List(Tree)) {
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
}

// part 2

fn calculate_scenic_score(coordinates, height, forest) {
  let #(left, right) = partition_tree_line(coordinates, forest)
  let #(up, down) = partition_tree_column(coordinates, forest)

  [
    left
    |> sort_line()
    |> list.reverse(),
    sort_line(right),
    up
    |> sort_column()
    |> list.reverse(),
    sort_column(down),
  ]
  |> list.map(count_visible_trees(_, height))
  |> int.product()
}

fn sort_line(trees: List(Tree)) -> List(Tree) {
  list.sort(
    trees,
    fn(tree_a, tree_b) {
      let #(#(x_a, _), _) = tree_a
      let #(#(x_b, _), _) = tree_b
      case x_a, x_b {
        x_a, x_b if x_a < x_b -> order.Lt
        x_a, x_b if x_a > x_b -> order.Gt
        _, _ -> order.Eq
      }
    },
  )
}

fn sort_column(trees: List(Tree)) -> List(Tree) {
  list.sort(
    trees,
    fn(tree_a, tree_b) {
      let #(#(_, y_a), _) = tree_a
      let #(#(_, y_b), _) = tree_b
      case y_a, y_b {
        y_a, y_b if y_a < y_b -> order.Lt
        y_a, y_b if y_a > y_b -> order.Gt
        _, _ -> order.Eq
      }
    },
  )
}

fn count_visible_trees(trees, height) {
  trees
  |> list.fold_until(
    0,
    fn(count, tree) {
      let #(_, cur_height) = tree
      case cur_height {
        x if x < height -> list.Continue(count + 1)
        x if x >= height -> list.Stop(count + 1)
      }
    },
  )
}
