import gleam/int
import gleam/list
import gleam/string

fn rot13(input: UtfCodepoint) -> UtfCodepoint {
  let assert [low_a, low_z] = string.to_utf_codepoints("az")
  let assert [upper_a, upper_z] = string.to_utf_codepoints("AZ")

  let low_a_code = string.utf_codepoint_to_int(low_a)
  let low_z_code = string.utf_codepoint_to_int(low_z)
  let upper_a_code = string.utf_codepoint_to_int(upper_a)
  let upper_z_code = string.utf_codepoint_to_int(upper_z)

  let rotate = fn(char, base) {
    let assert Ok(v) = int.modulo(char - base + 13, 26)
    v + base
  }

  let cipher_code = case string.utf_codepoint_to_int(input) {
    c if c >= low_a_code && c <= low_z_code -> rotate(c, low_a_code)
    c if c >= upper_a_code && c <= upper_z_code -> rotate(c, upper_a_code)
    c -> c
  }

  let assert Ok(res) = string.utf_codepoint(cipher_code)
  res
}

pub fn crypt(input: String) -> String {
  input
  |> string.to_utf_codepoints
  |> list.map(rot13)
  |> string.from_utf_codepoints
}
