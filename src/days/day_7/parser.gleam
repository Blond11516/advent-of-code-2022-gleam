import gleam/string
import gleam/list
import gleam/int

pub type File {
  File(name: String, size: Int)
  Dir(name: String)
}

pub type Command {
  CdRoot
  CdUp
  CdDown(dir: String)
  Ls(files: List(File))
}

pub fn parse(input: String) -> List(Command) {
  input
  |> string.drop_left(2)
  |> string.split("\n$ ")
  |> list.map(string.split(_, "\n"))
  |> list.map(parse_block)
}

fn parse_block(block: List(String)) -> Command {
  case block {
    ["cd /"] -> CdRoot
    ["cd .."] -> CdUp
    ["cd " <> dir] -> CdDown(dir)
    ["ls", ..raw_files] ->
      raw_files
      |> list.map(parse_file)
      |> Ls()
  }
}

fn parse_file(input: String) -> File {
  case input {
    "dir " <> dir -> Dir(name: dir)
    raw_file -> {
      let [raw_size, name] = string.split(raw_file, " ")
      assert Ok(size) = int.parse(raw_size)
      File(name: name, size: size)
    }
  }
}
