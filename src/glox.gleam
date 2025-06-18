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

type Model =
  Int

fn init(_args) -> #(Model, Effect(Msg)) {
  #(0, effect.none())
}

type Msg {
  UserClickedRunGlox
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(msg)) {
  case msg {
    UserClickedRunGlox -> #(model + 1, effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  let count = int.to_string(model)

  html.div([], [
    html.div([attribute.class("bubbles")], [
      html.span([], []),
      html.span([], []),
      html.span([], []),
      html.span([], []),
      html.span([], []),
    ]),
    html.div([attribute.class("main-container")], [
      html.div([attribute.class("left-panel")], [
        html.textarea(
          [
            attribute.id("input"),
            attribute.rowspan(30),
            attribute.placeholder("// Write some lox here"),
          ],
          "this is a textarea",
        ),
        html.br([]),
        html.button(
          [attribute.id("scan-button"), event.on_click(UserClickedRunGlox)],
          [html.text("Run GLOX")],
        ),
      ]),
      html.div([attribute.class("right-panel")], [
        html.textarea(
          [attribute.class("scan-output"), attribute.placeholder("Scan output")],
          count,
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
