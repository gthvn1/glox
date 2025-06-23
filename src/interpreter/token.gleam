import gleam/string

pub type Token {
  Token(ty: TokenType, lexeme: String, literal: String, line: Int)
}

pub type TokenType {
  // Single character token
  Comma
  Dot
  Minus
  Plus
  Semicolon
  Slash
  Star
  LeftParen
  RightParen
  LeftBrace
  RightBrace
  Equal
  Bang
  Less
  Greater

  // More complex ones
  EqualEqual
  BangEqual
  LessEqual
  GreaterEqual

  String
  Number
  Identifier

  // Reserved words
  // False, Nil and True are reserved so use FFalse, NNil and TTrue
  And
  Class
  Else
  FFalse
  For
  Fun
  If
  NNil
  Or
  Print
  Return
  Super
  This
  TTrue
  Var
  While

  Eof
}

// This token is currently used in parser when we have an error
// with no token. It is more a placeholder.
// TODO: improve management of errors in parser...
pub type TokenError {
  Unknown(#(String, String, Int))
  UnterminatedString(Int)
  NotFound
}

pub fn to_string(tok: Token) -> String {
  ty_to_string(tok.ty) <> " " <> tok.lexeme <> " " <> tok.literal
}

/// Returns the token found at the beginning of a given string and
/// the rest of the string.
///
pub fn read_token(
  input: String,
  line: Int,
) -> Result(#(Token, String), TokenError) {
  case string.pop_grapheme(input) {
    Error(Nil) -> Ok(#(new(Eof, "", "null", line), ""))
    Ok(#(",", rest)) -> Ok(#(new(Comma, ",", "null", line), rest))
    Ok(#(".", rest)) -> Ok(#(new(Dot, ".", "null", line), rest))
    Ok(#("-", rest)) -> Ok(#(new(Minus, "-", "null", line), rest))
    Ok(#("+", rest)) -> Ok(#(new(Plus, "+", "null", line), rest))
    Ok(#(";", rest)) -> Ok(#(new(Semicolon, ";", "null", line), rest))
    Ok(#("*", rest)) -> Ok(#(new(Star, "*", "null", line), rest))
    Ok(#("(", rest)) -> Ok(#(new(LeftParen, "(", "null", line), rest))
    Ok(#(")", rest)) -> Ok(#(new(RightParen, ")", "null", line), rest))
    Ok(#("{", rest)) -> Ok(#(new(LeftBrace, "{", "null", line), rest))
    Ok(#("}", rest)) -> Ok(#(new(RightBrace, "}", "null", line), rest))
    Ok(#(" ", rest)) | Ok(#("\t", rest)) -> read_token(rest, line)
    Ok(#("\n", rest)) -> read_token(rest, line + 1)
    Ok(#("\"", rest)) -> {
      case split_at_quote(rest, line) {
        Ok(#(contents, rest, l)) ->
          Ok(#(new(String, "\"" <> contents <> "\"", contents, l), rest))
        Error(e) -> Error(e)
      }
    }
    Ok(#("/", rest)) -> {
      // We need to check if it is a comment
      case peek(rest) {
        Ok(Slash) -> read_token(skip_until_newline(rest), line + 1)
        _ -> Ok(#(new(Slash, "/", "null", line), rest))
      }
    }
    Ok(#("=", rest)) -> {
      // We need to check if there is another Equal
      case peek(rest) {
        Ok(Equal) -> {
          let assert Ok(#(_, rest)) = string.pop_grapheme(rest)
          Ok(#(new(EqualEqual, "==", "null", line), rest))
        }
        _ -> Ok(#(new(Equal, "=", "null", line), rest))
      }
    }
    Ok(#("!", rest)) -> {
      case peek(rest) {
        Ok(Equal) -> {
          let assert Ok(#(_, rest)) = string.pop_grapheme(rest)
          Ok(#(new(BangEqual, "!=", "null", line), rest))
        }
        _ -> Ok(#(new(Bang, "!", "null", line), rest))
      }
    }
    Ok(#("<", rest)) -> {
      case peek(rest) {
        Ok(Equal) -> {
          let assert Ok(#(_, rest)) = string.pop_grapheme(rest)
          Ok(#(new(LessEqual, "<=", "null", line), rest))
        }
        _ -> Ok(#(new(Less, "<", "null", line), rest))
      }
    }
    Ok(#(">", rest)) -> {
      case peek(rest) {
        Ok(Equal) -> {
          let assert Ok(#(_, rest)) = string.pop_grapheme(rest)
          Ok(#(new(GreaterEqual, ">=", "null", line), rest))
        }
        _ -> Ok(#(new(Greater, ">", "null", line), rest))
      }
    }

    Ok(#(c, rest)) -> {
      // Check if it is a number
      case starts_with_digit(c) {
        True -> {
          let #(lexeme, rest) = read_number(input)
          // Althought literal is represented as "42.0" the lexem
          // field will contain the integer's value without the dot.
          let literal = case string.contains(does: lexeme, contain: ".") {
            True -> lexeme |> trim_end_zeroes
            False -> lexeme <> ".0"
          }
          Ok(#(new(Number, lexeme, literal, line), rest))
        }
        False ->
          // If it is not a number check if it is an identifier
          case starts_with_alpha(c) {
            True -> {
              let #(lexeme, rest) = read_identifier(input)
              // Check if it is a reserved word
              case lexeme {
                "and" -> Ok(#(new(And, "and", "null", line), rest))
                "class" -> Ok(#(new(Class, "class", "null", line), rest))
                "else" -> Ok(#(new(Else, "else", "null", line), rest))
                "false" -> Ok(#(new(FFalse, "false", "null", line), rest))
                "for" -> Ok(#(new(For, "for", "null", line), rest))
                "fun" -> Ok(#(new(Fun, "fun", "null", line), rest))
                "if" -> Ok(#(new(If, "if", "null", line), rest))
                "nil" -> Ok(#(new(NNil, "nil", "null", line), rest))
                "or" -> Ok(#(new(Or, "or", "null", line), rest))
                "print" -> Ok(#(new(Print, "print", "null", line), rest))
                "return" -> Ok(#(new(Return, "return", "null", line), rest))
                "super" -> Ok(#(new(Super, "super", "null", line), rest))
                "this" -> Ok(#(new(This, "this", "null", line), rest))
                "true" -> Ok(#(new(TTrue, "true", "null", line), rest))
                "var" -> Ok(#(new(Var, "var", "null", line), rest))
                "while" -> Ok(#(new(While, "while", "null", line), rest))
                _ -> Ok(#(new(Identifier, lexeme, "null", line), rest))
              }
            }
            False -> Error(Unknown(#(c, rest, line)))
          }
      }
    }
  }
}

fn new(ty: TokenType, lexeme: String, literal: String, line: Int) -> Token {
  Token(ty, lexeme, literal, line)
}

/// Returns the string for a given token
///
fn ty_to_string(ty: TokenType) -> String {
  case ty {
    Comma -> "COMMA"
    Dot -> "DOT"
    Minus -> "MINUS"
    Plus -> "PLUS"
    Semicolon -> "SEMICOLON"
    Slash -> "SLASH"
    Star -> "STAR"
    LeftParen -> "LEFT_PAREN"
    RightParen -> "RIGHT_PAREN"
    LeftBrace -> "LEFT_BRACE"
    RightBrace -> "RIGHT_BRACE"
    Equal -> "EQUAL"
    Bang -> "BANG"
    Less -> "LESS"
    Greater -> "GREATER"
    EqualEqual -> "EQUAL_EQUAL"
    BangEqual -> "BANG_EQUAL"
    LessEqual -> "LESS_EQUAL"
    GreaterEqual -> "GREATER_EQUAL"
    String -> "STRING"
    Number -> "NUMBER"
    Identifier -> "IDENTIFIER"
    Eof -> "EOF"
    And -> "AND"
    Class -> "CLASS"
    Else -> "ELSE"
    FFalse -> "FALSE"
    For -> "FOR"
    Fun -> "FUN"
    If -> "IF"
    NNil -> "NIL"
    Or -> "OR"
    Print -> "PRINT"
    Return -> "RETURN"
    Super -> "SUPER"
    This -> "THIS"
    TTrue -> "TRUE"
    Var -> "VAR"
    While -> "WHILE"
  }
}

fn is_alpha(input: String) -> Bool {
  let alpha = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  case string.first(input) {
    Error(Nil) -> False
    Ok(c) -> string.contains(does: alpha, contain: c)
  }
}

fn is_digit(input: String) -> Bool {
  let digit = "0123456789"
  case string.first(input) {
    Error(Nil) -> False
    Ok(c) -> string.contains(does: digit, contain: c)
  }
}

fn is_alpha_numeric(input: String) -> Bool {
  is_alpha(input) || is_digit(input)
}

/// Return true if a string starts by an alpha.
/// In fact our is alpha makes sense for a string of one character
/// but it works for any size and just check the first character.
///
fn starts_with_alpha(input: String) -> Bool {
  is_alpha(input)
}

/// Return true if a string starts by a digit.
/// As for alpha it works on all size of strings
///
fn starts_with_digit(input: String) -> Bool {
  is_digit(input)
}

/// Split string given as parameter into two strings splitted when " is found.
/// If there is no " an error is returned. It also update the line number if
/// needed.
///
fn split_at_quote(
  input: String,
  line: Int,
) -> Result(#(String, String, Int), TokenError) {
  case split_at_quote_loop(input, "", line) {
    Ok(v) -> Ok(v)
    Error(Nil) -> Error(UnterminatedString(line))
  }
}

fn split_at_quote_loop(
  input: String,
  acc: String,
  line: Int,
) -> Result(#(String, String, Int), Nil) {
  case string.pop_grapheme(input) {
    Ok(#("\"", rest)) -> Ok(#(acc, rest, line))
    Ok(#("\n", rest)) -> split_at_quote_loop(rest, acc <> "\n", line + 1)
    Ok(#(c, rest)) -> split_at_quote_loop(rest, acc <> c, line)
    Error(Nil) -> Error(Nil)
  }
}

/// Trims all caracters at the beginning of a string until a newline is reached
/// Example: "hello\nworld" -> "world"
///
fn skip_until_newline(input: String) -> String {
  case string.pop_grapheme(input) {
    Error(Nil) -> ""
    Ok(#("\n", rest)) -> rest
    Ok(#(_, rest)) -> skip_until_newline(rest)
  }
}

/// Trim all extra zeros at the end of the number passed as a string.
///
fn trim_end_zeroes(input: String) -> String {
  case string.contains(does: input, contain: ".") {
    False -> input
    True -> {
      // It looks easier to remove by poping zeroes from front
      let res = trim_end_zeroes_loop(string.reverse(input)) |> string.reverse
      // We need to check that we don't remove a 0 before a dot like
      // for "12.0" ...
      case string.ends_with(res, ".") {
        True -> res <> "0"
        False -> res
      }
    }
  }
}

fn trim_end_zeroes_loop(input: String) -> String {
  case string.pop_grapheme(input) {
    Error(Nil) -> input
    Ok(#(first, rest)) if first == "0" -> trim_end_zeroes_loop(rest)
    Ok(#(_, _)) -> input
  }
}

/// Read a number at the beginning if a string and return a tuple that
/// is the representation of the number as a string and the rest of the
/// string. If there is no number then an empty string is returned
///
fn read_number(input: String) -> #(String, String) {
  case read_number_loop(input, "") {
    #("", rest) -> #("", rest)
    #(num, rest) -> {
      // We need to check if there is a fraction
      case string.pop_grapheme(rest) {
        Error(Nil) -> #(num, "")
        Ok(#(c, rest)) if c == "." -> read_number_loop(rest, num <> ".")
        Ok(#(c, rest)) -> #(num, c <> rest)
      }
    }
  }
}

fn read_number_loop(input: String, acc: String) -> #(String, String) {
  case starts_with_digit(input) {
    False -> #(acc, input)
    True ->
      case string.pop_grapheme(input) {
        Ok(#(c, rest)) -> read_number_loop(rest, acc <> c)
        Error(Nil) -> #(acc, input)
      }
  }
}

/// Read an identifier. An identifier starts with an alpha character or
/// an underscore and we read until a non alphanumeric value
fn read_identifier(input: String) -> #(String, String) {
  read_identifier_loop(input, "")
}

fn read_identifier_loop(input: String, acc: String) -> #(String, String) {
  case string.pop_grapheme(input) {
    Error(Nil) -> #(acc, "")
    Ok(#(c, rest)) ->
      case is_alpha_numeric(c) {
        True -> read_identifier_loop(rest, acc <> c)
        False -> #(acc, input)
      }
  }
}

/// Returns the simple token in first position without modifying the string.
/// If there is no simple token we return an NotFound error.
///
fn peek(input: String) -> Result(TokenType, TokenError) {
  case string.first(input) {
    Ok(",") -> Ok(Comma)
    Ok(".") -> Ok(Dot)
    Ok("-") -> Ok(Minus)
    Ok("+") -> Ok(Plus)
    Ok(";") -> Ok(Semicolon)
    Ok("/") -> Ok(Slash)
    Ok("*") -> Ok(Star)
    Ok("(") -> Ok(LeftParen)
    Ok(")") -> Ok(RightParen)
    Ok("{") -> Ok(LeftBrace)
    Ok("}") -> Ok(RightBrace)
    Ok("=") -> Ok(Equal)
    Ok("!") -> Ok(Bang)
    Ok("<") -> Ok(Less)
    Ok(">") -> Ok(Greater)
    _ -> Error(NotFound)
  }
}
