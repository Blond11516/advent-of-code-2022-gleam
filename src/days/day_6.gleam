import gleam/string
import gleam/list
import gleam/result
import gleam/set

pub fn pt_1(input: String) -> Int {
  solve(input, 4)
}

pub fn pt_2(input: String) -> Int {
  solve(input, 14)
}

fn solve(input: String, window_size: Int) -> Int {
  let length = string.length(input)

  assert Ok(index) =
    list.range(1, length)
    |> list.zip(string.to_graphemes(input))
    |> list.window(window_size)
    |> list.find(fn(chars_with_index) {
      let nb_of_different_chars =
        chars_with_index
        |> list.map(fn(char_with_index) { char_with_index.1 })
        |> set.from_list()
        |> set.size()

      nb_of_different_chars == window_size
    })
    |> result.map(list.reverse)
    |> result.then(list.first)
    |> result.map(fn(char_with_index) { char_with_index.0 })

  index
}
