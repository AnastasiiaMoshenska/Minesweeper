class Cell {
  int value;
  int x;
  int y;
  boolean isChecked;
  boolean isOpen;
  boolean isInStack;

  public Cell(int value, int x, int y) {
    this.value = value;
    this.x = x;
    this.y = y;
  }

  public int getValue() {
    return value;
  }

  public int setValue(int value) {
    this.value = value;
    return value;
  }
}
