import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import hello

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(x: Int, input: String, output: String)
}

fn init(_args) -> Model {
  Model(0, "", "")
}

type Msg {
  UserClickedRunGlox
  HandleInput(String)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserClickedRunGlox -> {
      let msg = hello.rot13(model.input)
      Model(model.x + 1, model.input, msg)
    }
    HandleInput(s) -> Model(model.x, s, model.output)
  }
}

fn view(model: Model) -> Element(Msg) {
  let count = int.to_string(model.x)

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
            attribute.placeholder("// Write some lox here"),
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
        html.textarea([attribute.placeholder("// Scanner output")], model.input),
        html.textarea([attribute.placeholder("// Parser output")], model.output),
        html.textarea([attribute.placeholder("// Evaluator output")], count),
      ]),
    ]),
  ])
}
