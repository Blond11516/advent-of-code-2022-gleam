import gleam/map
import gleam/string
import gleam/list
import days/day_5/stack

type Crate =
  String

pub type CratesState =
  map.Map(Int, stack.Stack(Crate))

pub fn parse(input: String) -> CratesState {
  let lines =
    input
    |> string.split("\n")

  let #(lines, _) = list.split(lines, list.length(lines) - 1)

  lines
  |> list.map(parse_line)
  |> list.transpose()
  |> matrix_to_state()
}

fn matrix_to_state(matrix: List(List(String))) -> CratesState {
  let stacks =
    matrix
    |> list.map(fn(column: List(String)) {
      column
      |> list.filter(fn(col) { !string.is_empty(col) })
      |> stack.from_list()
    })

  let number_of_columns = list.length(stacks)

  list.range(1, number_of_columns)
  |> list.zip(stacks)
  |> map.from_list()
}

fn parse_line(input: String) -> List(String) {
  input
  |> string.to_graphemes()
  |> list.sized_chunk(4)
  |> list.map(string.join(_, ""))
  |> list.map(string.replace(_, "[", ""))
  |> list.map(string.replace(_, "]", ""))
  |> list.map(string.trim)
}
