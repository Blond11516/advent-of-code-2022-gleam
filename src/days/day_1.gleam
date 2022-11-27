import gleam/string
import gleam/list
import gleam/int
import gleam/result
import gleam/function

pub fn pt_1(input: String) -> Int {
  string.split(input, "\n")
  |> list.map(fn(raw_depth) {
    raw_depth
    |> int.parse()
    |> result.unwrap(0)
  })
  |> list.window(2)
  |> list.map(fn(depths) {
    let [first, second] = depths
    second > first
  })
  |> list.filter(function.identity)
  |> list.length()
}

pub fn pt_2(input: String) -> Int {
  string.split(input, "\n")
  |> list.map(fn(raw_depth) {
    raw_depth
    |> int.parse()
    |> result.unwrap(0)
  })
  |> list.window(3)
  |> list.map(fn(depths) {
    let [first, second, third] = depths
    first + second + third
  })
  |> list.window(2)
  |> list.map(fn(depths) {
    let [first, second] = depths
    second > first
  })
  |> list.filter(function.identity)
  |> list.length()
}
