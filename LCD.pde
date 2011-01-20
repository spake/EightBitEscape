// Used to track the stickman in the menu animation
int index = 0;

// This is constantly toggled to switch between stickman images A and B
// to create the poor sense of movement
boolean anim = false;

// This variable is used to keep track of how many times the newest tile has
// been used in the landscape. We keep track of this to ensure that ground & block
// tiles are repeated enough to allow the player to run a bit before the next jump.
int tileUses = 0;

void updateLCD() {
  lcd.clear();
  anim = !anim;
  
  if (state == STATE_INTRO) {
    lcd.setCursor(0, 1);
    lcd.print("  8-BIT ESCAPE  ");
    
    // Print out a little intro animation
    lcd.setCursor(index, index < 2 || index == 7 || index > 13 ? 1 : 0);
    lcd.write(anim ? STICKMAN_CHAR_A : STICKMAN_CHAR_B);
    
    if (index == 15) {
      state = STATE_MENU;
      menuIndex = 0;
      index = 0;
    } else {
      index++;
    }
  } else if (state == STATE_MENU || state == STATE_PREGAME) {
    lcd.print(state == STATE_PREGAME ? "GOOD LUCK!" : menuItems[menuIndex]);
    
    // Print the ground on line 1
    lcd.setCursor(0, 1);
    for (int i = 0; i < 16; i++) {
      lcd.write(GROUND_CHAR);
    }
    
    // And print the stickman as well
    lcd.setCursor(index, 1);
    lcd.write(anim ? STICKMAN_GROUND_CHAR_A : STICKMAN_GROUND_CHAR_B);
    index = (index + 1) % 16;
    
    // If we've hit index 7 and we're in the pre-game state,
    // it's time to start the game!
    if (index == 7 && state == STATE_PREGAME) {
      state = STATE_INGAME;
    }
  } else if (state == STATE_INGAME) {    
    // Print the landscape
    lcd.setCursor(0, 1);
    for (int i = 0; i < 16; i++) {
      lcd.write(landscape[i]);
    }
    
    // Print the stickman and evaluate whether they're still alive
    byte behind = landscape[6];
    byte here = landscape[7];
    
    if (jump > 0 || (here == BLOCK_CHAR && behind == BLOCK_CHAR)) {
      // Firstly, if we're here because we're the block, disable jumping
      // There is no third row of the LCD to jump to!!
      if (here == BLOCK_CHAR && behind == BLOCK_CHAR) {
        jump = 0;
      }
      
      // If we're either in the middle of jumping, or we're on top of a block,
      // draw the stickman on the LCD's top row
      lcd.setCursor(7, 0);
      // This funky conditional stops the stickman flailing about in midair
      // (i.e. halts animation when jumping)
      if (jump > 0 && here != BLOCK_CHAR) {
        anim = true;
      }
      lcd.write(anim ? STICKMAN_CHAR_A : STICKMAN_CHAR_B);
    } else {
      // Otherwise we're at ground level
      lcd.setCursor(7, 1);
      if (here == GROUND_CHAR) {
        // Everything's cool; we're on solid ground
        lcd.write(anim ? STICKMAN_GROUND_CHAR_A : STICKMAN_GROUND_CHAR_B);
      } else if ((here == BLOCK_CHAR && behind == GROUND_CHAR) || here == AIR_CHAR || here == ENEMY_CHAR_A || here == ENEMY_CHAR_B) {
        // Uh oh, we're dead... the stickman either ran into a block or fell down
        // a hole, or got eaten by one of those robot thingies
        
        // Check if we got a high score
        pos = -1;
        for (int i = 0; i < HIGHSCORES_COUNT; i++) {
          if (score > highScoresCache[HIGHSCORES_COUNT - i - 1]) {
            pos = HIGHSCORES_COUNT - i - 1;
          }
        }
        
        if (pos > -1) {
          // Yay high score!
          state = STATE_NEWHIGHSCORE;
          menuIndex = 0;
          tmp[0] = 'A';
          tmp[1] = 'A';
          tmp[2] = 'A';
        } else {
          state = STATE_GAMEOVER;
          
          // Setup the game over menu
          landscape[7] = DEAD_CHAR;
          menuIndex = 0;
        }
      }
    }
    
    // And if we're still playing...
    if (state == STATE_INGAME) {
      // ...we update the landscape!
      for (int i = 0; i < 15; i++) {
        landscape[i] = landscape[i + 1];
        // Also, switch the animation around if it's a ENEMY
        if (landscape[i] == ENEMY_CHAR_A) {
          landscape[i] = ENEMY_CHAR_B;
        } else if (landscape[i] == ENEMY_CHAR_B) {
          landscape[i] = ENEMY_CHAR_A;
        }
      }
      byte prev = landscape[14];
      byte* next = &landscape[15];
      if (prev == AIR_CHAR || prev == ENEMY_CHAR_A || prev == ENEMY_CHAR_B) {
        // Holes and ENEMYs can only be 1 wide, and must be followed by ground
        *next = GROUND_CHAR;
        tileUses = 1;
      } else if (prev == GROUND_CHAR || prev == BLOCK_CHAR) {
        // Check whether we've repeated the tile enough
        if (tileUses < LANDSCAPE_MIN) {
          *next = prev;
          tileUses++;
        } else {
          // Use the pseudo random number generator to decide whether to
          // continue with the same tile or switch to a new one
          // We generate a value between 1 and 100 (percentages!) and use
          // LANDSCAPE_REPEAT_CHANCE (Defines.h) to decide on the course
          // of action.
          int rand = random(1, 100);
          if (rand <= LANDSCAPE_REPEAT_CHANCE) {
            // Yay, we continue with whatever we had before.
            *next = prev;
          } else if (rand <= 100 - ((LANDSCAPE_REPEAT_CHANCE / 3) * 2) && prev == GROUND_CHAR) {
            // Note: the '&& prev == GROUND_CHAR' is to ensure there are no gaps in the
            // landscape after a line of blocks; stickmen jumping off cliffs can get
            // very messy
            *next = AIR_CHAR;
          } else if (rand <= 100 - (LANDSCAPE_REPEAT_CHANCE / 3) && prev == GROUND_CHAR) {
            // Same deal here; jumping to the third level doesn't work on a 2-high LCD,
            // so no ENEMYs on top of blocks
            *next = anim ? ENEMY_CHAR_A : ENEMY_CHAR_B;
          } else {
            // Start a line of blocks if the previous tile was ground, and vice versa.
            *next = prev == GROUND_CHAR ? BLOCK_CHAR : GROUND_CHAR;
            tileUses = 1;
          }
        }
      }
      
      // Also decrement the jump to make sure the stickman doesn't float away
      if (jump > 0) {
        jump--;
      }
      
      // Rewards!
      score++;
    }
  } else if (state == STATE_GAMEOVER) {
    if (menuIndex == GAMEOVER_ITEM_SCORE) {
      lcd.print("< SCORE: ");
      lcd.print(score);
      lcd.setCursor(15, 0);
      lcd.print(">");
    } else if (menuIndex == GAMEOVER_ITEM_PLAY) {
      lcd.print("<  PLAY AGAIN  >");
    } else if (menuIndex == GAMEOVER_ITEM_QUIT) {
      lcd.print("<RETURN TO MENU>");
    }
    
    // Print the final landscape out (with the gravestone)
    lcd.setCursor(0, 1);
    for (int i = 0; i < 16; i++) {
      lcd.write(landscape[i]);
    }
  } else if (state == STATE_NEWHIGHSCORE) {
    if (menuIndex == 3) {
      // If the user has finished entering their three letters, store the high score
      // in the EEPROM
      
      // But first, shift the lower high scores down to make room
      for (int i = pos + 1; i < HIGHSCORES_COUNT; i++) {
        setHighScore(i, highScoresCache[i - 1]);
        setHighScoreLetter(i, 0, highScoresLetterCache[i - 1][0]);
        setHighScoreLetter(i, 1, highScoresLetterCache[i - 1][1]);
        setHighScoreLetter(i, 2, highScoresLetterCache[i - 1][2]);
      }
      
      setHighScore(pos, score);
      setHighScoreLetter(pos, 0, tmp[0]);
      setHighScoreLetter(pos, 1, tmp[1]);
      setHighScoreLetter(pos, 2, tmp[2]);
      populateHighScoresCache();
      
      // Return to the high scores menu
      state = STATE_HIGHSCORES;
      menuIndex = pos;
    } else {
      // Otherwise, print a fancy banner!
      lcd.print("NEW HIGH SCORE ");
      lcd.write(anim ? STICKMAN_CHAR_A : STICKMAN_CHAR_B);
      lcd.setCursor(0, 1);
      
      // And print the three letters that the user is in the process of selecting
      for (int i = 0; i < 3; i++) {
        if (menuIndex == i) {
          lcd.print("<");
          lcd.write(tmp[i]);
          lcd.print(">");
        } else {
          lcd.write(tmp[i]);
        }
      }
      lcd.print(" ");
      lcd.print(score);
    }
  } else if (state == STATE_HIGHSCORES) {
    if (menuIndex == HIGHSCORES_COUNT) {
      // The last menu item
      lcd.print("<RETURN TO MENU>");
    } else {
      // Print out some cardinal stuff
      lcd.print("< ");
      lcd.print(menuIndex + 1);
      lcd.print(menuIndex == 0 ? "ST" : menuIndex == 1 ? "ND" : menuIndex == 2 ? "RD" : "TH");
      lcd.print(" PLACE");
      lcd.setCursor(15, 0);
      lcd.print(">");
      
      // Followed by the high score data
      lcd.setCursor(2, 1);
      lcd.print(highScoresLetterCache[menuIndex][0]);
      lcd.print(highScoresLetterCache[menuIndex][1]);
      lcd.print(highScoresLetterCache[menuIndex][2]);
      lcd.print(" ");
      lcd.print(highScoresCache[menuIndex]);
    }
  }
}
