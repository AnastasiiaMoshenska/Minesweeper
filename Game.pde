static final int CELL_SIZE = 26;
static final int CELL_NUMBER = 9;
static final int BOMB_NUMBER = 10;
static final int OPEN_CELLS_WIN_NUMBER = 71;


class Game {
  int isPlayPressed = 0;
  float y = 80;
  Cell[][] cells = new Cell[CELL_NUMBER][CELL_NUMBER];

  //adjustments
  int adjustmentX = 13;
  int adjustmentY = -55;
  int adjustmentXnumber = 4;
  int adjustmentYnumber = 74;

  int fieldTop = 80;
  int fieldRignth = 246;
  int fieldBottom = 314;
  int fieldLeft = 12;

  boolean isGameFinished = false;
  boolean isDBconnectionOpen = false;
  int openCellCounter = 0;
  Stack<Cell> cellsStack = new Stack<Cell>();


  public Game() {
  }

  public void drawEmptyField() {
    int y = fieldTop;
    for (int i = 0; i < CELL_NUMBER; i++) {
      float x = fieldLeft;
      for (int k = 0; k < CELL_NUMBER; k++) {
        fill(#c0c0c0);
        rect(x, y, CELL_SIZE, CELL_SIZE);
        x+=CELL_SIZE;
      }
      y+=CELL_SIZE;
    }
  }

  public void drawBobmsField() {
    int y = fieldTop;
    for (int i = 0; i < CELL_NUMBER; i++) {
      float x = fieldLeft;
      for (int k = 0; k < CELL_NUMBER; k++) {
        fill(#c0c0c0);
        rect(x, y, CELL_SIZE, CELL_SIZE);
        fill(#2e2a20);
        text(game.cells[i][k].getValue(), x + 10, y + 20);
        x+=CELL_SIZE;
      }
      game.y+=CELL_SIZE;
    }
  }

  public void openCell(int x, int y) {
    fill(#e60000);

    flagImgRed = loadImage("./data/img/flag_red.png");
    flagImgRed.resize(CELL_SIZE, CELL_SIZE);

    if (game.cells[x][y].getValue() == -1 && !game.cells[x][y].isChecked) {
      drawBombsAfterLoss(x, y);
    } else if (!game.cells[x][y].isChecked && !game.cells[x][y].isOpen) {
      info.info = "Playing ...";
      int newCellValue = calculateCellValue(x, y);
      drawCellAfterClick(newCellValue, x, y);
      if (newCellValue == 0) {
        openStack(x, y);
        openCellCounter--;
      }
      game.cells[x][y].isOpen = true;
    }
    fill(#c0c0c0);
    rect(12, 326, 234, 20);
    info.createInfoField();
  }


  int calculateCellValue(int x, int y) {
    return abs(
      hasBomb(x - 1, y - 1) +
      hasBomb(x - 1, y    ) +
      hasBomb(x - 1, y + 1) +
      hasBomb(x, y - 1) +
      hasBomb(x, y + 1) +
      hasBomb(x + 1, y - 1) +
      hasBomb(x + 1, y    ) +
      hasBomb(x + 1, y + 1));
  }

  void drawBombsAfterLoss(int x, int y) {
    info.info = "You lost :-(";
    info.img = "./data/img/face_sad.png";

    bombImg = loadImage("./data/img/bomb.png");
    bombImg.resize(CELL_SIZE - 2, CELL_SIZE - 2);
    for (int i = 0; i < 9; i++) {
      for (int k = 0; k < 9; k++) {

        if (game.cells[i][k].getValue() != -1 && game.cells[i][k].isChecked) {
          image(flagImgRed, game.cells[i][k].x * CELL_SIZE - adjustmentX, game.cells[i][k].y * CELL_SIZE - adjustmentY);
        } else if (game.cells[i][k].getValue() == -1) {
          image(bombImg, game.cells[i][k].x * CELL_SIZE - adjustmentX, game.cells[i][k].y * CELL_SIZE - adjustmentY);
        }
      }
    }

    bombRedImg = loadImage("./data/img/bomb_red.png");
    bombRedImg.resize(CELL_SIZE, CELL_SIZE);
    image(bombRedImg, game.cells[x][y].x * CELL_SIZE - adjustmentX, game.cells[x][y].y * CELL_SIZE - adjustmentY);

    game.isGameFinished = true;
    info.createStartBtn();
    game.isDBconnectionOpen = true;
  }

  void drawCellAfterClick(int newCellValue, int x, int y) {
    addCellValueColor(newCellValue);
    if (newCellValue == 0) {
      rect((x + 1) * CELL_SIZE - adjustmentX - 1, (y + 1) * CELL_SIZE - adjustmentY - 1, CELL_SIZE, CELL_SIZE);
      makeInStack(x, y);
    } else {
      fill(#c0c0c0);
      rect((x + 1) * CELL_SIZE - adjustmentXnumber - 10, (y + 1) * CELL_SIZE + adjustmentYnumber - 20, CELL_SIZE, CELL_SIZE);
      addCellValueColor(newCellValue);
      text(newCellValue, (x + 1) * CELL_SIZE - adjustmentXnumber, (y + 1) * CELL_SIZE + adjustmentYnumber);
    }
    makeOpen(x, y);
  }

  void addCellValueColor(int newCellValue) {
    if (newCellValue == 0) {
      fill(#d9d9d9);
    } else if (newCellValue == 1) {
      fill(#0373fc);
    } else if (newCellValue == 2) {
      fill(#588c56);
    } else {
      fill(#c70828);
    }
  }

  void openStack(int coordX, int coordY) {
    if (coordX >= 0 && coordX < 9 && coordY >= 0 && coordY < 9) {
      cellsStack.push(game.cells[coordX][coordY]);
      checkCorners(coordX, coordY);
      openCellCounter++;
    }

    while (cellsStack.size() > 0) {
      Cell cellFromStack = cellsStack.pop();
      cellFromStack.x--;
      cellFromStack.y--;

      openOneDirection(cellFromStack.x + 1, cellFromStack.y);
      openOneDirection(cellFromStack.x, cellFromStack.y + 1);
      openOneDirection(cellFromStack.x - 1, cellFromStack.y);
      openOneDirection(cellFromStack.x, cellFromStack.y - 1);
    }
  }

  void openOneDirection(int x, int y) {
    println(x + " " + y);
    int cellValue = 0;
    if (hasBomb(x, y) != -1 && !isChecked(x, y)) {
      cellValue = calculateCellValue(x, y);
      if (cellValue == 0 && !isInStack(x, y)) {
        checkCorners(x, y);
        cellsStack.push(takeCell(x, y));
        drawCellAfterClick(cellValue, x, y);
      } else if (cellValue != 0 && !isInStack(x, y)) {
        drawCellAfterClick(cellValue, x, y);
      }
    }
  }


  void checkCorners(int x, int y) {
    if (!isOpen(x - 1, y - 1) && calculateCellValue(x - 1, y - 1) != 0 && !isChecked(x - 1, y - 1)) {
      drawCellAfterClick(calculateCellValue(x - 1, y - 1), x - 1, y - 1);
      makeOpen(x - 1, y - 1);
    }
    if (!isOpen(x - 1, y + 1) && calculateCellValue(x - 1, y + 1) != 0 && !isChecked(x - 1, y + 1)) {
      drawCellAfterClick(calculateCellValue(x - 1, y + 1), x - 1, y + 1);
      makeOpen(x - 1, y + 1);
    }
    if (!isOpen(x + 1, y - 1) && calculateCellValue(x + 1, y - 1) != 0 && !isChecked(x + 1, y - 1)) {
      drawCellAfterClick(calculateCellValue(x + 1, y - 1), x + 1, y - 1);
      makeOpen(x + 1, y - 1);
    }
    if (!isOpen(x + 1, y + 1) && calculateCellValue( x + 1, y + 1) != 0 && !isChecked(x + 1, y + 1)) {
      drawCellAfterClick(calculateCellValue( x + 1, y + 1), x + 1, y + 1);
      makeOpen(x + 1, y + 1);
    }
  }

  Cell takeCell(int x, int y) {
    if (x >= 0 && x < CELL_NUMBER && y >= 0 && y < CELL_NUMBER) {
      return cells[x][y];
    } else {
      return null;
    }
  }

  boolean isOpen(int x, int y) {
    if (x >= 0 && x < CELL_NUMBER && y >= 0 && y < CELL_NUMBER) {
      return cells[x][y].isOpen;
    } else {
      return true;
    }
  }

  boolean isInStack(int x, int y) {
    if (x >= 0 && x < CELL_NUMBER && y >= 0 && y < CELL_NUMBER) {
      return cells[x][y].isInStack;
    } else {
      return true;
    }
  }

  void makeInStack(int x, int y) {
    if (x >= 0 && x < CELL_NUMBER && y >= 0 && y < CELL_NUMBER) {
      cells[x][y].isInStack = true;
    } else {
      cells[x][y].isInStack = false;
    }
  }

  void makeOpen(int x, int y) {
    if (x >= 0 && x < CELL_NUMBER && y >= 0 && y < CELL_NUMBER && !cells[x][y].isOpen) {
      //println(x, y);
      cells[x][y].isOpen = true;
      openCellCounter++;
    }
  }

  int hasBomb(int x, int y) {
    if (x >= 0 && x < CELL_NUMBER && y >= 0 && y < CELL_NUMBER) {
      return cells[x][y].getValue();
    } else {
      return 0;
    }
  }
  
    boolean isChecked(int x, int y) {
    if (x >= 0 && x < CELL_NUMBER && y >= 0 && y < CELL_NUMBER) {
      return cells[x][y].isChecked;
    } else {
      return false;
    }
  }

  void addBombsToArray(int x, int y) {
    Random rand = new Random();
    int counter = 0;
    while (counter < BOMB_NUMBER) {
      int coordX = rand.nextInt(9);
      int coordY = rand.nextInt(9);
      if (game.cells[coordX][coordY].getValue() == 0 && coordY + 1 != y && coordX + 1 != x) {
        game.cells[coordX][coordY] = new Cell(-1, coordX + 1, coordY + 1);
        counter++;
      }
    }
  }

  void initArray() {
    for (int i = 0; i < CELL_NUMBER; i++) {
      for (int k = 0; k < CELL_NUMBER; k++) {
        game.cells[i][k] = new Cell(0, i + 1, k + 1);
      }
    }
  }

  void switchFlag(boolean isChecked, int x, int y) {
    if (isChecked) {
      flagImg = loadImage("./data/img/flag.png");
      flagImg.resize(CELL_SIZE, CELL_SIZE);
      image(flagImg, game.cells[x][y].x * CELL_SIZE - game.adjustmentX, game.cells[x][y].y * CELL_SIZE - game.adjustmentY, CELL_SIZE - 2, CELL_SIZE - 2);
      info.bombs--;
      info.createBombsField();
    } else if (!isChecked) {
      fill(#c0c0c0);
      rect(game.cells[x][y].x * CELL_SIZE - game.adjustmentX - 1, game.cells[x][y].y * CELL_SIZE  - game.adjustmentY - 1, CELL_SIZE, CELL_SIZE);
      info.bombs++;
      info.createBombsField();
    }
  }
}
