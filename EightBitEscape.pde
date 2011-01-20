#include "LiquidCrystal.h"
#include "Defines.h"

// Define the LCD and custom characters
LiquidCrystal lcd(5, 4, 14, 17, 15, 16);

byte groundChar[8] = {
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b00000,
  0b11111
};

byte stickmanCharA[8] = {
  0b00110,
  0b00110,
  0b11101,
  0b00110,
  0b00100,
  0b11010,
  0b00001,
  0b00000
};

byte stickmanCharB[8] = {
  0b00110,
  0b00110,
  0b01100,
  0b10111,
  0b00100,
  0b01011,
  0b10000,
  0b00000
};

byte stickmanGroundCharA[8] = {
  0b00110,
  0b00110,
  0b11101,
  0b00110,
  0b00100,
  0b11010,
  0b00001,
  0b11111
};

byte stickmanGroundCharB[8] = {
  0b00110,
  0b00110,
  0b01100,
  0b10111,
  0b00100,
  0b01011,
  0b10000,
  0b11111
};

byte enemyCharA[8] = {
  0b01110,
  0b10101,
  0b11111,
  0b00000,
  0b11111,
  0b11111,
  0b01010,
  0b01010
};

byte enemyCharB[8] = {
  0b00000,
  0b01110,
  0b10101,
  0b11111,
  0b11111,
  0b11111,
  0b01010,
  0b01010
};

byte deadChar[8] = {
  0b00100,
  0b01110,
  0b00100,
  0b00100,
  0b01110,
  0b11111,
  0b11111,
  0b11111
};

// Buttons
int leftButton = 3;
int rightButton = 2;
int centreButton = 6;

// The current program state
int state = STATE_INTRO;

// Timers
unsigned long inputsTimer = 0;
unsigned long lcdTimer = 0;

// Menu items and the index of the selected menu item
char* menuItems[MENU_ITEM_COUNT] = {
  "<     PLAY     >",
  "<  HIGH SCORES >"
};
int menuIndex = 0;

// The number of tiles the current jump has crossed; 0 indicates not currently jumping
int jump = 0;

// Game score
int score = 0;

// The current landscape in the game
byte landscape[16];

void setup() {
  // Set the random number generator's seed to the noise on analog pin 5
  randomSeed(analogRead(5));
  
  // Setup pins
  pinMode(leftButton, INPUT);
  pinMode(rightButton, INPUT);
  pinMode(centreButton, INPUT);
  digitalWrite(leftButton, HIGH);
  digitalWrite(rightButton, HIGH);
  digitalWrite(centreButton, HIGH);
  
  // Set up the LCD and custom characters
  lcd.begin(16, 2);
  lcd.createChar(GROUND_CHAR, groundChar);
  lcd.createChar(STICKMAN_CHAR_A, stickmanCharA);
  lcd.createChar(STICKMAN_CHAR_B, stickmanCharB);
  lcd.createChar(STICKMAN_GROUND_CHAR_A, stickmanGroundCharA);
  lcd.createChar(STICKMAN_GROUND_CHAR_B, stickmanGroundCharB);
  lcd.createChar(ENEMY_CHAR_A, enemyCharA);
  lcd.createChar(ENEMY_CHAR_B, enemyCharB);
  lcd.createChar(DEAD_CHAR, deadChar);
  
  if (digitalRead(leftButton) == LOW && digitalRead(centreButton) == LOW && digitalRead(rightButton) == LOW) {
    // If all three buttons are being held down, reset the high scores
    for (int i = 0; i < HIGHSCORES_COUNT; i++) {
      resetHighScore(i);
    }
  }
  
  // Populate high scores cache
  populateHighScoresCache();
}

void loop() {
  if (millis() > inputsTimer) {
    checkInputs();
    inputsTimer = millis() + DELAY_INPUTS;
  }
  
  if (millis() > lcdTimer) {
    updateLCD();
    lcdTimer = millis() + DELAY_LCD;
  }
}
