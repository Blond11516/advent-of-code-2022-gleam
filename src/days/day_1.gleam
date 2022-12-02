import gleam/string
import gleam/list
import gleam/result
import gleam/int
import gleam/order

pub fn pt_1(input: String) -> Int {
  input
  |> string.split("\n")
  |> group_calories()
  |> list.map(sum)
  |> find_max()
}

pub fn pt_2(input: String) -> Int {
  input
  |> string.split("\n")
  |> group_calories()
  |> list.map(sum)
  |> list.sort(fn(a, b) {
    int.compare(a, b)
    |> order.reverse()
  })
  |> list.take(3)
  |> sum()
}

fn find_max(nums: List(Int)) -> Int {
  list.fold(nums, 0, int.max)
}

fn sum(nums: List(Int)) -> Int {
  list.fold(nums, 0, int.add)
}

fn group_calories(calories_items: List(String)) -> List(List(Int)) {
  list.fold(
    calories_items,
    [[]],
    fn(acc, cur) {
      case cur {
        "" -> [[], ..acc]
        raw -> {
          let calories = parse_calories(raw)
          let [first, ..rest] = acc
          [[calories, ..first], ..rest]
        }
      }
    },
  )
}

fn parse_calories(raw: String) -> Int {
  raw
  |> int.parse()
  |> result.unwrap(0)
}
