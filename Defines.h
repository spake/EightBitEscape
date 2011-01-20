#ifndef DEFINES_H
#define DEFINES_H

// Program states
#define STATE_INTRO        0
#define STATE_MENU         1
#define STATE_PREGAME      2
#define STATE_INGAME       3
#define STATE_GAMEOVER     4
#define STATE_HIGHSCORES   5
#define STATE_NEWHIGHSCORE 6

// Menu defines
#define MENU_ITEM_COUNT  2
#define MENU_ITEM_PLAY   0
#define MENU_ITEM_SCORES 1

#define GAMEOVER_ITEM_COUNT 3
#define GAMEOVER_ITEM_SCORE 0
#define GAMEOVER_ITEM_PLAY  1
#define GAMEOVER_ITEM_QUIT  2

// Custom characters printed to the LCD
// These numbers are used as references; the actual layout of the characters
// is defined elsewhere
#define AIR_CHAR               0b00100000
#define BLOCK_CHAR             0b11111111
#define GROUND_CHAR            0
#define STICKMAN_CHAR_A        1
#define STICKMAN_CHAR_B        2
#define STICKMAN_GROUND_CHAR_A 3
#define STICKMAN_GROUND_CHAR_B 4
#define ENEMY_CHAR_A           5
#define ENEMY_CHAR_B           6
#define DEAD_CHAR              7

// The minimum distance that ground and blocks must go for before switching
// to a different tile type
#define LANDSCAPE_MIN 5

// The probability that the current tile will be repeated when the landscape is
// next updated, as a percentage
// Can be anywhere between 1 and 98, though really high values aren't recommended
#define LANDSCAPE_REPEAT_CHANCE 50

// How many tiles the stickman will jump over when the centre button is pressed
#define JUMP_DISTANCE 2

// Delays (in milliseconds)
// Specifies how long to wait between executing various parts of the game loop
#define DELAY_INPUTS 30
#define DELAY_LCD    170

// Number of high scores to store; probably best not to set this above 9
#define HIGHSCORES_COUNT 3

#endif
