import gleam/erlang/charlist

@external(erlang, "raylib_ffi", "init_window")
pub fn init_window(width: Int, height: Int, title: charlist.Charlist) -> Nil

@external(erlang, "raylib_ffi", "set_target_fps")
pub fn set_target_fps(fps: Int) -> Nil

@external(erlang, "raylib_ffi", "window_should_close")
pub fn window_should_close() -> Int

@external(erlang, "raylib_ffi", "close_window")
pub fn close_window() -> Nil

@external(erlang, "raylib_ffi", "begin_drawing")
pub fn begin_drawing() -> Nil

@external(erlang, "raylib_ffi", "end_drawing")
pub fn end_drawing() -> Nil

@external(erlang, "raylib_ffi", "clear_background")
pub fn clear_background(color: Int) -> Nil

@external(erlang, "raylib_ffi", "draw_text")
pub fn draw_text(
  text: charlist.Charlist,
  pos_x: Int,
  pos_y: Int,
  font_size: Int,
  color: Int,
) -> Nil

@external(erlang, "raylib_ffi", "draw_circle")
pub fn draw_circle(
  center_x: Int,
  center_y: Int,
  radius: Float,
  color: Int,
) -> Nil

pub type Vector2 {
  Vector2(x: Int, y: Int)
}

@external(erlang, "raylib_ffi", "draw_circle_v")
pub fn draw_circle_v(center: Vector2, radius: Float, color: Int) -> Nil

@external(erlang, "raylib_ffi", "get_mouse_x")
pub fn get_mouse_x() -> Int

@external(erlang, "raylib_ffi", "get_mouse_y")
pub fn get_mouse_y() -> Int
