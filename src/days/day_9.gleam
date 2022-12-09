import gleam/string
import gleam/int
import gleam/list
import gleam/set

pub fn pt_1(input: String) {
  input
  |> parse()
  |> count_visited_positions2(initial_state(2))
}

pub fn pt_2(input: String) {
  input
  |> parse()
  |> count_visited_positions2(initial_state(10))
}

type Position {
  Position(x: Int, y: Int)
}

type Direction {
  Up
  Down
  Left
  Right
}

type Motion {
  Motion(direction: Direction, distance: Int)
}

type TraversalState {
  TraversalState(visited_positions: set.Set(Position), knots: List(Position))
}

fn count_visited_positions2(
  motions: List(Motion),
  initial_state: TraversalState,
) -> Int {
  let TraversalState(visited_positions, _) =
    list.fold(motions, initial_state, apply_motion)

  set.size(visited_positions)
}

fn apply_motion(
  traversal_state: TraversalState,
  motion: Motion,
) -> TraversalState {
  list.range(1, motion.distance)
  |> list.fold(
    traversal_state,
    fn(state, _) { move_rope(state, motion.direction) },
  )
}

fn move_rope(
  traversal_state: TraversalState,
  direction: Direction,
) -> TraversalState {
  assert Ok(head) = list.first(traversal_state.knots)
  let head = move_head(direction, head)

  let reversed_moved_knots =
    traversal_state.knots
    |> list.drop(1)
    |> list.fold([head], move_follower_knot)

  assert Ok(last) = list.first(reversed_moved_knots)

  let visited_positions = set.insert(traversal_state.visited_positions, last)

  TraversalState(
    visited_positions: visited_positions,
    knots: list.reverse(reversed_moved_knots),
  )
}

fn move_follower_knot(moved_knots, cur_knot) {
  assert Ok(cur_head) = list.first(moved_knots)

  let tail = follow(this: cur_knot, follows: cur_head)

  [tail, ..moved_knots]
}

fn move_head(direction, head) -> Position {
  case direction, head {
    Up, Position(x, y) -> Position(x, y - 1)
    Down, Position(x, y) -> Position(x, y + 1)
    Left, Position(x, y) -> Position(x - 1, y)
    Right, Position(x, y) -> Position(x + 1, y)
  }
}

fn follow(this tail: Position, follows head: Position) -> Position {
  case are_direct_neighbors(head, tail), head, tail {
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x < head_x && tail_y == head_y ->
      Position(tail_x + 1, tail_y)
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x > head_x && tail_y == head_y ->
      Position(tail_x - 1, tail_y)
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x == head_x && tail_y < head_y ->
      Position(tail_x, tail_y + 1)
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x == head_x && tail_y > head_y ->
      Position(tail_x, tail_y - 1)
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x < head_x && tail_y < head_y ->
      Position(tail_x + 1, tail_y + 1)
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x < head_x && tail_y > head_y ->
      Position(tail_x + 1, tail_y - 1)
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x > head_x && tail_y < head_y ->
      Position(tail_x - 1, tail_y + 1)
    False, Position(head_x, head_y), Position(tail_x, tail_y) if tail_x > head_x && tail_y > head_y ->
      Position(tail_x - 1, tail_y - 1)
    _, _, tail -> tail
  }
}

fn are_direct_neighbors(a: Position, b: Position) -> Bool {
  let are_neighbors_horizontally = b.x <= a.x + 1 && b.x >= a.x - 1
  let are_neighbors_vertically = b.y <= a.y + 1 && b.y >= a.y - 1

  are_neighbors_horizontally && are_neighbors_vertically
}

fn initial_state(number_of_knots) {
  let initial_position = Position(0, 0)
  let initial_knots =
    list.range(1, number_of_knots)
    |> list.map(fn(_) { initial_position })

  TraversalState(set.from_list([initial_position]), initial_knots)
}

fn parse(input: String) -> List(Motion) {
  input
  |> string.split("\n")
  |> list.map(fn(raw_motion) {
    let #(direction, raw_count) = case raw_motion {
      "U " <> count -> #(Up, count)
      "D " <> count -> #(Down, count)
      "L " <> count -> #(Left, count)
      "R " <> count -> #(Right, count)
    }

    assert Ok(count) = int.parse(raw_count)

    Motion(direction, count)
  })
}
