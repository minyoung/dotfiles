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
#define _L1_SPC LT(1, KC_SPC)
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
// #define HM__DLR LSFT_T(KC_4)
#define HM_TILD TD(D_TILD)
// #define HM_TILD LSFT_T(KC_GRV)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [_QWERTY] = LAYOUT_split_3x6_3_ex2(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T, KC_VOLU,    KC_RABK,    KC_Y,    KC_U,    KC_I,    KC_O,   KC_P,  KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL, HM____A, HM____S, HM____D, HM____F,    KC_G, KC_VOLD,    KC_LABK,    KC_H, HM____J, HM____K, HM____L, HM___SC, KC_QUOT,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, KC_CAPS,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                            MO(2), _L1_SPC, _LG_ESC,    _RG_ENT, _L2_SPC,   MO(1)
                                      //`--------------------------'  `--------------------------'

  ),

  [_LOWER] = LAYOUT_split_3x6_3_ex2(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB, XXXXXXX, KC_7   , KC_8   , KC_9   , KC_0   , XXXXXXX,  XXXXXXX,   KC_LBRC, KC_RBRC, KC_INS , XXXXXXX, KC_DEL , KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL, HM__GRV, HM____4, HM____5, HM____6, KC_MINS, XXXXXXX,  XXXXXXX,   KC_LEFT, KC_DOWN,   KC_UP, KC_RGHT, KC_COLN, KC_GRV ,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT, KC_0   , KC_1   , KC_2   , KC_3   , KC_EQL ,                      KC_BSLS, XXXXXXX, KC_LABK, KC_RABK, KC_QUES, KC_RSFT,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LALT, _______, KC_LGUI,    KC_RGUI,   MO(3), KC_RALT
                                      //`--------------------------'  `--------------------------'
  ),

  [_RAISE] = LAYOUT_split_3x6_3_ex2(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
       KC_TAB, XXXXXXX, KC_AMPR, KC_ASTR, KC_LPRN, KC_RPRN, KC_MCTL,  XXXXXXX,   KC_LCBR, KC_RCBR, XXXXXXX, XXXXXXX, KC_DEL , KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LCTL, HM_TILD, HM__DLR, HM_PERC, HM_CIRC, KC_UNDS, KC_MUTE,  XXXXXXX,   KC_HOME, HM_PGDN, HM_PGUP, HM__END, HM_COLN, KC_DQUO,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      KC_LSFT, XXXXXXX, KC_EXLM, KC_AT  , KC_HASH, KC_PLUS,                      KC_PIPE, XXXXXXX, KC_LABK, KC_RABK, KC_QUES, KC_RSFT,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
                                          KC_LALT,   MO(3), KC_LGUI,    KC_RGUI, _______, KC_RALT
                                      //`--------------------------'  `--------------------------'
  ),

  [_ADJUST] = LAYOUT_split_3x6_3_ex2(
  //,-----------------------------------------------------.                    ,-----------------------------------------------------.
      QK_BOOT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,  XXXXXXX,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      RM_TOGG, RM_HUEU, RM_SATU, RM_VALU, XXXXXXX, XXXXXXX, XXXXXXX,  XXXXXXX,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|                    |--------+--------+--------+--------+--------+--------|
      RM_NEXT, RM_HUED, RM_SATD, RM_VALD, XXXXXXX, XXXXXXX,                      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
                                          KC_LGUI, _______,  KC_SPC,     KC_ENT, _______, KC_RALT
                                      //`--------------------------'  `--------------------------'
  )
};

#ifdef ENCODER_MAP_ENABLE
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
  [0] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
  [1] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
  [2] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
  [3] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
};
#endif

bool get_hold_on_other_key_press(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case _LC_GRV:
    case _L1_SPC:
    case _LG_ESC:
    case _RG_ENT:
    case _L2_SPC:
      return true;
    default:
      return false;
  }
}

/*
bool get_ignore_mod_tap_interrupt(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case _LC_GRV:
      return false;
    default:
      return true;
  }
}
*/

/*
bool lower_interrupted = false;
bool raise_interrupted = false;

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
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
*/

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

td_state_t cur_dance(tap_dance_state_t *state) {
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

void _tap_dance_hold_finished(tap_dance_state_t *state, void *user_data) {
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

void _tap_dance_hold_reset(tap_dance_state_t *state, void *user_data) {
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

tap_dance_action_t tap_dance_actions[] = {
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
