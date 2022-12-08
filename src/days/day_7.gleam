import gleam/map
import gleam/list
import gleam/int
import days/day_7/parser
import days/day_7/file_walker

pub fn pt_1(input: String) -> Int {
  input
  |> parser.parse()
  |> file_walker.walk()
  |> calculate_directory_sizes()
  |> map.to_list()
  |> list.filter_map(fn(dir_size) {
    case dir_size.1 <= 100000 {
      True -> Ok(dir_size.1)
      False -> Error(Nil)
    }
  })
  |> int.sum()
}

pub fn pt_2(input: String) -> Int {
  let dir_sizes =
    input
    |> parser.parse()
    |> file_walker.walk()
    |> calculate_directory_sizes()

  assert Ok(total_space_used) = map.get(dir_sizes, [""])

  let size_to_free = total_space_used - 40000000

  assert Ok(size_of_dir_to_delete) =
    dir_sizes
    |> map.to_list()
    |> list.filter_map(fn(dir_size) {
      case dir_size.1 >= size_to_free {
        True -> Ok(dir_size.1)
        False -> Error(Nil)
      }
    })
    |> list.sort(int.compare)
    |> list.first()

  size_of_dir_to_delete
}

fn calculate_directory_sizes(
  fs: file_walker.FileSystem,
) -> map.Map(List(String), Int) {
  map.map_values(fs, fn(dir, _) { calculate_directory_size(dir, fs) })
}

fn calculate_directory_size(
  dir: List(String),
  fs: file_walker.FileSystem,
) -> Int {
  assert Ok(dir_contents) = map.get(fs, dir)

  dir_contents
  |> list.filter(fn(x) {
    case x {
      parser.Dir(_) -> True
      parser.File(_, _) -> False
    }
  })
  |> list.map(fn(sub_dir) {
    assert parser.Dir(name) = sub_dir
    calculate_directory_size([name, ..dir], fs)
  })
  |> int.sum()
  |> int.add(calculate_size_of_files_in(dir, fs))
}

fn calculate_size_of_files_in(
  dir: List(String),
  fs: file_walker.FileSystem,
) -> Int {
  assert Ok(dir_contents) = map.get(fs, dir)

  dir_contents
  |> list.filter(fn(x) {
    case x {
      parser.Dir(_) -> False
      parser.File(_, _) -> True
    }
  })
  |> list.map(fn(file) {
    assert parser.File(_, size: size) = file
    size
  })
  |> int.sum()
}
