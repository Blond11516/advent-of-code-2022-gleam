import gleam/string
import gleam/list.{Continue, Stop}
import gleam/map.{Map}
import gleam/option.{None, Option, Some}
import gleam/set.{Set}
import gleam/int
import gleam/result
import gleam/iterator

pub fn pt_1(input: String) {
  let #(height_map, start, end) =
    input
    |> parse()

  let width = get_map_dimension(height_map, fn(pos: Pos) { pos.row })
  let height = get_map_dimension(height_map, fn(pos: Pos) { pos.col })

  find_shortest_distance(height_map, [start], end, width, height)
}

pub fn pt_2(input: String) {
  let #(height_map, _, end) =
    input
    |> parse()

  let width = get_map_dimension(height_map, fn(pos: Pos) { pos.row })
  let height = get_map_dimension(height_map, fn(pos: Pos) { pos.col })

  let <<a_height:int>> = <<"a":utf8>>

  height_map
  |> map.to_list()
  |> list.filter(fn(cur) { cur.1 == a_height })
  |> list.map(fn(cur) { cur.0 })
  |> find_shortest_distance(height_map, _, end, width, height)
}

type Pos {
  Pos(row: Int, col: Int)
}

type HeightMap =
  Map(Pos, Int)

type AStar {
  AStar(open: Set(Pos), closed: Set(Pos), g: Map(Pos, Int))
}

fn get_map_dimension(height_map, get_pos_dimension) -> Int {
  assert Ok(dimension) =
    height_map
    |> map.to_list()
    |> list.map(fn(cur) {
      let pos = cur.0
      get_pos_dimension(pos)
    })
    |> list.reduce(int.max)
    |> result.map(int.add(_, 1))

  dimension
}

fn h(pos: Pos, height_map: HeightMap) -> Int {
  assert Ok(pos_height) = map.get(height_map, pos)
  let <<end_height:int>> = <<"z":utf8>>
  end_height - pos_height
}

fn find_shortest_distance(
  height_map: HeightMap,
  starts: List(Pos),
  end: Pos,
  width: Int,
  height: Int,
) -> Int {
  let #(_, cost) = {
    use
      a_star,
      _
    <- iterator.fold_until(
        iterator.repeat(Nil),
        #(
          AStar(
            open: set.from_list(starts),
            closed: set.new(),
            g: starts
            |> list.map(fn(x) { #(x, 0) })
            |> map.from_list(),
          ),
          0,
        ),
      )
    let #(a_star, _) = a_star
    let m =
      a_star.open
      |> set.to_list()
      |> list.sort(fn(a, b) {
        assert Ok(a_g) = map.get(a_star.g, a)
        assert Ok(b_g) = map.get(a_star.g, b)
        let a_h = h(a, height_map)
        let b_h = h(b, height_map)
        let a_f = a_g + a_h
        let b_f = b_g + b_h
        int.compare(a_f, b_f)
      })
      |> list.first()

    case m {
      Error(Nil) -> Stop(#(a_star, 1000))
      Ok(m) -> {
        assert Ok(m_g) = map.get(a_star.g, m)
        case m == end {
          True -> Stop(#(a_star, m_g))
          False -> {
            let open = set.delete(a_star.open, m)
            let closed = set.insert(a_star.closed, m)
            let a_star = {
              let neighbors = find_valid_neighbors(height_map, m, width, height)
              use
                a_star,
                neighbor
              <- list.fold(
                  neighbors,
                  AStar(..a_star, open: open, closed: closed),
                )
              case set.contains(a_star.closed, neighbor) {
                True -> a_star
                False -> {
                  let cost = m_g + 1
                  let open =
                    maybe_remove_open_or_closed(
                      a_star.open,
                      neighbor,
                      cost,
                      a_star.g,
                    )
                  let closed =
                    maybe_remove_open_or_closed(
                      a_star.closed,
                      neighbor,
                      cost,
                      a_star.g,
                    )
                  case
                    set.contains(open, neighbor),
                    set.contains(closed, neighbor)
                  {
                    False, False -> {
                      let open = set.insert(open, neighbor)
                      let g = map.insert(a_star.g, neighbor, cost)
                      AStar(open: open, closed: closed, g: g)
                    }
                    _, _ -> AStar(..a_star, open: open, closed: closed)
                  }
                }
              }
            }
            Continue(#(a_star, 0))
          }
        }
      }
    }
  }

  cost
}

fn maybe_remove_open_or_closed(
  open_or_closed: Set(Pos),
  n: Pos,
  cost: Int,
  g: Map(Pos, Int),
) -> Set(Pos) {
  case set.contains(open_or_closed, n) {
    True -> {
      assert Ok(n_g) = map.get(g, n)
      case cost < n_g {
        True -> set.delete(open_or_closed, n)
        False -> open_or_closed
      }
    }
    False -> open_or_closed
  }
}

fn find_valid_neighbors(
  height_map: HeightMap,
  pos: Pos,
  width: Int,
  height: Int,
) -> List(Pos) {
  assert Ok(pos_height) = map.get(height_map, pos)

  [#(-1, 0), #(1, 0), #(0, -1), #(0, 1)]
  |> list.map(fn(diff) { Pos(row: pos.row + diff.0, col: pos.col + diff.1) })
  |> list.filter(fn(pos) {
    pos.row >= 0 && pos.row < width && pos.col >= 0 && pos.col < height
  })
  |> list.filter(fn(pos) {
    assert Ok(neighbor_height) = map.get(height_map, pos)
    neighbor_height <= pos_height + 1
  })
}

fn parse(input: String) -> #(HeightMap, Pos, Pos) {
  let parsed_lines =
    input
    |> string.split("\n")
    |> list.index_map(fn(index, line) { parse_line(line, index) })

  assert Ok(Some(start)) =
    parsed_lines
    |> list.map(fn(line) { line.1 })
    |> list.find(option.is_some)

  assert Ok(Some(end)) =
    parsed_lines
    |> list.map(fn(line) { line.2 })
    |> list.find(option.is_some)

  let height_map =
    list.fold(parsed_lines, map.new(), fn(acc, line) { map.merge(acc, line.0) })

  #(height_map, start, end)
}

fn parse_line(input: String, row: Int) -> #(HeightMap, Option(Pos), Option(Pos)) {
  let #(heights, start, end) = {
    let graphemes = string.to_graphemes(input)
    use acc, char, index <- list.index_fold(graphemes, #([], None, None))
    let pos = Pos(row: row, col: index)
    case char {
      "S" -> {
        let <<char:int>> = <<"a":utf8>>
        #([#(pos, char), ..acc.0], Some(pos), acc.2)
      }
      "E" -> {
        let <<char:int>> = <<"z":utf8>>
        #([#(pos, char), ..acc.0], acc.1, Some(pos))
      }
      char -> {
        let <<char:int>> = <<char:utf8>>
        #([#(pos, char), ..acc.0], acc.1, acc.2)
      }
    }
  }
  #(map.from_list(heights), start, end)
}
