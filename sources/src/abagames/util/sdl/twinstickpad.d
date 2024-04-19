/*
 * $Id: twinstickpad.d,v 1.4 2006/03/18 03:36:00 kenta Exp $
 *
 * Copyright 2006 Kenta Cho. Some rights reserved.
 */
module abagames.util.sdl.twinstickpad;

private import std.string;
private import std.stdio;
private import std.math;
private import bindbc.sdl;
private import abagames.util.vector;
private import abagames.util.sdl.input;
private import abagames.util.sdl.recordableinput;

/**
 * Twinstick and buttons input.
 */
public class TwinStickPad: Input {
 public:
  static float rotate = 0;
  static float reverse = 1;
  static bool buttonReversed = false;
  static bool enableAxis5 = false;
  static bool disableStick2 = false;
  ubyte *keys;
 private:
  SDL_Joystick *stick = null;
  const int JOYSTICK_AXIS_MAX = 32768;
  TwinStickPadState state;

  public this() {
    state = new TwinStickPadState;
  }

  public SDL_Joystick* openJoystick(SDL_Joystick *st = null) {
    if (st == null) {
      if (SDL_InitSubSystem(SDL_INIT_JOYSTICK) < 0)
        return null;
      stick = SDL_JoystickOpen(0);
    } else {
      stick = st;
    }
    return stick;
  }

  public void handleEvents() {
    keys = SDL_GetKeyboardState(null);
  }

  public TwinStickPadState getState() {
    if (stick) {
      state.left.x = adjustAxis(SDL_JoystickGetAxis(stick, 0));
      state.left.y = -adjustAxis(SDL_JoystickGetAxis(stick, 1));
      int rx = 0, ry = 0;
      if (!disableStick2) {
        if (enableAxis5)
          rx = SDL_JoystickGetAxis(stick, 4);
        else
          rx = SDL_JoystickGetAxis(stick, 2);
        ry = SDL_JoystickGetAxis(stick, 3);
      }
      if (rx == 0 && ry == 0) {
        state.right.x = state.right.y = 0;
      } else {
        ry = -ry;
        float rd = atan2(cast(float) rx, cast(float) ry) * reverse + rotate;
        assert(!std.math.isNaN(rd));
        float rl = sqrt(cast(float) rx * rx + cast(float) ry * ry);
        assert(!std.math.isNaN(rl));
        float rdSin = sin(rd);
        float rdCos = cos(rd);
        state.right.x = adjustAxis(cast(int) (rdSin * rl));
        state.right.y = adjustAxis(cast(int) (rdCos * rl));
      }
    } else {
      state.left.x = state.left.y = state.right.x = state.right.y = 0;
    }
    if (keys[SDL_SCANCODE_RIGHT] == SDL_PRESSED || keys[SDL_SCANCODE_KP_6] == SDL_PRESSED ||
        keys[SDL_SCANCODE_D] == SDL_PRESSED)
      state.left.x = 1;
    if (keys[SDL_SCANCODE_L] == SDL_PRESSED)
      state.right.x = 1;
    if (keys[SDL_SCANCODE_LEFT] == SDL_PRESSED || keys[SDL_SCANCODE_KP_4] == SDL_PRESSED ||
        keys[SDL_SCANCODE_A] == SDL_PRESSED)
      state.left.x = -1;
    if (keys[SDL_SCANCODE_J] == SDL_PRESSED)
      state.right.x = -1;
    if (keys[SDL_SCANCODE_DOWN] == SDL_PRESSED || keys[SDL_SCANCODE_KP_2] == SDL_PRESSED ||
        keys[SDL_SCANCODE_S] == SDL_PRESSED)
      state.left.y = -1;
    if (keys[SDL_SCANCODE_K] == SDL_PRESSED)
      state.right.y = -1;
    if (keys[SDL_SCANCODE_UP] == SDL_PRESSED ||  keys[SDL_SCANCODE_KP_8] == SDL_PRESSED ||
        keys[SDL_SCANCODE_W] == SDL_PRESSED)
      state.left.y = 1;
    if (keys[SDL_SCANCODE_I] == SDL_PRESSED)
      state.right.y = 1;
    state.button = 0;
    int btn1 = 0, btn2 = 0;
    version(PYRA) {
    } else {
      if (stick) {
        btn1 = SDL_JoystickGetButton(stick, 0) + SDL_JoystickGetButton(stick, 2) +
               SDL_JoystickGetButton(stick, 4) + SDL_JoystickGetButton(stick, 6) +
               SDL_JoystickGetButton(stick, 8) + SDL_JoystickGetButton(stick, 10);
        btn2 = SDL_JoystickGetButton(stick, 1) + SDL_JoystickGetButton(stick, 3) +
               SDL_JoystickGetButton(stick, 5) + SDL_JoystickGetButton(stick, 7) +
               SDL_JoystickGetButton(stick, 9) + SDL_JoystickGetButton(stick, 11);
        if (enableAxis5) {
          int ax2 = SDL_JoystickGetAxis(stick, 2);
          if (ax2 > JOYSTICK_AXIS_MAX / 3 || ax2 < -JOYSTICK_AXIS_MAX / 3)
            btn2 = 1;
        }
      }
    }
    version (PYRA) {
      if (keys[SDL_SCANCODE_HOME] == SDL_PRESSED || keys[SDL_SCANCODE_PAGEUP] == SDL_PRESSED) {
        if (!buttonReversed)
          state.button |= TwinStickPadState.Button.A;
        else
          state.button |= TwinStickPadState.Button.B;
      }
      if (keys[SDL_SCANCODE_PAGEDOWN] == SDL_PRESSED || keys[SDL_SCANCODE_END] == SDL_PRESSED) {
        if (!buttonReversed)
          state.button |= TwinStickPadState.Button.B;
        else
          state.button |= TwinStickPadState.Button.A;
      }
    } else {
      if (keys[SDL_SCANCODE_Z] == SDL_PRESSED || keys[SDL_SCANCODE_PERIOD] == SDL_PRESSED ||
          keys[SDL_SCANCODE_LCTRL] == SDL_PRESSED || keys[SDL_SCANCODE_RCTRL] == SDL_PRESSED ||
          btn1) {
        if (!buttonReversed)
          state.button |= TwinStickPadState.Button.A;
        else
          state.button |= TwinStickPadState.Button.B;
      }
      if (keys[SDL_SCANCODE_X] == SDL_PRESSED || keys[SDL_SCANCODE_SLASH] == SDL_PRESSED ||
          keys[SDL_SCANCODE_LALT] == SDL_PRESSED || keys[SDL_SCANCODE_RALT] == SDL_PRESSED ||
          keys[SDL_SCANCODE_LSHIFT] == SDL_PRESSED || keys[SDL_SCANCODE_RSHIFT] == SDL_PRESSED ||
          keys[SDL_SCANCODE_RETURN] == SDL_PRESSED || keys[SDL_SCANCODE_SPACE] == SDL_PRESSED ||
          btn2) {
        if (!buttonReversed)
          state.button |= TwinStickPadState.Button.B;
        else
          state.button |= TwinStickPadState.Button.A;
      }
    }
    return state;
  }

