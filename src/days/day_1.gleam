import gleam/string
import gleam/list
import gleam/result
import gleam/int
import gleam/order

pub fn pt_1(input: String) -> Int {
  input
  |> string.split("\n\n")
  |> list.map(parse_elf)
  |> list.map(sum)
  |> find_max()
}

pub fn pt_2(input: String) -> Int {
  input
  |> string.split("\n\n")
  |> list.map(parse_elf)
  |> list.map(sum)
  |> list.sort(fn(a, b) {
    int.compare(a, b)
    |> order.reverse()
  })
  |> list.take(3)
  |> sum()
}

fn parse_elf(calories_report: String) -> List(Int) {
  calories_report
  |> string.split("\n")
  |> list.map(parse_calories)
}

fn find_max(nums: List(Int)) -> Int {
  list.fold(nums, 0, int.max)
}

fn sum(nums: List(Int)) -> Int {
  list.fold(nums, 0, int.add)
}

fn parse_calories(raw: String) -> Int {
  raw
  |> int.parse()
  |> result.unwrap(0)
}
