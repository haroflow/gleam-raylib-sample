import gleam/dict
import gleam/erlang/charlist
import gleam/float
import gleam/int
import gleam/io
import raylib as rl

pub fn main() {
  rl.init_window(800, 600, charlist.from_string("Gleam Raylib FFI"))

  // rl.disable_cursor()
  rl.set_target_fps(60)

  main_loop()

  rl.close_window()
}

fn main_loop() {
  rl.begin_drawing()
  rl.clear_background(0xCCCCCCFF)

  rl.draw_text(
    charlist.from_string("It works?!"),
    int.random(200),
    int.random(200),
    20,
    0xFF0000FF,
  )

  rl.draw_circle_v(rl.Vector2(400.0, 500.0), 30.0, 0x0000FFFF)

  rl.draw_circle(200, 300, 30.0, 0xFF0000FF)
  rl.draw_circle(rl.get_mouse_x(), rl.get_mouse_y(), 30.0, 0x00FF00FF)

  rl.draw_fps(100, 100)
  rl.draw_circle_gradient(250, 350, 50.0, 0x000000FF, 0xFFFFFFFF)

  rl.rl_set_line_width(5.0)
  rl.draw_circle_lines(100, 100, 60.0, 0x000000FF)

  let v = rl.get_mouse_position()
  io.println(float.to_string(v.x) <> ", " <> float.to_string(v.y))

  rl.end_drawing()

  case rl.window_should_close() {
    0 -> main_loop()
    _ -> Nil
  }
}
