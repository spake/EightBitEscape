#include "EEPROM.h"

// High scores are laid out like so:
// Byte 0: Score high byte
// Byte 1: Score low byte
// Byte 2: Name character 1
// Byte 3: Name character 2
// Byte 4: Name character 3

// Some variables for caching high scores, since we don't really need to read
// the EEPROM every time we want to refresh the LCD
unsigned int highScoresCache[HIGHSCORES_COUNT];
char highScoresLetterCache[HIGHSCORES_COUNT][3];

// These are used to temporarily store the high score position and three letters
// during new high score entry
char tmp[3];
int pos;

void resetHighScore(int n) {
  setHighScore(n, 0);
  setHighScoreLetter(n, 0, 'A');
  setHighScoreLetter(n, 1, 'A');
  setHighScoreLetter(n, 2, 'A');
}

void setHighScoreLetter(int n, int index, char letter) {
  EEPROM.write(n * 5 + 2 + index, letter);
}

char getHighScoreLetter(int n, int index) {
  char letter = EEPROM.read(n * 5 + 2 + index);
  if (letter == 0xFF) {
    // This high score hasn't been set before; reset it
    resetHighScore(n);
  }
}

void setHighScore(int n, unsigned int score) {
  // Chop up score
  byte a = highByte(score);
  byte b = lowByte(score);
  // And write these bytes
  EEPROM.write(n * 5, a);
  EEPROM.write(n * 5 + 1, b);
}

unsigned int getHighScore(int n) {
  // Read bytes from EEPROM
  byte a = EEPROM.read(n * 5);
  byte b = EEPROM.read(n * 5 + 1);
  // Are they both equal to 0xFF?
  // If so, we just haven't set high scores yet and it should be
  // reset to 0
  if (a == 0xFF && b == 0xFF) {
    resetHighScore(n);
  }
  return word(a, b);
}

void populateHighScoresCache() {
  for (int i = 0; i < HIGHSCORES_COUNT; i++) {
    highScoresCache[i] = getHighScore(i);
    highScoresLetterCache[i][0] = getHighScoreLetter(i, 0);
    highScoresLetterCache[i][1] = getHighScoreLetter(i, 1);
    highScoresLetterCache[i][2] = getHighScoreLetter(i, 2);
  }
}
