//
// A prototype, still crashes from time to time.
//

import gleam/dict
import gleam/erlang/charlist
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import raylib as rl

const background_color: Int = 0x000000FF

const color_white: Int = 0xFFFFFFFF

const star_color: Int = 0xCCCCCCFF

const key_right: Int = 262

const key_left: Int = 263

const key_up: Int = 265

const key_space: Int = 32

const screen_width: Int = 800

const screen_height: Int = 800

const bullet_life: Int = 80

type GameState {
  GameState(
    ship_orientation: Float,
    ship_position: rl.Vector2,
    ship_velocity: rl.Vector2,
    ship_thruster: Bool,
    bullets: List(Bullet),
    asteroids: List(Asteroid),
    score: Int,
    stars: List(Star),
  )
}

type Star {
  Star(position: rl.Vector2, size: Float)
}

type Bullet {
  Bullet(position: rl.Vector2, velocity: rl.Vector2, life: Int)
}

type Asteroid {
  Asteroid(
    position: rl.Vector2,
    velocity: rl.Vector2,
    rotation: Float,
    rotation_speed: Float,
  )
}

type ImageDict =
  dict.Dict(String, rl.Texture2D)

pub fn main() {
  rl.init_window(screen_width, screen_height, charlist.from_string("Asteroids"))

  let images = load_images()

  let state =
    GameState(
      ship_orientation: 0.0,
      ship_position: rl.Vector2(
        int.to_float(screen_width) /. 2.0,
        int.to_float(screen_height) /. 2.0,
      ),
      ship_velocity: rl.Vector2(0.0, 0.0),
      ship_thruster: False,
      bullets: [],
      asteroids: [],
      score: 0,
      stars: generate_stars(),
    )

  rl.set_target_fps(60)

  main_loop(images, state)

  rl.close_window()
}

fn main_loop(images: ImageDict, state: GameState) {
  let state =
    state
    |> process_inputs
    |> process_physics

  rl.begin_drawing()
  draw_background(state)
  draw_spaceship(images, state)
  draw_bullets(state)
  draw_asteroids(images, state)
  draw_score(state)
  rl.end_drawing()

  case rl.window_should_close() {
    0 -> main_loop(images, state)
    _ -> Nil
  }
}

@external(erlang, "math", "sin")
fn sin(angle: Float) -> Float

@external(erlang, "math", "cos")
fn cos(angle: Float) -> Float

@external(erlang, "math", "pi")
fn pi() -> Float

fn degrees_to_radians(degrees: Float) -> Float {
  degrees *. pi() /. 180.0
}

fn process_inputs(state: GameState) -> GameState {
  let rotation_speed = 5.0
  let state = case rl.is_key_down(key_left) {
    0 -> state
    _ ->
      GameState(
        ..state,
        ship_orientation: state.ship_orientation -. rotation_speed,
      )
  }
  let state = case rl.is_key_down(key_right) {
    0 -> state
    _ ->
      GameState(
        ..state,
        ship_orientation: state.ship_orientation +. rotation_speed,
      )
  }

  let radians = degrees_to_radians(state.ship_orientation -. 90.0)
  let direction = rl.Vector2(cos(radians), sin(radians))

  let state = case rl.is_key_down(key_up) {
    0 -> GameState(..state, ship_thruster: False)
    _ -> {
      let thrust = 0.3
      let new_velocity =
        vector2_add(state.ship_velocity, vector2_scale(direction, thrust))
      GameState(..state, ship_velocity: new_velocity, ship_thruster: True)
    }
  }

  let state = case rl.is_key_pressed(key_space) {
    0 -> state
    _ -> {
      let bullet_velocity = vector2_scale(direction, 10.0)
      let new_bullet =
        Bullet(state.ship_position, bullet_velocity, life: bullet_life)
      GameState(..state, bullets: [new_bullet, ..state.bullets])
    }
  }

  let state = case int.random(50) == 0 {
    True -> {
      let x =
        float.random()
        |> float.round
        |> int.to_float
      let y =
        float.random()
        |> float.round
        |> int.to_float
      let new_asteroid =
        Asteroid(
          position: rl.Vector2(
            x *. int.to_float(screen_width),
            y *. int.to_float(screen_height),
          ),
          velocity: rl.Vector2(
            float.random() *. 2.0 -. 1.0,
            float.random() *. 2.0 -. 1.0,
          ),
          rotation: float.random() *. 10.0,
          rotation_speed: float.random() *. 2.0,
        )

      GameState(..state, asteroids: [new_asteroid, ..state.asteroids])
    }
    False -> state
  }

  state
}

