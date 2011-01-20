// These variables hold the current and previous states of the various
// buttons attached to the board
int leftButtonState, leftButtonPrev;
int rightButtonState, rightButtonPrev;
int centreButtonState, centreButtonPrev;
boolean leftButtonClicked, rightButtonClicked, centreButtonClicked;

// This variable is used to ensure that:
// (1) We don't compare the current state with the previous state before
//     a previous state has been recorded
// (2) A button held down as the game ends will not immediately affect the
//     next screen
boolean firstCheck = true;

void setupPreGame() {
  // It's time to play!
  // Clear out the landscape and reset some other stuff before switching the state
  for (int i = 0; i < 16; i++) {
    landscape[i] = GROUND_CHAR;
  }
  jump = 0;
  score = 0;
  
  // The pre-game state transitions between the menu animation and the game
  state = STATE_PREGAME;
}

void checkInputs() {
  leftButtonPrev = leftButtonState;
  rightButtonPrev = rightButtonState;
  centreButtonPrev = centreButtonState;
  
  leftButtonState = digitalRead(leftButton);
  rightButtonState = digitalRead(rightButton);
  centreButtonState = digitalRead(centreButton);
  
  leftButtonClicked = leftButtonPrev != leftButtonState && leftButtonState == LOW;
  rightButtonClicked = rightButtonPrev != rightButtonState && rightButtonState == LOW;
  centreButtonClicked = centreButtonPrev != centreButtonState && centreButtonState == LOW;
  
  // If we haven't checked the inputs before, then we won't have previous
  // values to compare the current ones against.
  // That's where firstCheck comes in. If it's true, we'll take a break this
  // time 'round.
  if (!firstCheck) {
    if (state == STATE_MENU) {
      if (centreButtonClicked) {
        // Select the current menu item
        if (menuIndex == MENU_ITEM_PLAY) {
          setupPreGame();
        } else if (menuIndex == MENU_ITEM_SCORES) {
          state = STATE_HIGHSCORES;
          menuIndex = 0;
        }
      } else if (leftButtonClicked) {
        // Go left in the menu
        menuIndex = menuIndex > 0 ? menuIndex - 1 : MENU_ITEM_COUNT - 1;
      } else if (rightButtonClicked) {
        // Go right in the menu
        menuIndex = (menuIndex + 1) % MENU_ITEM_COUNT;
      }
    } else if (state == STATE_INGAME) {
      if (centreButtonClicked) {
        // If the player isn't already jumping, jump!
        if (jump == 0) {
          jump = JUMP_DISTANCE;
        }
      }
    } else if (state == STATE_GAMEOVER) {
      // Essentially the same as STATE_MENU but with... a different menu!
      if (centreButtonClicked) {
        if (menuIndex == GAMEOVER_ITEM_PLAY) {
          setupPreGame();
        } else if (menuIndex == GAMEOVER_ITEM_QUIT) {
          state = STATE_MENU;
          menuIndex = 0;
        }
      } else if (leftButtonClicked) {
        menuIndex = menuIndex > 0 ? menuIndex - 1 : GAMEOVER_ITEM_COUNT - 1;
      } else if (rightButtonClicked) {
        menuIndex = (menuIndex + 1) % GAMEOVER_ITEM_COUNT;
      }
    } else if (state == STATE_HIGHSCORES) {
      // And again, another menu...
      if (centreButtonClicked) {
        if (menuIndex == HIGHSCORES_COUNT) {
          state = STATE_MENU;
          menuIndex = 0;
        }
      } else if (leftButtonClicked) {
        menuIndex = menuIndex > 0 ? menuIndex - 1 : HIGHSCORES_COUNT;
      } else if (rightButtonClicked) {
        menuIndex = (menuIndex + 1) % (HIGHSCORES_COUNT + 1);
      }
    } else if (state == STATE_NEWHIGHSCORE) {
      // Yay, more menus!</sarcasm>
      if (centreButtonClicked) {
        menuIndex++;
      } else if (leftButtonClicked) {
        tmp[menuIndex] = tmp[menuIndex] > 'A' ? tmp[menuIndex] - 1 : 'Z';
      } else if (rightButtonClicked) {
        tmp[menuIndex] = tmp[menuIndex] < 'Z' ? tmp[menuIndex] + 1 : 'A';
      }
    }
  } else {
    firstCheck = false;
  }
}
