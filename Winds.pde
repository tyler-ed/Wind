void run_cells() {
  if (key_down[0]) { 
    for (int x = floor(-20/scale); x<floor(20/scale)+2; x++) { //Access all cells within a radius of the mouse
      float h = sqrt(400/pow(scale, 2)-pow(x, 2));
      for (int y = floor(-h); y<floor(h)+2; y++) {
        //Store position of nearby cell
        int px = floor(mouseX/scale)+x;
        int py = floor(mouseY/scale)+y;
        if (px>-1 && px<cells.length && py>-1 && py<cells[px].length) {
          cells[px][py].blow_from(mouse.copy()); //Create wind from mouse at nearby cell
        }
      }
    }
  }
  for (Cell[] c2 : cells) {
    for (Cell c1 : c2) {
      c1.mail();
    }
  }
  for (Cell[] c2 : cells) {
    for (Cell c1 : c2) {
      c1.catch_up();
    }
  }
}
class Cell {
  int posX;
  int posY;
  PVector pos = new PVector(0, 0); //Cell position as a vector
  int scale = 1;
  PVector wind = new PVector(0, 0); //Wind vector
  PVector d_wind = new PVector(0, 0); //Change in wind vector this frame
  Cell(int px, int py, int g) {
    scale = g;
    posX = px;
    posY = py;
    pos.set(px, py);
  }
  void mail() {

    if ((posX-3)%6+(posY-3)%6==0&&posX>2 && posY>2) {//Display wind vectors as lines on screen
      if (wind.mag()>.1) {
        animation();
      }
    }
    update();
  }
  void catch_up() {
    wind.set(d_wind);
    d_wind.set(0, 0);
  }
  void animation() {
    strokeWeight(1);
    stroke(0);
    //Draw wind
    line((posX+.5)*scale, (posY+.5)*scale, (posX+.5)*scale+2.0*wind.x/(5), (posY+.5)*scale+2.0*wind.y/(5));
  }
  void update() {
    if (wind.mag()>0) { //Bleed into adjacent cells
      for (int a=0; a<8; a++) {
        float ang = a*PI/4;
        float dot = PVector.dot(wind, PVector.fromAngle(ang)); //Dot between relative position and wind vector
        if (dot>0) { //If wind bleeds in that direction
          int nx = posX + floor(cos(ang)+.5);
          int ny = posY + floor(sin(ang)+.5);
          if (nx>-1 && nx<cells.length && ny>-1 && ny<cells[nx].length) {
            cells[nx][ny].d_wind.add(PVector.fromAngle(ang).mult(.5*dot)); //Change wind next frame
          }
        }
      }
    }
  }
  void blow_from(PVector m) {
    d_wind.add(m.sub(pos.copy().mult(scale)).mult(-50/(pow(m.mag(), 2)+1))); //Create wind
  }
}
