#include <erl_nif.h>
#include <iostream>
#include <raylib.h>

static ERL_NIF_TERM init_window(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  int width, height;
  enif_get_int(env, argv[0], &width);
  enif_get_int(env, argv[1], &height);

  char buf[1024];
  if (!enif_get_string(env, argv[2], buf, sizeof(buf), ERL_NIF_UTF8))
  {
    return enif_make_badarg(env);
  }

  InitWindow(width, height, buf);
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM set_target_fps(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  int fps;
  enif_get_int(env, argv[0], &fps);

  SetTargetFPS(fps);
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM window_should_close(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  unsigned int result = WindowShouldClose();
  return enif_make_uint(env, result);
}

static ERL_NIF_TERM close_window(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  CloseWindow();
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM begin_drawing(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  BeginDrawing();
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM end_drawing(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  EndDrawing();
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM clear_background(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  unsigned int color;
  enif_get_uint(env, argv[0], &color);

  ClearBackground(GetColor(color));
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM draw_text(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  char buf[1024];
  if (!enif_get_string(env, argv[0], buf, sizeof(buf), ERL_NIF_UTF8))
  {
    return enif_make_badarg(env);
  }

  int posX, posY, fontSize;
  enif_get_int(env, argv[1], &posX);
  enif_get_int(env, argv[2], &posY);
  enif_get_int(env, argv[3], &fontSize);

  unsigned int color;
  enif_get_uint(env, argv[4], &color);

  DrawText(buf, posX, posY, fontSize, GetColor(color));
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM draw_circle(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  int center_x;
  enif_get_int(env, argv[0], &center_x);
  int center_y;
  enif_get_int(env, argv[1], &center_y);
  double radius;
  enif_get_double(env, argv[2], &radius);
  unsigned int color;
  enif_get_uint(env, argv[3], &color);

  DrawCircle(center_x, center_y, radius, GetColor(color));
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM draw_circle_v(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  const ERL_NIF_TERM* center;
  int arity;
  enif_get_tuple(env, argv[0], &arity, &center);

  int center_x;
  enif_get_int(env, center[1], &center_x);

  int center_y;
  enif_get_int(env, center[2], &center_y);

  Vector2 vec2;
  vec2.x = center_x;
  vec2.y = center_y;

  double radius;
  enif_get_double(env, argv[1], &radius);
  unsigned int color;
  enif_get_uint(env, argv[2], &color);

  DrawCircleV(vec2, radius, GetColor(color));
  return enif_make_uint(env, 0);
}

static ERL_NIF_TERM get_mouse_x(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  int result = GetMouseX();
  return enif_make_int(env, result);
}

static ERL_NIF_TERM get_mouse_y(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  int result = GetMouseY();
  return enif_make_int(env, result);
}

static ErlNifFunc nif_funcs[] =
{
  {"init_window", 3, init_window},
  {"set_target_fps", 1, set_target_fps},
  {"window_should_close", 0, window_should_close},
  {"close_window", 0, close_window},
  {"begin_drawing", 0, begin_drawing},
  {"end_drawing", 0, end_drawing},
  {"clear_background", 1, clear_background},
  {"draw_text", 5, draw_text},
  {"draw_circle", 4, draw_circle},
  {"draw_circle_v", 3, draw_circle_v},
  {"get_mouse_x", 0, get_mouse_x},
  {"get_mouse_y", 0, get_mouse_y},
};

ERL_NIF_INIT(raylib_ffi, nif_funcs, NULL, NULL, NULL, NULL)
