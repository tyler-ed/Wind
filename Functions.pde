class Slider {
  String name;
  boolean held;
  int posX;
  int posY;
  int size;
  float pos;
  float posMax; //max and min
  float posMin;
  int dia;
  float step;
  Slider(int y, int min, int max, int def, String namer, float stepr) {
    size=120;//animation size
    posX=605+40;
    posY=y;
    pos=0;//Control value!
    dia=20;
    posMax=max;
    posMin=min;
    name=namer;
    pos=def;
    step=stepr;
  }
  void animation() {
    if(released){
      held=false;
    }
    strokeWeight(dia/4);
    stroke(#7DC2E5);
    fill(0);
    text(name+": "+floor(pos*100)*1.0/100, posX, posY-15);
    line(posX, posY, posX+size, posY);
    noStroke();
    fill(#7DC2E5);
    ellipse(posX+map(pos, posMin, posMax, 0, size), posY, dia, dia);
    if (dist(mouseX, mouseY, posX+map(pos, posMin, posMax, 0, size), posY)<=dia/2&&mousePressed) { //Mouse on knob
      held=true;
    }
    if (held) {
      pos=map(mouseX-posX, 0, size, posMin, posMax); //Slide knob
      pos=pos-pos%step;
      if (abs(pos-((posMax+posMin)/2))>(posMax-posMin)/2) { //Outside min and max bounds
        pos=(posMax+posMin)/2+.5*(posMax-posMin)*(mouseX-(posX+size/2))/abs(mouseX-(posX+size/2)); //Bring it back in bounds
      }
    }
  }
}
