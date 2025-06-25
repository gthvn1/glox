import gleam/int
import gleam/list
import interpreter/token as t

pub type ScannerError {
  ScannerError(code: Int, reason: String)
}

pub type ScannerState {
  ScannerState(
    input: String,
    tokens: List(t.Token),
    line: Int,
    err: ScannerError,
  )
}

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

    Error(e) -> handle_error(e, scan_state)
  }
}

/// Returns the list of tokens found as a list of string
///
pub fn tokenize(input: String) -> #(List(t.Token), ScannerError) {
  let init_state = ScannerState(input, [], 1, ScannerError(0, ""))
  let ScannerState(_, toks, _, err) = scan_tokens(init_state)
  #(toks, err)
}

fn handle_error(e: t.TokenError, scan_state: ScannerState) -> ScannerState {
  case e {
    t.Unknown(#(c, _, line)) ->
      ScannerState(
        ..scan_state,
        tokens: scan_state.tokens |> list.reverse,
        err: ScannerError(
          65,
          "Unknown " <> c <> " at " <> line |> int.to_string,
        ),
      )
    t.UnterminatedString(line) ->
      ScannerState(
        ..scan_state,
        tokens: scan_state.tokens |> list.reverse,
        err: ScannerError(
          65,
          "Unterminated string at " <> line |> int.to_string,
        ),
      )
    _ ->
      ScannerState(
        ..scan_state,
        tokens: scan_state.tokens |> list.reverse,
        err: ScannerError(65, "TODO: describe the error"),
      )
  }
}
