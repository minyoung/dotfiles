/*
Copyright 2019 @foostan
Copyright 2020 Drashna Jaelre <@drashna>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include QMK_KEYBOARD_H

// tap dance
enum {
  D_COLN,
  D_SCLN,
  D_CIRC,
  D_PERC,
  D_DLR,
  D_TILD,
  SOME_OTHER_DANCE,
};


enum custom_keycodes {
  LT_LOWER = SAFE_RANGE,
  LT_RAISE,
};


enum layers {
  _QWERTY,
  _LOWER,
  _RAISE,
  _ADJUST
};


#define _LS_CPS LSFT_T(KC_CAPS)
#define _LG_ESC LGUI_T(KC_ESC)
#define _RG_ENT RGUI_T(KC_ENT)
#define _L1_ESC LT(1, KC_ESC)
// #define _L1_SPC LT(1, KC_SPC)
#define _L1_SPC LT_LOWER
#define _L2_SPC LT(2, KC_SPC)
// #define _L2_SPC LT_RAISE
#define _RS_ESC RSFT_T(KC_ESC)
#define _LC_GRV LCTL_T(KC_GRV)

// home row mod keys
// base layer
#define HM____J LCTL_T(KC_J)
#define HM____K LALT_T(KC_K)
#define HM____L LGUI_T(KC_L)
// #define _MOD_CN LSFT_T(KC_SCLN)
#define HM___SC TD(D_SCLN)

#define HM____F RCTL_T(KC_F)
#define HM____D RALT_T(KC_D)
#define HM____S RGUI_T(KC_S)
#define HM____A RSFT_T(KC_A)

// lower layer
#define HM_DOWN LCTL_T(KC_DOWN)
#define HM___UP LALT_T(KC_UP)
#define HM_RGHT LGUI_T(KC_RGHT)
// #define HM___R4 LSFT_T(KC_SCLN)
#define HM___R4 KC_LSFT

#define HM____6 RCTL_T(KC_6)
#define HM____5 RALT_T(KC_5)
#define HM____4 RGUI_T(KC_4)
#define HM__GRV RSFT_T(KC_GRV)

// raise layer
#define HM_PGDN LCTL_T(KC_PGDN)
#define HM_PGUP LALT_T(KC_PGUP)
#define HM__END LGUI_T(KC_END)
#define HM_COLN TD(D_COLN)

#define HM_CIRC TD(D_CIRC)
#define HM_PERC TD(D_PERC)
#define HM__DLR TD(D_DLR)
#define HM_TILD TD(D_TILD)


const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [_QWERTY] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,                         KC_Y,    KC_U,    KC_I,    KC_O,   KC_P,  KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      _LC_GRV, HM____A, HM____S, HM____D, HM____F,    KC_G,                         KC_H, HM____J, HM____K, HM____L, HM___SC, KC_QUOT,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, KC_CAPS,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                            MO(2), _L1_SPC, _LG_ESC,    _RG_ENT, _L2_SPC,   MO(1)
                                      //`--------------------------'  `--------------------------'

  ),

  [_LOWER] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB, XXXXXXX, KC_7   , KC_8   , KC_9   , KC_0   ,                      KC_LBRC, KC_RBRC, KC_INS , XXXXXXX, KC_DEL , KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL, HM__GRV, HM____4, HM____5, HM____6, KC_MINS,                      KC_LEFT, HM_DOWN, HM___UP, HM_RGHT, HM___R4, KC_GRV ,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT, KC_0   , KC_1   , KC_2   , KC_3   , KC_EQL ,                      KC_BSLS, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_RSFT,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LGUI, _______, KC_LGUI,    KC_RGUI,   MO(3), KC_RALT
                                      //`--------------------------'  `--------------------------'
  ),

  [_RAISE] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB, XXXXXXX, KC_AMPR, KC_ASTR, KC_LPRN, KC_RPRN,                      KC_LCBR, KC_RCBR, XXXXXXX, XXXXXXX, KC_DEL , KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL, HM_TILD, HM__DLR, HM_PERC, HM_CIRC, KC_UNDS,                      KC_HOME, HM_PGDN, HM_PGUP, HM__END, HM_COLN, KC_DQUO,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT, XXXXXXX, KC_EXLM, KC_AT  , KC_HASH, KC_PLUS,                      KC_PIPE, XXXXXXX, KC_LABK, KC_RABK, KC_QUES, KC_RSFT,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LGUI,   MO(3), KC_LGUI,    KC_RGUI, _______, KC_RALT
                                      //`--------------------------'  `--------------------------'
  ),

  [_ADJUST] = LAYOUT_split_3x6_3(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
        RESET, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      RGB_TOG, RGB_HUI, RGB_SAI, RGB_VAI, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      RGB_MOD, RGB_HUD, RGB_SAD, RGB_VAD, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LGUI, _______,  KC_SPC,     KC_ENT, _______, KC_RALT
                                      //`--------------------------'  `--------------------------'
  )
};

bool get_ignore_mod_tap_interrupt(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case _LC_GRV:
      return false;
    default:
      return true;
  }
}

#ifdef OLED_DRIVER_ENABLE
oled_rotation_t oled_init_user(oled_rotation_t rotation) {
  if (!is_master) {
    return OLED_ROTATION_180;  // flips the display 180 degrees if offhand
  }
  return rotation;
}

#define L_BASE 0
#define L_LOWER 2
#define L_RAISE 4
#define L_ADJUST 8

void oled_render_layer_state(void) {
    oled_write_P(PSTR("Layer: "), false);
    switch (layer_state) {
        case L_BASE:
            oled_write_ln_P(PSTR("Default"), false);
            break;
        case L_LOWER:
            oled_write_ln_P(PSTR("Lower"), false);
            break;
        case L_RAISE:
            oled_write_ln_P(PSTR("Raise"), false);
            break;
        case L_ADJUST:
        case L_ADJUST|L_LOWER:
        case L_ADJUST|L_RAISE:
        case L_ADJUST|L_LOWER|L_RAISE:
            oled_write_ln_P(PSTR("Adjust"), false);
            break;
    }
}


char keylog_str[24] = {};

const char code_to_name[60] = {
    ' ', ' ', ' ', ' ', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
    'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
    'R', 'E', 'B', 'T', '_', '-', '=', '[', ']', '\\',
    '#', ';', '\'', '`', ',', '.', '/', ' ', ' ', ' '};

void set_keylog(uint16_t keycode, keyrecord_t *record) {
  char name = ' ';
    if ((keycode >= QK_MOD_TAP && keycode <= QK_MOD_TAP_MAX) ||
        (keycode >= QK_LAYER_TAP && keycode <= QK_LAYER_TAP_MAX)) { keycode = keycode & 0xFF; }
  if (keycode < 60) {
    name = code_to_name[keycode];
  }

  // update keylog
  snprintf(keylog_str, sizeof(keylog_str), "%dx%d, k%2d : %c",
           record->event.key.row, record->event.key.col,
           keycode, name);
}

void oled_render_keylog(void) {
    oled_write(keylog_str, false);
}

void render_bootmagic_status(bool status) {
    /* Show Ctrl-Gui Swap options */
    static const char PROGMEM logo[][2][3] = {
        {{0x97, 0x98, 0}, {0xb7, 0xb8, 0}},
        {{0x95, 0x96, 0}, {0xb5, 0xb6, 0}},
    };
    if (status) {
        oled_write_ln_P(logo[0][0], false);
        oled_write_ln_P(logo[0][1], false);
    } else {
        oled_write_ln_P(logo[1][0], false);
        oled_write_ln_P(logo[1][1], false);
    }
}

