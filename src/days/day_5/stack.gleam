import gleam/list

pub opaque type Stack(a) {
  Stack(stack: List(a))
}

pub fn new() -> Stack(a) {
  Stack([])
}

pub fn from_list(vals: List(a)) -> Stack(a) {
  Stack(vals)
}

pub fn push(stack: Stack(a), val: a) -> Stack(a) {
  Stack([val, ..stack.stack])
}

pub fn pop(stack: Stack(a)) -> Result(#(Stack(a), a), Nil) {
  case stack.stack {
    [] -> Error(Nil)
    [head, ..rest] -> Ok(#(Stack(rest), head))
  }
}

pub fn push_multiple(stack: Stack(a), vals: List(a)) -> Stack(a) {
  vals
  |> list.append(stack.stack)
  |> Stack()
}

pub fn pop_multiple(stack: Stack(a), count: Int) -> #(Stack(a), List(a)) {
  let #(popped, rest) = list.split(stack.stack, count)

  #(Stack(rest), popped)
}
