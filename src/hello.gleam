import gleam/int
import gleam/list
import gleam/string

fn rot13_char(char: Int) -> Int {
  let assert [low_a, ..] = string.to_utf_codepoints("a")
  let assert [low_z, ..] = string.to_utf_codepoints("z")
  let assert [upper_a, ..] = string.to_utf_codepoints("A")
  let assert [upper_z, ..] = string.to_utf_codepoints("Z")

  let low_a = string.utf_codepoint_to_int(low_a)
  let low_z = string.utf_codepoint_to_int(low_z)
  let upper_a = string.utf_codepoint_to_int(upper_a)
  let upper_z = string.utf_codepoint_to_int(upper_z)

  case char {
    char if char >= low_a && char <= low_z -> {
      let assert Ok(v) = int.modulo(char - low_a + 13, 26)
      v + low_a
    }
    char if char >= upper_a && char <= upper_z -> {
      let assert Ok(v) = int.modulo(char - upper_a + 13, 26)
      v + upper_a
    }
    _ -> char
  }
}

pub fn rot13(input: String) -> String {
  input
  |> string.to_utf_codepoints
  |> list.map(string.utf_codepoint_to_int)
  |> list.map(rot13_char)
  |> list.map(fn(x) {
    let assert Ok(v) = string.utf_codepoint(x)
    v
  })
  |> string.from_utf_codepoints
}

pub fn say_hello(name: String) -> String {
  "Hello " <> name <> "!"
}
