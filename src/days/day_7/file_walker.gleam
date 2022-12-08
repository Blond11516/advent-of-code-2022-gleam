import gleam/map
import gleam/list
import days/day_7/parser

pub type FileSystem =
  map.Map(List(String), List(parser.File))

type FileWalker {
  FileWalker(file_system: FileSystem, cwd: List(String))
}

pub fn walk(commands: List(parser.Command)) -> FileSystem {
  let walker =
    list.fold(
      commands,
      FileWalker(file_system: map.new(), cwd: []),
      interpret_command,
    )
  walker.file_system
}

fn interpret_command(walker: FileWalker, command: parser.Command) -> FileWalker {
  case command {
    parser.CdRoot -> FileWalker(file_system: walker.file_system, cwd: [""])
    parser.CdUp -> {
      assert Ok(cwd) = list.rest(walker.cwd)
      FileWalker(..walker, cwd: cwd)
    }
    parser.CdDown(dir) -> {
      let cwd = [dir, ..walker.cwd]
      FileWalker(..walker, cwd: cwd)
    }
    parser.Ls(files) -> {
      let file_system = map.insert(walker.file_system, walker.cwd, files)
      FileWalker(..walker, file_system: file_system)
    }
  }
}
