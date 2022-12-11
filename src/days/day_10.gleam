import gleam/string
import gleam/int
import gleam/list
import gleam/map
import gleam/io

pub fn pt_1(input: String) {
  input
  |> parse()
  |> calculate_sum_of_signal_strengths()
}

pub fn pt_2(input: String) {
  input
  |> parse()
  |> run_with_crt()
  |> draw()
}

type Command {
  Noop
  Addx(value: Int)
}

type CpuState {
  CpuState(cycle_idx: Int, x: Int)
}

type Position {
  Position(row: Int, col: Int)
}

type Display =
  map.Map(Position, Bool)

type CrtState {
  CrtState(display: Display, next_pixel: Position)
}

fn calculate_sum_of_signal_strengths(commands: List(Command)) {
  commands
  |> list.take(220)
  |> run_with_signal_strength_calculator()
}

fn run_with_signal_strength_calculator(commands: List(Command)) -> Int {
  let initial_cpu_state = CpuState(0, 1)

  let #(_, signal_strength) =
    list.fold(
      commands,
      #(initial_cpu_state, 0),
      fn(state, command) {
        execute_cycle(state, command, signal_strength_cycle_handler)
      },
    )

  signal_strength
}

fn signal_strength_cycle_handler(
  cpu_state: CpuState,
  signal_strength: Int,
) -> Int {
  let cycle_number = cpu_state.cycle_idx + 1
  let cycle_signal_strength = case int.modulo(cycle_number - 20, 40) {
    Ok(0) -> cycle_number * cpu_state.x
    _ -> 0
  }
  cycle_signal_strength + signal_strength
}

fn execute_cycle(
  state: #(CpuState, a),
  command: Command,
  cycle_handler: fn(CpuState, a) -> a,
) -> #(CpuState, a) {
  let #(cpu_state, handler_state) = state

  let handler_state = cycle_handler(cpu_state, handler_state)
  let cpu_state = update_cpu(cpu_state, command)

  #(cpu_state, handler_state)
}

fn update_cpu(cpu_state: CpuState, command: Command) -> CpuState {
  let x = case command {
    Addx(value) -> cpu_state.x + value
    Noop -> cpu_state.x
  }

  CpuState(cycle_idx: cpu_state.cycle_idx + 1, x: x)
}

fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.flat_map(parse_command)
}

fn parse_command(input: String) {
  case input {
    "noop" -> [Noop]
    "addx " <> value -> {
      assert Ok(value) = int.parse(value)
      [Noop, Addx(value)]
    }
  }
}

// part 2

fn draw(crt_state: CrtState) -> Nil {
  list.range(0, 5)
  |> list.each(draw_row(_, crt_state.display))

  Nil
}

fn draw_row(row: Int, display: Display) -> Nil {
  list.range(0, 39)
  |> list.map(fn(col) {
    assert Ok(is_lit) = map.get(display, Position(row, col))
    case is_lit {
      True -> "#"
      False -> "."
    }
  })
  |> string.join("")
  |> io.println()

  Nil
}

fn run_with_crt(commands: List(Command)) -> CrtState {
  let initial_cpu_state = CpuState(0, 1)

  let #(_, crt_state) =
    list.fold(
      commands,
      #(initial_cpu_state, get_initial_crt_state()),
      fn(state, command) { execute_cycle(state, command, crt_cycle_handler) },
    )

  crt_state
}

fn get_initial_crt_state() -> CrtState {
  let initial_display =
    list.range(0, 39)
    |> list.flat_map(fn(col) {
      list.range(0, 5)
      |> list.map(fn(row) { Position(row, col) })
    })
    |> list.map(fn(position) { #(position, False) })
    |> map.from_list()

  CrtState(display: initial_display, next_pixel: Position(0, 0))
}

fn crt_cycle_handler(cpu_state: CpuState, crt_state: CrtState) -> CrtState {
  let sprite_position = cpu_state.x
  let current_col = crt_state.next_pixel.col
  let is_current_pixel_lit =
    current_col >= sprite_position - 1 && current_col <= sprite_position + 1
  let display =
    map.insert(crt_state.display, crt_state.next_pixel, is_current_pixel_lit)

  let next_pixel = case crt_state.next_pixel {
    Position(row, col) if col == 39 -> {
      assert Ok(row) = int.modulo(row + 1, 6)
      Position(row, 0)
    }
    Position(row, col) -> Position(row, col + 1)
  }

  CrtState(display: display, next_pixel: next_pixel)
}
