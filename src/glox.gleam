import gleam/int
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import interpreter/lexer
import interpreter/token

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(input: String, output: String, error: Int)
}

fn init(_args) -> Model {
  Model("", "", 0)
}

type Msg {
  UserClickedRunGlox
  HandleInput(String)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserClickedRunGlox -> {
      case lexer.tokenize(model.input) {
        #(tokens, 0) -> {
          let msg =
            list.map(tokens, fn(tok) { token.to_string(tok) <> "\n" })
            |> string.concat
          Model(model.input, msg, 0)
        }
        #(_, err) -> Model(model.input, "TODO: better error handling...", err)
      }
    }
    HandleInput(s) -> Model(s, model.output, model.error)
    // Just update the input string
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    // This is used to display some bubbles. Completely useless, just for fun...
    html.div([attribute.class("bubbles")], [
      html.span([], []),
      html.span([], []),
      html.span([], []),
      html.span([], []),
      html.span([], []),
    ]),
    html.div([attribute.class("main-container")], [
      // We have a left-panel that is our input,
      html.div([attribute.class("left-panel")], [
        html.textarea(
          [
            attribute.value(model.input),
            attribute.rowspan(30),
            attribute.placeholder("// Write some lox her (ie: var i = 10)"),
            event.on_input(HandleInput),
          ],
          "",
        ),
        html.br([]),
        html.button([event.on_click(UserClickedRunGlox)], [
          html.text("Run GLOX"),
        ]),
      ]),
      // and a right-panel to display result of scanner, parser and evaluator.
      // Currently we are just printing input, output and count...
      html.div([attribute.class("right-panel")], [
        html.textarea([attribute.placeholder("// Input")], model.input),
        html.textarea([attribute.placeholder("// Lexer output")], model.output),
        html.textarea(
          [attribute.placeholder("// Returned error")],
          case model.error {
            e if e == 0 -> "No error"
            e -> "Found error " <> e |> int.to_string
          },
        ),
      ]),
    ]),
  ])
}
