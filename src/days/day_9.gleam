import gleam/string
import gleam/int
import gleam/list
import gleam/set

pub fn pt_1(input: String) {
  input
  |> parse()
  |> count_visited_positions()
}

pub fn pt_2(_input: String) {
  1
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
  TraversalState(
    visited_positions: set.Set(Position),
    head: Position,
    tail: Position,
  )
}

fn count_visited_positions(motions: List(Motion)) -> Int {
  let TraversalState(visited_positions, _, _) =
    list.fold(
      motions,
      TraversalState(
        set.from_list([Position(0, 0)]),
        Position(0, 0),
        Position(0, 0),
      ),
      apply_motion,
    )

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
  let head = case direction, traversal_state.head {
    Up, Position(x, y) -> Position(x, y - 1)
    Down, Position(x, y) -> Position(x, y + 1)
    Left, Position(x, y) -> Position(x - 1, y)
    Right, Position(x, y) -> Position(x + 1, y)
  }

  let tail = case
    are_direct_neighbors(head, traversal_state.tail),
    head,
    traversal_state.tail
  {
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

  let visited_positions = set.insert(traversal_state.visited_positions, tail)

  TraversalState(visited_positions, head, tail)
}

fn are_direct_neighbors(a: Position, b: Position) -> Bool {
  let are_neighbors_horizontally = b.x <= a.x + 1 && b.x >= a.x - 1
  let are_neighbors_vertically = b.y <= a.y + 1 && b.y >= a.y - 1

  are_neighbors_horizontally && are_neighbors_vertically
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
