import gleam/string
import gleam/list
import gleam/int

pub fn pt_1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_round)
  |> list.map(calculate_round_score)
  |> sum()
}

pub fn pt_2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(parse_round_part_2)
  |> list.map(get_my_shape)
  |> list.map(calculate_round_score)
  |> sum()
}

type Shape {
  Rock
  Paper
  Scissors
}

type Round {
  Round(opponent_shape: Shape, my_shape: Shape)
}

type RoundResult {
  Win
  Loss
  Draw
}

fn calculate_round_score(round: Round) -> Int {
  get_shape_score(round.my_shape) + get_result_score(round)
}

fn get_shape_score(shape: Shape) -> Int {
  case shape {
    Rock -> 1
    Paper -> 2
    Scissors -> 3
  }
}

fn get_result_score(round: Round) -> Int {
  let result = case round {
    Round(my_shape: Rock, opponent_shape: Scissors) -> Win
    Round(my_shape: Paper, opponent_shape: Rock) -> Win
    Round(my_shape: Scissors, opponent_shape: Paper) -> Win
    Round(my_shape: Paper, opponent_shape: Scissors) -> Loss
    Round(my_shape: Scissors, opponent_shape: Rock) -> Loss
    Round(my_shape: Rock, opponent_shape: Paper) -> Loss
    _ -> Draw
  }

  case result {
    Win -> 6
    Draw -> 3
    Loss -> 0
  }
}

fn parse_round(round_input: String) -> Round {
  let [opponent_raw_shape, my_raw_shape] = string.split(round_input, " ")

  let opponent_shape = parse_opponent_shape(opponent_raw_shape)
  let my_shape = parse_my_shape(my_raw_shape)

  Round(my_shape: my_shape, opponent_shape: opponent_shape)
}

fn parse_opponent_shape(raw_shape: String) -> Shape {
  case raw_shape {
    "A" -> Rock
    "B" -> Paper
    "C" -> Scissors
  }
}

fn parse_my_shape(raw_shape: String) -> Shape {
  case raw_shape {
    "X" -> Rock
    "Y" -> Paper
    "Z" -> Scissors
  }
}

fn sum(nums: List(Int)) -> Int {
  list.fold(nums, 0, int.add)
}

// Part 2

fn parse_round_part_2(round_input: String) -> #(Shape, RoundResult) {
  let [opponent_raw_shape, raw_result] = string.split(round_input, " ")

  let opponent_shape = parse_opponent_shape(opponent_raw_shape)
  let result = parse_result(raw_result)

  #(opponent_shape, result)
}

fn get_my_shape(hint: #(Shape, RoundResult)) -> Round {
  let my_shape = case hint {
    #(Rock, Loss) -> Scissors
    #(Rock, Win) -> Paper
    #(Paper, Loss) -> Rock
    #(Paper, Win) -> Scissors
    #(Scissors, Loss) -> Paper
    #(Scissors, Win) -> Rock
    #(opponent_shape, Draw) -> opponent_shape
  }

  Round(my_shape: my_shape, opponent_shape: hint.0)
}

fn parse_result(raw_result: String) -> RoundResult {
  case raw_result {
    "X" -> Loss
    "Y" -> Draw
    "Z" -> Win
  }
}
