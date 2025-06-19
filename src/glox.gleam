import gleam/int
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(x: Int, str: String)
}

fn init(_args) -> #(Model, Effect(Msg)) {
  #(Model(0, ""), effect.none())
}

type Msg {
  UserClickedRunGlox
  HandleInput(String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(msg)) {
  case msg {
    UserClickedRunGlox -> #(Model(model.x + 1, model.str), effect.none())
    HandleInput(s) -> #(Model(model.x, s), effect.none())
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
            attribute.id("input"),
            attribute.value(model.str),
            attribute.rowspan(30),
            attribute.placeholder("// Write some lox here"),
            event.on_input(HandleInput),
          ],
          "this is a textarea",
        ),
        html.br([]),
        html.button(
          [attribute.id("scan-button"), event.on_click(UserClickedRunGlox)],
          [html.text("Run GLOX")],
        ),
      ]),
      // and a right-panel to display result of scanner, parser and evaluator.
      html.div([attribute.class("right-panel")], [
        html.textarea(
          [attribute.class("scan-output"), attribute.placeholder("Scan output")],
          model.str,
        ),
        html.textarea(
          [
            attribute.class("parse-output"),
            attribute.placeholder("Parse output"),
          ],
          count,
        ),
        html.textarea(
          [
            attribute.class("expr-output"),
            attribute.placeholder("Expression output"),
          ],
          count,
        ),
      ]),
    ]),
  ])
}
