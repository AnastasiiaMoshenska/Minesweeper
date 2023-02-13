class Info {
  int bombs = BOMB_NUMBER;
  String info = "Press any cell!";
  String img = "./data/img/face_happy.png";

  public Info() {
  }

  void createBombsField() {
    gameScore = cp5.addTextlabel("bombsLabel")
      .setText("Bombs: " + bombs)
      .setPosition(16, 26)
      .setColor(#160ac4)
      .setFont(createFont("arial", 14));
  }
  
    void createInfoField() {
    gameScore = cp5.addTextlabel("infoLabel")
      .setText(info)
      .setPosition(12, 326)
      .setColor(#3293a8)
      .setFont(createFont("arial", 14));
  }
  
     void createScoreField() {
    bestScores = cp5.addTextlabel("infoLabel")
      .setText("Best scores:")
      .setPosition(6, 356)
      .setColor(#a8813e)
      .setFont(createFont("arial", 14));
  }

  void createStartBtn() {
    btnImg = loadImage(img);
    btnImg.resize(40, 40);
    startBtn = cp5.addButton("play")
      .setValue(10)
      .setPosition(110, 15)
      .setSize(40, 40)
      .setImage(btnImg);
  }

  void createTimer() {
    gameTimerTextField = cp5.addTextlabel("timerLabel")
      .setText("00 : 00 : 00")
      .setPosition(158, 26)
      .setColor(#160ac4)
      .setFont(createFont("arial", 14));
  }
}
