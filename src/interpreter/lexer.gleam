import gleam/list
import interpreter/token as t

pub type ScannerState {
  ScannerState(input: String, tokens: List(t.Token), line: Int, error_code: Int)
}

const scan_error: Int = 65

fn scan_tokens(scan_state: ScannerState) -> ScannerState {
  case t.read_token(scan_state.input, scan_state.line) {
    Ok(#(t.Token(t.Eof, _, _, _) as tok, _)) ->
      // We reach the EOF so just return our list of tokens
      ScannerState(
        ..scan_state,
        tokens: [tok, ..scan_state.tokens] |> list.reverse,
      )

    Ok(#(tok, rest)) ->
      // We found a token. Add it to our list and continue with the next one
      scan_tokens(
        ScannerState(
          ..scan_state,
          input: rest,
          tokens: [tok, ..scan_state.tokens],
          line: tok.line,
        ),
      )

    Error(_) ->
      // When error is found just return with 65 error and the list of what we already have
      // TODO: manage the different kinds of errors
      ScannerState(
        ..scan_state,
        tokens: scan_state.tokens |> list.reverse,
        error_code: scan_error,
      )
  }
}

/// Returns the list of tokens found as a list of string
///
pub fn tokenize(input: String) -> #(List(t.Token), Int) {
  let init_state = ScannerState(input, [], 1, 0)
  let ScannerState(_, toks, _, error_code) = scan_tokens(init_state)
  #(toks, error_code)
}
