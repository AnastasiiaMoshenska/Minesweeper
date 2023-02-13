import controlP5.*;
import java.util.*;
import de.bezier.data.sql.*;

ControlP5 cp5;

PImage flagImg;
PImage flagImgRed;
PImage btnImg;
PImage bombImg;
PImage bombRedImg;

ControlTimer gameTimer;
Textlabel gameTimerTextField;
Textlabel gameScore;
Textlabel bestScores;
Button startBtn;
boolean isGameStarted = false;
boolean isBtnInFocusAfterFinish = false;

SQLite db;
String[] bestResults = {"00 : 00 : 00", "00 : 00 : 00", "00 : 00 : 00"};

Game game = new Game();
Info info = new Info();

void setup() {
  fill(#c0c0c0);
  size(260, 452);
  cp5 = new ControlP5(this);

  info.createTimer();
  info.createStartBtn();
  info.createBombsField();

  game.drawEmptyField();
  rect(12, 326, 234, 20);
  info.createInfoField();
  info.createScoreField();


  if (!game.isDBconnectionOpen) {
    showResultsDB();
    game.isDBconnectionOpen = true;
  }
}

void draw() {

  fill(#c0c0c0);
  rect(11, 11, 234, 48);

  gameTimerTextField.draw(this);
  gameScore.draw(this);

  if (game.isPlayPressed >= 2) {
    gameTimer.setSpeedOfTime(1);
    gameTimerTextField.setValue(gameTimer.toString());
    //gameTimerTextField.draw(this);
  }

  //fix for the button
  if (mouseX > 110 && mouseX < 150 && mouseY > 15 && mouseY < 55 && game.isGameFinished) {
    isBtnInFocusAfterFinish = true;
  } else {
    isBtnInFocusAfterFinish = false;
  }

  if (info.bombs == 0 && game.openCellCounter == OPEN_CELLS_WIN_NUMBER && game.isDBconnectionOpen) {
    winingMessage();
    writeResultsDB();
    showResultsDB();
    game.isDBconnectionOpen = false;
  }
}

void writeResultsDB() {
  db = new SQLite( this, "data/db.sqlite" );  // open database file
  try {
    if ( db.connect() )
    {
      db.query("INSERT INTO Score VALUES(\"" + gameTimer.toString() + "\")");
    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  db.close();
}

void showResultsDB() {
  int i = 0;
  db = new SQLite( this, "data/db.sqlite" );  // open database file
  try {
    if ( db.connect() )
    {
      game.isDBconnectionOpen = true;
      db.query("SELECT time FROM Score ORDER BY time ASC");
      //db.query("SELECT * FROM Score");
      while (db.next() && i < 3) {
        bestResults[i] = db.getString("time");
        i++;
      }
    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  fill(#c0c0c0);
  rect(12, 376, 234, 66);
  fill(#a8813e);
  textSize(16);
  text(bestResults[0], 16, 394);
  text(bestResults[1], 16, 414);
  text(bestResults[2], 16, 434);
  i++;
  db.close();
}

void winingMessage() {
  fill(#c0c0c0);
  rect(12, 326, 234, 20);
  info.info = "Congradulations, you won!";
  info.createInfoField();
  game.isPlayPressed = 0;
  game.isGameFinished = true;
}


void mouseClicked() {
  if (!isGameStarted) {
    startGame();
  }

  //fix for the button
  if (isBtnInFocusAfterFinish) {
    info.img = "./data/img/face_happy.png";
    game.isGameFinished = false;
    info.createStartBtn();
    fill(#c0c0c0);
    rect(12, 326, 234, 20);
    info.info = "Press any cell!";
    info.createInfoField();
  }
}

void startGame() {
  game.initArray();
  int x = (mouseX + game.adjustmentX) / CELL_SIZE;
  int y = (mouseY + game.adjustmentY) / CELL_SIZE;

  for (int i = 0; i < CELL_NUMBER; i++) {
    for (int k = 0; k < CELL_NUMBER; k++) {
      if (x == game.cells[i][k].x && y == game.cells[i][k].y) {
        game.addBombsToArray(x, y);
        gameTimer = new ControlTimer();
        game.isPlayPressed++;
      }
    }
  }
}

void mousePressed() {
  if (mouseX > game.fieldLeft && mouseX < game.fieldRignth && mouseY > game.fieldTop && mouseY < game.fieldBottom && !game.isGameFinished) {
    if (!isGameStarted) {
      startGame();
      game.openCellCounter = 0;
      isGameStarted = true;
    }

    int x = (mouseX + game.adjustmentX) / CELL_SIZE - 1;
    int y = (mouseY + game.adjustmentY) / CELL_SIZE - 1;
    if (mouseButton == LEFT) {
      game.openCell(x, y);
    } else if (mouseButton == RIGHT) {
      Cell activeCell = game.cells[x][y];
      if (info.bombs > 0 && !activeCell.isChecked && !activeCell.isOpen) {
        activeCell.isChecked = true;
        game.switchFlag(activeCell.isChecked, x, y);
      } else if (activeCell.isChecked) {
        activeCell.isChecked = false;
        game.switchFlag(activeCell.isChecked, x, y);
      }
    }
  }
}

public void play() {
  if (!game.isGameFinished) {
    game.drawEmptyField();
    game.isPlayPressed = 1;
    info.createTimer();
    isGameStarted = false;
    info.bombs = BOMB_NUMBER;
    info.createBombsField();
  } else {
    game.isPlayPressed = 0;
  }
}