void oled_render_logo(void) {
    static const char PROGMEM crkbd_logo[] = {
        0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93, 0x94,
        0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4,
        0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4,
        0};
    oled_write_P(crkbd_logo, false);
}

void oled_task_user(void) {
    if (is_master) {
        oled_render_layer_state();
        oled_render_keylog();
    } else {
        oled_render_logo();
    }
}

#endif // OLED_DRIVER_ENABLE

bool lower_interrupted = false;
bool raise_interrupted = false;

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
#ifdef OLED_DRIVER_ENABLE
  if (record->event.pressed) {
    set_keylog(keycode, record);
  }
#endif

  // unfortunately LT() doesn't use `get_ignore_mod_tap_interrupt`, so we'll
  // have to emulate it's logic manually here
  // https://github.com/qmk/qmk_firmware/issues/303
  // https://github.com/yroeht/qmk_firmware/commit/cc78964f531fff7eb0ebc4c4e75bc8bc76386ec2
  switch (keycode) {
    case LT_LOWER:
      if (record->event.pressed) {
        lower_interrupted = false;
        layer_on(_LOWER);
      } else {
        if (!lower_interrupted) {
          register_code(KC_SPC);
          unregister_code(KC_SPC);
        }
        layer_off(_LOWER);
      }
      return false;
      break;
    case LT_RAISE:
      if (record->event.pressed) {
        raise_interrupted = false;
        layer_on(_RAISE);
      } else {
        if (!raise_interrupted) {
          register_code(KC_SPC);
          unregister_code(KC_SPC);
        }
        layer_off(_RAISE);
      }
      return false;
      break;
    default:
      if (record->event.pressed) {
        lower_interrupted = true;
        raise_interrupted = true;
      }
  }
  return true;
}

// some tap dance customization

