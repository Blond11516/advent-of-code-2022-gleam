import gleam/string
import gleam/list
import gleam/int
import gleam/map
import gleam/result
import gleam/option

pub fn pt_1(input: String) {
  let monkeys =
    input
    |> parse()
    |> map.from_list()

  let #(_, inspect_counts) =
    list.range(1, 20)
    |> list.fold(#(monkeys, map.new()), run_round)

  inspect_counts
  |> map.values()
  |> list.sort(int.compare)
  |> list.reverse()
  |> list.take(2)
  |> int.product()
}

pub fn pt_2(input: String) {
  let monkeys =
    input
    |> parse()
    |> map.from_list()

  let #(_, inspect_counts) =
    list.range(1, 10000)
    |> list.fold(#(monkeys, map.new()), run_round2)

  inspect_counts
  |> map.values()
  |> list.sort(int.compare)
  |> list.reverse()
  |> list.take(2)
  |> int.product()
}

pub type Value {
  Old
  Const(val: Int)
}

pub type Operation {
  Operation(operator: fn(Int, Int) -> Int, value: Value)
}

pub type Test {
  Test(value: Int, true_id: Int, false_id: Int)
}

pub type Monkey {
  Monkey(items: List(Int), operation: Operation, test: Test)
}

fn run_round(acc: #(map.Map(Int, Monkey), map.Map(Int, Int)), _) {
  let #(monkeys, inspect_counts) = acc

  monkeys
  |> map.keys()
  |> list.sort(int.compare)
  |> list.fold(
    #(monkeys, inspect_counts),
    fn(acc, current_id) {
      let #(monkeys, inspect_counts) = acc
      let inspect_counts =
        update_inspect_counts(monkeys, inspect_counts, current_id)
      let monkeys = monkey_turn(monkeys, current_id)
      #(monkeys, inspect_counts)
    },
  )
}

fn update_inspect_counts(
  monkeys: map.Map(Int, Monkey),
  inspect_counts,
  monkey_id,
) {
  assert Ok(monkey) = map.get(monkeys, monkey_id)
  map.update(
    inspect_counts,
    monkey_id,
    fn(count) {
      count
      |> option.unwrap(0)
      |> int.add(list.length(monkey.items))
    },
  )
}

fn monkey_turn(monkeys, current_id) {
  assert Ok(cur_monkey) = map.get(monkeys, current_id)

  cur_monkey.items
  |> list.fold(
    monkeys,
    fn(monkeys, item) {
      let item = apply_operation(cur_monkey.operation, item)
      assert Ok(item) = int.floor_divide(item, 3)

      let throw_id = case
        item
        |> int.modulo(cur_monkey.test.value)
        |> result.unwrap(0) == 0
      {
        True -> cur_monkey.test.true_id
        False -> cur_monkey.test.false_id
      }

      map.update(
        monkeys,
        throw_id,
        fn(thrown_monkey) {
          assert option.Some(thrown_monkey) = thrown_monkey
          Monkey(
            ..thrown_monkey,
            items: list.append(thrown_monkey.items, [item]),
          )
        },
      )
    },
  )
  |> map.update(
    current_id,
    fn(monkey) {
      assert option.Some(monkey) = monkey
      Monkey(..monkey, items: [])
    },
  )
}

fn apply_operation(operation, item) {
  let value = case operation.value {
    Old -> item
    Const(value) -> value
  }

  operation.operator(item, value)
}

fn parse(input: String) {
  input
  |> string.split("\n\n")
  |> list.map(parse_monkey)
}

fn parse_monkey(input: String) {
  let [
    monkey_id,
    starting_items,
    operation,
    test,
    true_monkey_id,
    false_monkey_id,
  ] =
    input
    |> string.split("\n")
    |> list.map(string.trim)

  let "Monkey " <> monkey_id = monkey_id
  assert Ok(monkey_id) =
    monkey_id
    |> string.drop_right(1)
    |> int.parse()

  let "Starting items: " <> starting_items = starting_items
  let starting_items =
    starting_items
    |> string.split(", ")
    |> list.map(fn(worry) {
      assert Ok(worry) = int.parse(worry)
      worry
    })

  let "Operation: new = old " <> operation = operation
  let #(operator, operation_value) = case operation {
    "* old" -> #(int.multiply, Old)
    "* " <> value -> {
      assert Ok(value) = int.parse(value)
      #(int.multiply, Const(value))
    }
    "+ old" -> #(int.add, Old)
    "+ " <> value -> {
      assert Ok(value) = int.parse(value)
      #(int.add, Const(value))
    }
  }

  let "Test: divisible by " <> test = test
  assert Ok(test) = int.parse(test)

  let "If true: throw to monkey " <> true_monkey_id = true_monkey_id
  assert Ok(true_monkey_id) = int.parse(true_monkey_id)

  let "If false: throw to monkey " <> false_monkey_id = false_monkey_id
  assert Ok(false_monkey_id) = int.parse(false_monkey_id)

  #(
    monkey_id,
    Monkey(
      items: starting_items,
      operation: Operation(operator: operator, value: operation_value),
      test: Test(
        value: test,
        true_id: true_monkey_id,
        false_id: false_monkey_id,
      ),
    ),
  )
}

// part 2

fn run_round2(acc: #(map.Map(Int, Monkey), map.Map(Int, Int)), _) {
  let #(monkeys, inspect_counts) = acc

  monkeys
  |> map.keys()
  |> list.sort(int.compare)
  |> list.fold(
    #(monkeys, inspect_counts),
    fn(acc, current_id) {
      let #(monkeys, inspect_counts) = acc
      let inspect_counts =
        update_inspect_counts(monkeys, inspect_counts, current_id)
      let monkeys = monkey_turn2(monkeys, current_id)
      #(monkeys, inspect_counts)
    },
  )
}

const ppcm = 9699690

fn monkey_turn2(monkeys, current_id) {
  assert Ok(cur_monkey) = map.get(monkeys, current_id)

  cur_monkey.items
  |> list.fold(
    monkeys,
    fn(monkeys, item) {
      let item = apply_operation(cur_monkey.operation, item)
      assert Ok(item) = int.modulo(item, ppcm)

      let throw_id = case
        item
        |> int.modulo(cur_monkey.test.value)
        |> result.unwrap(0) == 0
      {
        True -> cur_monkey.test.true_id
        False -> cur_monkey.test.false_id
      }

      map.update(
        monkeys,
        throw_id,
        fn(thrown_monkey) {
          assert option.Some(thrown_monkey) = thrown_monkey
          Monkey(
            ..thrown_monkey,
            items: list.append(thrown_monkey.items, [item]),
          )
        },
      )
    },
  )
  |> map.update(
    current_id,
    fn(monkey) {
      assert option.Some(monkey) = monkey
      Monkey(..monkey, items: [])
    },
  )
}
