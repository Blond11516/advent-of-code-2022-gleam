import gleam/string
import gleam/map
import gleam/list
import gleam/int
import days/day_5/stack
import days/day_5/crate_state

type Crate =
  String

type TransferNCratesFn =
  fn(stack.Stack(Crate), stack.Stack(Crate), Int) ->
    #(stack.Stack(Crate), stack.Stack(Crate))

pub fn pt_1(input: String) -> String {
  solve(input, transfer_n_crates_1)
}

pub fn pt_2(input: String) -> String {
  solve(input, transfer_n_crates_2)
}

fn solve(input: String, transfer_n_crates: TransferNCratesFn) -> String {
  let [initial_state_input, procedure_input] = string.split(input, "\n\n")
  let initial_state = crate_state.parse(initial_state_input)
  let procedure = parse_procedure(procedure_input)

  initial_state
  |> reorganize_crates(procedure, transfer_n_crates)
  |> map.values()
  |> list.map(fn(stack: stack.Stack(Crate)) {
    assert Ok(#(_, head)) = stack.pop(stack)
    head
  })
  |> string.join("")
}

type Move {
  Move(count: Int, from: Int, to: Int)
}

type Procedure =
  List(Move)

type CratesState =
  map.Map(Int, stack.Stack(Crate))

fn reorganize_crates(
  initial_state: CratesState,
  procedure: Procedure,
  transfer_n_crates: TransferNCratesFn,
) -> CratesState {
  list.fold(
    procedure,
    initial_state,
    fn(acc, val) { apply_move(acc, val, transfer_n_crates) },
  )
}

fn apply_move(
  state: CratesState,
  move: Move,
  transfer_n_crates: TransferNCratesFn,
) -> CratesState {
  assert Ok(from_stack) = map.get(state, move.from)
  assert Ok(to_stack) = map.get(state, move.to)

  let #(from_stack, to_stack) =
    transfer_n_crates(from_stack, to_stack, move.count)

  state
  |> map.insert(move.from, from_stack)
  |> map.insert(move.to, to_stack)
}

fn transfer_n_crates_1(
  from initial_from: stack.Stack(Crate),
  to initial_to: stack.Stack(Crate),
  count: Int,
) -> #(stack.Stack(Crate), stack.Stack(Crate)) {
  list.range(1, count)
  |> list.fold(
    #(initial_from, initial_to),
    fn(stacks: #(stack.Stack(Crate), stack.Stack(Crate)), _: Int) {
      let #(from_stack, to_stack) = stacks
      transfer_crate(from: from_stack, to: to_stack)
    },
  )
}

fn transfer_crate(
  from from: stack.Stack(Crate),
  to to: stack.Stack(Crate),
) -> #(stack.Stack(Crate), stack.Stack(Crate)) {
  assert Ok(#(from, crate)) = stack.pop(from)
  let to = stack.push(to, crate)
  #(from, to)
}

fn parse_procedure(input: String) -> Procedure {
  input
  |> string.split("\n")
  |> list.map(parse_procedure_line)
}

fn parse_procedure_line(input: String) -> Move {
  let [_, raw_count, _, raw_from, _, raw_to] = string.split(input, " ")
  assert Ok(count) = int.parse(raw_count)
  assert Ok(from) = int.parse(raw_from)
  assert Ok(to) = int.parse(raw_to)
  Move(count: count, from: from, to: to)
}

// Part 2

fn transfer_n_crates_2(
  from initial_from: stack.Stack(Crate),
  to initial_to: stack.Stack(Crate),
  count: Int,
) -> #(stack.Stack(Crate), stack.Stack(Crate)) {
  let #(from, popped) = stack.pop_multiple(initial_from, count)
  let to = stack.push_multiple(initial_to, popped)

  #(from, to)
}
