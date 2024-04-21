# gleam-raylib-sample

Created for learning purposes, just copy what you need!

Tested on:
- Windows 10
- Erlang 26
- Raylib 5
- Gleam 1.0.0
- GCC 10.2.1 (MinGW-W64 x86_64-posix-seh).

*GCC 13.x.x did not work for me, throws `function not defined` inside Erlang's headers.*

## How to run

1. Clone this repository
2. `cd gleam-raylib-sample`
3. Compile `src/raylib_ffi.cpp` to a shared library. Example on Windows:

    ```
    g++ -fPIC -shared -o raylib_ffi.dll src\raylib_ffi.cpp -I"C:\Program Files\Erlang OTP\usr\include" -lraylib -lgdi32 -lwinmm
    ```

4. Run sample code:

    ```
    gleam run
    ```

5. Run asteroids example:

    ```
    gleam run -m asteroids
    ```

## How to generate bindings from raylib.h

*Note: In progress. Saves ignored functions in `generate_bindings.log`.

1. To generate `.erl`, `.gleam` and `.cpp` files:

    ```
    gleam run -m generate_bindings
    ```

    Note: this will overwrite `src/raylib.gleam`, `src/raylib_ffi.erl` and `src/raylib_ffi.cpp`.

2. Compile `src/raylib_ffi.cpp` to a shared library. Example on Windows:

    ```
    g++ -fPIC -shared -o raylib_ffi.dll src\raylib_ffi.cpp -I"C:\Program Files\Erlang OTP\usr\include" -lraylib -lgdi32 -lwinmm
    ```

3. Run:

    ```
    gleam run
    ```

## How it works

To call raylib functions, we need:

- Bindings from C/C++ to raylib: `src/raylib_ffi.cpp`
- Bindings from Erlang to C: `src/raylib_ffi.erl`
- Bindings from Gleam to Erlang: `src/raylib.gleam`

### C/C++ to Raylib

See `src/raylib_ffi.cpp`.

Documentation for Erlang NIF: https://www.erlang.org/doc/man/erl_nif.html

The function definitions follow this convention:
```cpp
static ERL_NIF_TERM set_target_fps(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ...
}
```

Every function must be exported at the end:
```cpp
static ErlNifFunc nif_funcs[] =
{
  {"set_target_fps", 1, set_target_fps},
  ...
}

ERL_NIF_INIT(raylib_ffi, nif_funcs, NULL, NULL, NULL, NULL)
```

`raylib_ffi` refers to `raylib_ffi.erl` module's name, I believe.

`1` is the arity of the function.

### Erlang to C

See `src/raylib_ffi.erl`.

Erlang NIF works by creating an Erlang module with an init() function. This function is called when Erlang loads the module.

`erlang:load_nif` replaces the definitions of all functions mentioned in `-nifs([ ... ]).` with code to call the C functions.

```erlang
-export([
  init/0
  ...
]).
-on_load(init/0).

init() ->
  erlang:load_nif("raylib_ffi", 0).
```

`raylib_ffi` refers to the name of the shared library, in my case `raylib_ffi.dll`.

To add new functions, change the `-export([ ... ]).`, `-nifs([ ... ]).`, and define the function as:

```erlang
get_mouse_y() ->
	erlang:nif_error("NIF library not loaded").
```

### Gleam to Erlang

See `src/raylib.gleam`.

Example:
```
@external(erlang, "raylib_ffi", "set_target_fps")
pub fn set_target_fps(fps: Int) -> Nil
```

`raylib_ffi` refers to the `raylib_ffi.erl` module name.

## Tips

- This breaks easily... if there are exported functions in raylib_ffi.cpp not defined in raylib_ffi.erl, etc.
- You can use erlang interactive shell to debug some problems: `c("src/raylib_ffi.erl").`
- For String arguments, I had to use Charlist in Gleam.
- For Vector2 arguments, the C++ code used Erlang's Tuples.