  private float adjustAxis(int v) {
    float a = 0;
    if (v > JOYSTICK_AXIS_MAX / 3) {
      a = cast(float) (v - JOYSTICK_AXIS_MAX / 3) /
        (JOYSTICK_AXIS_MAX - JOYSTICK_AXIS_MAX / 3);
      if (a > 1)
        a = 1;
    } else if (v < -(JOYSTICK_AXIS_MAX / 3)) {
      a = cast(float) (v + JOYSTICK_AXIS_MAX / 3) /
        (JOYSTICK_AXIS_MAX - JOYSTICK_AXIS_MAX / 3);
      if (a < -1)
        a = -1;
    }
    return a;
  }

  public TwinStickPadState getNullState() {
    state.clear();
    return state;
  }
}

public class TwinStickPadState {
 public:
  static enum Button {
    A = 16, B = 32, ANY = 48,
  };
  Vector left, right;
  int button;
 private:

  invariant() {
    assert(left.x >= -1 && left.x <= 1);
    assert(left.y >= -1 && left.y <= 1);
    assert(right.x >= -1 && right.x <= 1);
    assert(right.y >= -1 && right.y <= 1);
  }

  public static TwinStickPadState newInstance() {
    return new TwinStickPadState;
  }

  public static TwinStickPadState newInstance(TwinStickPadState s) {
    return new TwinStickPadState(s);
  }

  public this() {
    left = new Vector;
    right = new Vector;
  }

  public this(TwinStickPadState s) {
    this();
    set(s);
  }

  public void set(TwinStickPadState s) {
    left.x = s.left.x;
    left.y = s.left.y;
    right.x = s.right.x;
    right.y = s.right.y;
    button = s.button;
  }

  public void clear() {
    left.x = left.y = right.x = right.y = 0;
    button = 0;
  }

  public void read(File fd) {
    float[4] read_data;
    fd.rawRead(read_data);
    left.x = read_data[0];
    left.y = read_data[1];
    right.x = read_data[2];
    right.y = read_data[3];
    int[1] read_data2;
    fd.rawRead(read_data2);
    button = read_data2[0];
  }

  public void write(File fd) {
    float[4] write_data = [left.x, left.y, right.x, right.y];
    fd.rawWrite(write_data);
    int[1] write_data2 = [button];
    fd.rawWrite(write_data2);
  }

  public bool equals(TwinStickPadState s) {
    return (left.x == s.left.x && left.y == s.left.y &&
            right.x == s.right.x && right.y == s.right.y &&
            button == s.button);
  }
}

public class RecordableTwinStickPad: TwinStickPad {
  mixin RecordableInput!(TwinStickPadState);
 private:

  public override TwinStickPadState getState() {
    return getState(true);
  }

  public TwinStickPadState getState(bool doRecord) {
    TwinStickPadState s = super.getState();
    if (doRecord)
      record(s);
    return s;
  }
}
