boolean released;
boolean start = false;
boolean go = true;
//wind grid
boolean gravity = false;
float ag = .02;

float r2 = sqrt(2);

//Sandbox Dimensions
int c_width = 600;
int c_height = 600;


int scale = 8; //Pixels width per wind cell  
Cell[][] cells = new Cell[c_width/scale][c_height/scale];

PVector mouse = new PVector(0, 0); //Stores mouse position as a vector

char[] keys = {'1'};
boolean[] key_down = new boolean[keys.length];

//Sliders for controlling the width and height of new shapes
Slider shape_width = new Slider(220, 1, 25, 2, "Shape Width", 1);
Slider shape_height = new Slider(260, 1, 25, 5, "Shape Height", 1);

//Arraylist of shapes, called paper
ArrayList<Paper> papes = new ArrayList<Paper>();
float r_set = 20;

void setup() {
  size(800, 600);
  //Initializing all of the wind cells 
  for (int x = 0; x<cells.length; x++) {
    for (int y = 0; y<cells[x].length; y++) {
      cells[x][y] = new Cell(x, y, scale);
    }
  }
}

void draw() {

  if (start) {
    background(255); //Set background white
    mouse.set(mouseX, mouseY); //Store mouse position
    hud(); //User interface
    if (go) { //Play
      run_cells();
      pape_main();
    } else { //Paused
      pape_just_draw();
    }
  } else {
    background(255);
    fill(0);
    textSize(20);
    text(keys[0]+" to blow wind outward", 100, 100);
    text('2'+" over a dot to lock or unlock it", 100, 150);
    text('3'+" to place a shape", 100, 200);
    text('4'+" over a dot to remove a shape", 100, 250);
    text('g'+" to toggle gravity", 100, 300);
    text('p'+" to toggle pause", 100, 350);
    text("Press any key to continue", 100, 510);
  }
}
void hud() {
  fill(#E07878);
  rect(c_width, 0, width-c_width, height);
  //Draw and update sliders
  shape_width.animation();
  shape_height.animation();
  
  textSize(12);
  text("Gravity: "+gravity, 10, 15);
}
void mouseReleased() {
  released = true;
}
void mousePressed() {
  released = false;
}
void keyPressed() {
  //Update key being held or not
  for (int i=0; i<keys.length; i++) {
    if (key == keys[i]) {
      key_down[i] = true;
    }
  }
}
void keyReleased() {
  if (start) {
    for (int i=0; i<keys.length; i++) {
      if (key == keys[i]) {
        key_down[i] = false;
      }
    }
    if (key == '2') {
      boolean cont=true;
      for (int a=0; a<papes.size()&&cont; a++) {
        Paper pap = papes.get(a);
        for (int b=0; b<pap.beads.length&&cont; b++) {
          for (int c=0; c<pap.beads[b].length&&cont; c++) {
            if (PVector.sub(mouse, pap.beads[b][c].pos).mag()<pap.beads[b][c].r/2) { //Mouse on bead
              pap.beads[b][c].lock_p=!pap.beads[b][c].lock_p;
              cont = false;
            }
          }
        }
      }
    } else if (key == '3') {
      drop_ok(mouse); //Can I place a shape?
    } else if (key == '4') {
      boolean cont=true;
      for (int a=0; a<papes.size()&&cont; a++) {
        Paper pap = papes.get(a);
        for (int b=0; b<pap.beads.length&&cont; b++) {
          for (int c=0; c<pap.beads[b].length&&cont; c++) {
            if (PVector.sub(mouse, pap.beads[b][c].pos).mag()<pap.beads[b][c].r/2) {
              papes.remove(a);
              cont = false;
            }
          }
        }
      }
    } else if (key=='p'||key=='P') { //Toggle pause
      go=!go;
    } else if (key=='g'||key=='G') { //Toggle gravity
      gravity = !gravity;
    }
  } else {
    start = true;
  }
}
