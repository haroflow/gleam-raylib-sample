-module(raylib_ffi).
-export([
	init/0,
	init_window/3,
	set_target_fps/1,
	window_should_close/0,
	close_window/0,
	begin_drawing/0,
	end_drawing/0,
	clear_background/1,
	draw_text/5,
	draw_circle/4,
	draw_circle_v/3,
	get_mouse_x/0,
	get_mouse_y/0
]).
-on_load(init/0).
-nifs([
	init_window/3,
	set_target_fps/1,
	window_should_close/0,
	close_window/0,
	begin_drawing/0,
	end_drawing/0,
	clear_background/1,
	draw_text/5,
	draw_circle/4,
	draw_circle_v/3,
	get_mouse_x/0,
	get_mouse_y/0
]).

init() ->
	erlang:load_nif("raylib_ffi", 0).

init_window(width, height, title) ->
	erlang:nif_error("NIF library not loaded").

set_target_fps(fps) -> 
	erlang:nif_error("NIF library not loaded").

window_should_close() -> 
	erlang:nif_error("NIF library not loaded").

close_window() -> 
	erlang:nif_error("NIF library not loaded").

begin_drawing() -> 
	erlang:nif_error("NIF library not loaded").

end_drawing() -> 
	erlang:nif_error("NIF library not loaded").

clear_background(color) -> 
	erlang:nif_error("NIF library not loaded").

draw_text(text, pos_x, pos_y, font_size, color) -> 
	erlang:nif_error("NIF library not loaded").

draw_circle(center_x, center_y, radius, color) -> 
	erlang:nif_error("NIF library not loaded").

draw_circle_v(center, radius, color) ->
	erlang:nif_error("NIF library not loaded").

get_mouse_x() ->
	erlang:nif_error("NIF library not loaded").

get_mouse_y() ->
	erlang:nif_error("NIF library not loaded").
