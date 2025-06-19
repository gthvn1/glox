# Glox — A Lox Interpreter in Gleam

- Glox is an implementation of the Lox language (from [Crafting Interpreters](https://craftinginterpreters.com)) written in Gleam.
- It targets javascript to run in the browser, using [lustre](https://hexdocs.pm/lustre/index.html) as the runtime.
- Some examples of Lox code are [here](https://github.com/munificent/craftinginterpreters/tree/01e6f5b8f3e5dfa65674c2f9cf4700d73ab41cf8/test/scanning)
- To run it locally:
```sh
gleam run -m lustre/dev start
```