fn process_physics(state: GameState) -> GameState {
  let ship_position =
    vector2_add(state.ship_position, state.ship_velocity)
    |> wrap_around_screen

  let bullets =
    state.bullets
    |> list.map(fn(bullet) {
      let new_position =
        vector2_add(bullet.position, bullet.velocity)
        |> wrap_around_screen
      Bullet(..bullet, position: new_position, life: bullet.life - 1)
    })
    |> list.filter(fn(bullet) { bullet.life > 0 })

  let asteroids =
    state.asteroids
    |> list.map(fn(asteroid) {
      let new_position =
        vector2_add(asteroid.position, asteroid.velocity)
        |> wrap_around_screen
      Asteroid(
        ..asteroid,
        position: new_position,
        rotation: asteroid.rotation +. asteroid.rotation_speed,
      )
    })

  let asteroid_bullet_collisions =
    bullets
    |> list.filter_map(fn(bullet) {
      let colliding_with_asteroid =
        asteroids
        |> list.find(fn(asteroid) {
          vector2_distance(asteroid.position, bullet.position) <=. 40.0
        })
      case colliding_with_asteroid {
        Ok(asteroid) -> Ok(#(bullet, asteroid))
        Error(Nil) -> Error(Nil)
      }
    })

  let bullets =
    bullets
    |> list.filter(fn(bullet) {
      let collided =
        asteroid_bullet_collisions
        |> list.any(fn(collision) { collision.0 == bullet })
      !collided
    })

  let asteroids =
    asteroids
    |> list.filter(fn(asteroid) {
      let collided =
        asteroid_bullet_collisions
        |> list.any(fn(collision) { collision.1 == asteroid })
      !collided
    })

  let score = state.score + list.length(asteroid_bullet_collisions)

  GameState(
    ..state,
    ship_position: ship_position,
    bullets: bullets,
    asteroids: asteroids,
    score: score,
  )
}

fn vector2_distance(v1: rl.Vector2, v2: rl.Vector2) -> Float {
  let assert Ok(dx) = float.power(float.absolute_value(v1.x -. v2.x), 2.0)
  let assert Ok(dy) = float.power(float.absolute_value(v1.y -. v2.y), 2.0)
  let assert Ok(result) = float.square_root(dx +. dy)
  result
}

fn wrap_around_screen(position: rl.Vector2) -> rl.Vector2 {
  let w = int.to_float(screen_width)
  let h = int.to_float(screen_height)
  let x = case position.x <. 10.0, position.x >. { w +. 10.0 } {
    True, False -> position.x +. w
    False, True -> position.x -. w
    _, _ -> position.x
  }
  let y = case position.y <. 10.0, position.y >. { h +. 10.0 } {
    True, False -> position.y +. h
    False, True -> position.y -. h
    _, _ -> position.y
  }

  rl.Vector2(x, y)
}

fn vector2_add(v1: rl.Vector2, v2: rl.Vector2) -> rl.Vector2 {
  rl.Vector2(v1.x +. v2.x, v1.y +. v2.y)
}

fn vector2_scale(v1: rl.Vector2, scale: Float) -> rl.Vector2 {
  rl.Vector2(v1.x *. scale, v1.y *. scale)
}

fn draw_spaceship(images: ImageDict, state: GameState) {
  let assert Ok(img_spaceship) = dict.get(images, "spaceship")
  let assert Ok(img_spaceship_thruster) = dict.get(images, "spaceship_thruster")
  let image_width = 80.0
  let image_height = 80.0

  let img = case state.ship_thruster {
    True -> img_spaceship_thruster
    False -> img_spaceship
  }
  rl.draw_texture_pro(
    img,
    rl.Rectangle(0.0, 0.0, image_width, image_height),
    rl.Rectangle(
      state.ship_position.x,
      state.ship_position.y,
      image_width /. 2.0,
      image_height /. 2.0,
    ),
    rl.Vector2(image_width /. 4.0, image_height /. 4.0),
    state.ship_orientation,
    color_white,
  )
}

fn draw_bullets(state: GameState) {
  state.bullets
  |> list.each(draw_bullet)
}

fn draw_bullet(bullet: Bullet) {
  let rl.Vector2(x, y) = bullet.position
  rl.draw_circle(float.round(x), float.round(y), 3.0, color_white)
}

fn draw_asteroids(images: ImageDict, state: GameState) {
  state.asteroids
  |> list.each(fn(asteroid) { draw_asteroid(images, asteroid) })
}

fn draw_asteroid(images: ImageDict, asteroid: Asteroid) {
  let assert Ok(image) = dict.get(images, "asteroid")
  let image_width = 112.0
  let image_height = 108.0

  rl.draw_texture_pro(
    image,
    rl.Rectangle(0.0, 0.0, image_width, image_height),
    rl.Rectangle(
      asteroid.position.x,
      asteroid.position.y,
      image_width /. 2.0,
      image_height /. 2.0,
    ),
    rl.Vector2(image_width /. 4.0, image_height /. 4.0),
    asteroid.rotation,
    color_white,
  )
}

fn load_images() -> dict.Dict(String, rl.Texture2D) {
  dict.from_list([])
  |> dict.insert(
    "spaceship",
    rl.load_texture(charlist.from_string("assets/spaceship.png")),
  )
  |> dict.insert(
    "spaceship_thruster",
    rl.load_texture(charlist.from_string("assets/spaceship_thruster.png")),
  )
  |> dict.insert(
    "asteroid",
    rl.load_texture(charlist.from_string("assets/asteroid.png")),
  )
}

fn draw_score(state: GameState) {
  rl.draw_text(
    charlist.from_string("Score: " <> int.to_string(state.score)),
    10,
    10,
    20,
    color_white,
  )
}

fn draw_background(state: GameState) {
  rl.clear_background(background_color)

  state.stars
  |> list.each(fn(star) {
    let color = case int.random(30) == 0 {
      True -> 0x000000FF
      False -> 0xEEEEEEFF
    }
    rl.draw_circle_v(star.position, star.size, color)
  })
}

fn generate_stars() {
  list.range(0, 100)
  |> list.map(fn(_) {
    Star(
      rl.Vector2(
        float.random() *. int.to_float(screen_width),
        float.random() *. int.to_float(screen_height),
      ),
      float.random() *. 5.0,
    )
  })
}
