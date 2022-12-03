import gleam/string
import gleam/list
import gleam/set
import gleam/int
import gleam/result

pub fn pt_1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_rucksack)
  |> list.map(find_common_item)
  |> list.map(get_item_priority)
  |> sum()
}

pub fn pt_2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_rucksack)
  |> group_rucksacks()
  |> list.map(find_badge)
  |> list.map(get_item_priority)
  |> sum()
}

type Rucksack =
  #(set.Set(String), set.Set(String))

fn parse_rucksack(input: String) -> Rucksack {
  let input_length = string.length(input)

  let #(first_compartment, second_compartment) =
    input
    |> string.to_graphemes()
    |> list.split(input_length / 2)

  #(set.from_list(first_compartment), set.from_list(second_compartment))
}

fn find_common_item(sack: Rucksack) -> String {
  let #(first_compartment, second_compartment) = sack

  assert Ok(item) =
    set.intersection(first_compartment, second_compartment)
    |> set.to_list()
    |> list.first()

  item
}

fn get_item_priority(item: String) -> Int {
  let <<ascii_value:int>> = <<item:utf8>>

  case ascii_value {
    x if x >= 65 && x <= 90 -> x - 38
    x if x >= 97 && x <= 132 -> x - 96
  }
}

fn sum(nums: List(Int)) -> Int {
  list.fold(nums, 0, int.add)
}

// Part 2

type Group =
  #(Rucksack, Rucksack, Rucksack)

external fn list_to_3_tuple(List(a)) -> #(a, a, a) =
  "erlang" "list_to_tuple"

external fn tuple_3_to_list(#(a, a, a)) -> List(a) =
  "erlang" "tuple_to_list"

fn group_rucksacks(sacks: List(Rucksack)) -> List(Group) {
  sacks
  |> list.sized_chunk(3)
  |> list.map(list_to_3_tuple)
}

fn find_badge(group: Group) -> String {
  assert Ok(Ok(badge)) =
    group
    |> tuple_3_to_list()
    |> list.map(fn(sack: Rucksack) {
      let #(first_compartment, second_compartment) = sack
      set.union(first_compartment, second_compartment)
    })
    |> list.reduce(set.intersection)
    |> result.map(set.to_list)
    |> result.map(list.first)

  badge
}