typedef enum {
  TD_NONE,
  TD_SINGLE_TAP,
  TD_SINGLE_HOLD,
  TD_DOUBLE_TAP,
  TD_DOUBLE_HOLD,
} td_state_t;

typedef struct {
  td_state_t state;
  uint16_t single_mod;
  uint16_t single_tap;
  uint16_t double_mod;
  uint16_t double_tap;
  uint16_t hold;
} td_tap_t;

td_state_t cur_dance(qk_tap_dance_state_t *state) {
  if (state->count == 1) {
    if (!state->pressed) return TD_SINGLE_TAP;
    else return TD_SINGLE_HOLD;
  } else if (state->count == 2) {
    if (state->pressed) return TD_DOUBLE_HOLD;
    else return TD_DOUBLE_TAP;
  }

  // default to single taps :shrug
  if (!state->pressed) return TD_SINGLE_TAP;
  else return TD_SINGLE_HOLD;
}

void _tap_dance_hold_finished(qk_tap_dance_state_t *state, void *user_data) {
  td_tap_t* user_state = (td_tap_t*)user_data;
  user_state->state = cur_dance(state);
  switch (user_state->state) {
    case TD_SINGLE_TAP:
      if (user_state->single_mod) {
        register_code(user_state->single_mod);
      }
      register_code(user_state->single_tap);
      break;
    case TD_SINGLE_HOLD: register_code(user_state->hold); break;
    case TD_DOUBLE_TAP:
      if (!user_state->double_tap) {
        break;
      }
      if (user_state->double_mod) {
        register_code(user_state->double_mod);
      }
      register_code(user_state->double_tap);
      break;
    case TD_DOUBLE_HOLD: register_code(user_state->hold); break;
    case TD_NONE: break;
  };
}

void _tap_dance_hold_reset(qk_tap_dance_state_t *state, void *user_data) {
  td_tap_t* user_state = (td_tap_t*)user_data;
  switch (user_state->state) {
    case TD_SINGLE_TAP:
      unregister_code(user_state->single_tap);
      if (user_state->single_mod) {
        unregister_code(user_state->single_mod);
      }
      break;
    case TD_SINGLE_HOLD: unregister_code(user_state->hold); break;
    case TD_DOUBLE_TAP:
      if (!user_state->double_tap) {
        break;
      }
      unregister_code(user_state->double_tap);
      if (user_state->double_mod) {
        unregister_code(user_state->double_mod);
      }
      break;
    case TD_DOUBLE_HOLD: unregister_code(user_state->hold); break;
    case TD_NONE: break;
  }
  user_state->state = TD_NONE;
}

qk_tap_dance_action_t tap_dance_actions[] = {
  [D_COLN] = {
    .fn = {NULL, _tap_dance_hold_finished, _tap_dance_hold_reset},
    .user_data = (void*)&((td_tap_t){
      .single_mod = KC_RSFT,
      .single_tap = KC_SCLN,
      .double_mod = 0,
      .double_tap = 0,
      .hold = KC_RSFT,
    }),
  },
  [D_SCLN] = {
    .fn = {NULL, _tap_dance_hold_finished, _tap_dance_hold_reset},
    .user_data = (void*)&((td_tap_t){
      .single_mod = 0,
      .single_tap = KC_SCLN,
      .double_mod = KC_RSFT,
      .double_tap = KC_SCLN,
      .hold = KC_RSFT,
    }),
  },
  [D_CIRC] = {
    .fn = {NULL, _tap_dance_hold_finished, _tap_dance_hold_reset},
    .user_data = (void*)&((td_tap_t){
      .single_mod = KC_LSFT,
      .single_tap = KC_6,
      .double_mod = 0,
      .double_tap = 0,
      .hold = KC_LCTL
    }),
  },
  [D_PERC] = {
    .fn = {NULL, _tap_dance_hold_finished, _tap_dance_hold_reset},
    .user_data = (void*)&((td_tap_t){
      .single_mod = KC_LSFT,
      .single_tap = KC_5,
      .double_mod = 0,
      .double_tap = 0,
      .hold = KC_LALT,
    }),
  },
  [D_DLR] = {
    .fn = {NULL, _tap_dance_hold_finished, _tap_dance_hold_reset},
    .user_data = (void*)&((td_tap_t){
      .single_mod = KC_LSFT,
      .single_tap = KC_4,
      .double_mod = 0,
      .double_tap = 0,
      .hold = KC_LGUI,
    }),
  },
  [D_TILD] = {
    .fn = {NULL, _tap_dance_hold_finished, _tap_dance_hold_reset},
    .user_data = (void*)&((td_tap_t){
      .single_mod = KC_LSFT,
      .single_tap = KC_GRV,
      .double_mod = 0,
      .double_tap = 0,
      .hold = KC_LSFT,
    }),
  },
};
