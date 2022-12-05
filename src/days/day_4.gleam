import gleam/string
import gleam/list
import gleam/int

pub fn pt_1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_assignment_pair)
  |> list.filter(assignments_contain)
  |> list.length()
}

pub fn pt_2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_assignment_pair)
  |> list.filter(assignments_overlap)
  |> list.length()
}

type Assignment =
  #(Int, Int)

fn assignments_overlap(assignments: #(Assignment, Assignment)) -> Bool {
  let #(first, other) = assignments
  let #(other_start, other_end) = other

  assignments_contain(assignments) || contains_id(first, other_start) || contains_id(
    first,
    other_end,
  )
}

fn contains_id(assignment: Assignment, id: Int) -> Bool {
  let #(start, end) = assignment

  start <= id && id <= end
}

fn assignments_contain(assignments: #(Assignment, Assignment)) {
  let #(first, other) = assignments

  contains(does: first, contain: other) || contains(does: other, contain: first)
}

fn contains(does first: Assignment, contain other: Assignment) -> Bool {
  let #(first_start, first_end) = first
  let #(other_start, other_end) = other

  first_start <= other_start && first_end >= other_end
}

fn parse_assignment_pair(input: String) -> #(Assignment, Assignment) {
  let [raw_pair_1, raw_pair_2] = string.split(input, ",")

  #(parse_assignment(raw_pair_1), parse_assignment(raw_pair_2))
}

fn parse_assignment(input: String) -> Assignment {
  let [raw_start, raw_end] = string.split(input, "-")

  assert Ok(start) = int.parse(raw_start)
  assert Ok(end) = int.parse(raw_end)

  #(start, end)
}
