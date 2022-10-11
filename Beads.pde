void pape_main() {
  for (int a = 0; a<papes.size(); a++) {
    Paper p1 = papes.get(a);
    for (int b = a; b<papes.size(); b++) {
      Paper p2 = papes.get(b);
      if (p1.id==p2.id) {
        p1.check_collisions(p2, true);
      } else {
        //Is paper in vicinity
        if (abs(.5*(p2.bounds[2]-p1.bounds[0]+p2.bounds[0]-p1.bounds[2]))<(p2.bounds[2]-p2.bounds[0]+p1.bounds[2]-p1.bounds[0])/2) {
          if (abs(.5*(p2.bounds[3]-p1.bounds[1]+p2.bounds[1]-p1.bounds[3]))<(p2.bounds[3]-p2.bounds[1]+p1.bounds[3]-p1.bounds[1])/2) {
            p1.check_collisions(p2, true);
          }
        }
      }
    }
    p1.mail(); //Main function
  }
}
void pape_just_draw() { //When paused
  for (Paper p1 : papes) {
    for (int x = 0; x<p1.dim[0]; x++) {
      for (int y = 0; y<p1.dim[1]; y++) {
        p1.beads[x][y].animation();
      }
    }
  }
}
void drop_ok(PVector pos) {
  if (pos.x>r_set && pos.x+(shape_width.pos+1)*r_set<c_width&& pos.y>r_set && pos.y+(shape_height.pos+1)*r_set<c_height) {
    int[] dim_dim = {int(shape_height.pos), int(shape_width.pos)};
    Paper p1 = new Paper(dim_dim, mouseX, mouseY, r_set, 0, false, int(millis()));
    boolean did_something_collide = false;
    for (int a = 0; a<papes.size() && !did_something_collide; a++) {
      Paper p2 = papes.get(a);
      did_something_collide = p1.check_collisions(p2, false);
    }
    if (!did_something_collide) {
      papes.add(p1); //Place shape
    } else {
      println("Placement Failed: collision detected");
    }
  }
}


class Paper {
  int[] dim = {0, 0}; //width and height in # of particles
  Bead[][] beads; 

  float gap; // gap between particles
  float[] bounds = new float[4]; // corners

  float id; //Unique id for each shape
  
  Paper(int[] in_dim, float p_x, float p_y, float gap_s, float a, boolean lock, int id_set) {
    id = id_set;
    gap = gap_s;
    dim = in_dim;
    beads = new Bead[in_dim[0]][in_dim[1]];
    for (int x = 0; x<dim[0]; x++) {
      for (int y = 0; y<dim[1]; y++) {
        PVector pos = new PVector(p_x+gap*((x-(dim[0]-1)*.5)*sin(a)+y*cos(a)), p_y+gap*((x)*cos(a)+y*sin(a)));
        if (lock) {    
          if (x==0) {
            beads[x][y] = new Bead(6, pos, true); //Locked position beads
          } else {
            beads[x][y] = new Bead(6, pos); //Unlocked beads
          }
        } else {
          beads[x][y] = new Bead(6, pos);
        }
      }
    }
  }
  void mail() {
    update();
  }
  boolean check_collisions(Paper p1, boolean real) {
    if (id!=p1.id) { //Different shapes
      for (int a=0; a<beads.length; a++) {
        for (int b=0; b<beads[a].length; b++) {
          for (int c=0; c<p1.beads.length; c++) {
            for (int d=0; d<p1.beads[c].length; d++) {
              if (PVector.sub(beads[a][b].pos, p1.beads[c][d].pos).mag()<beads[a][b].r+p1.beads[c][d].r) {
                if (real) {
                  beads[a][b].collide(p1.beads[c][d]);
                } else {
                  return true;
                }
              }
            }
          }
        }
      }
    } else { //Same shape
      for (int a=0; a<beads.length; a++) {
        for (int b=0; b<beads[a].length; b++) {
          for (int c=a; c<beads.length; c++) {
            for (int d=b; d<beads[c].length; d++) {
              if (c-a>1 || abs(d-b)>1) {
                if (PVector.sub(beads[a][b].pos, p1.beads[c][d].pos).mag()<beads[a][b].r+p1.beads[c][d].r) {
                  beads[a][b].collide(p1.beads[c][d]);
                }
              }
            }
          }
        }
      }
    }
    return false;
  }
  void update() {
    for (int x = 0; x<dim[0]; x++) {
      for (int y = 0; y<dim[1]; y++) {
        beads[x][y].mail();
        if (x+1<dim[0]) {
          beads[x][y].yank(beads[x+1][y], gap);
          if (y+1<dim[1]) {
            beads[x][y].yank(beads[x+1][y+1], gap*r2);
          }
          if (y-1>-1) {
            beads[x][y].yank(beads[x+1][y-1], gap*r2);
          }
        }
        if (y+1<dim[1]) {
          beads[x][y].yank(beads[x][y+1], gap);
        }
      }
    }

    bounds[0] = beads[0][0].pos.x-beads[0][0].r;
    bounds[1] = beads[0][0].pos.y-beads[0][0].r;
    bounds[2] = beads[0][0].pos.x+beads[0][0].r;
    bounds[3] = beads[0][0].pos.y+beads[0][0].r;

    for (int x = 0; x<dim[0]; x++) {
      for (int y = 0; y<dim[1]; y++) {
        beads[x][y].catch_up();
        bounds[0] = min(beads[x][y].pos.x-beads[0][0].r, bounds[0]);
        bounds[1] = min(beads[x][y].pos.y-beads[0][0].r, bounds[1]);
        bounds[2] = max(beads[x][y].pos.x+beads[0][0].r, bounds[2]);
        bounds[3] = max(beads[x][y].pos.y+beads[0][0].r, bounds[3]);
      }
    }
  }
}
class Bead {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);

  boolean lock_p = false; //Locked?
  float r; //radius
  
  Bead(float r_set, PVector p_set, boolean _p) {
    lock_p = _p;
    pos = p_set;
    r = r_set*2;
  }
  Bead(float r_set, PVector p_set) {
    pos = p_set;
    r = r_set*2;
  }
  void mail() {
    animation();
    update();
  }
  void animation() {
    noStroke();
    if (lock_p) {
      fill(255, 0, 0);
    } else {
      fill(0);
    }
    ellipse(pos.x, pos.y, r, r);
  }
  void update() {
    for (int x = floor(-r/scale); x<floor(-r/scale)+2; x++) {
      float h = sqrt(pow(r*1.0/scale, 2)-pow(x, 2));
      for (int y = floor(-h); y<floor(h)+2; y++) {
        int px = floor(pos.x/scale)+x;
        int py = floor(pos.y/scale)+y;
        if (px>-1 && px<cells.length && py>-1 && py<cells[px].length) {
          vel.add(cells[px][py].wind.mult(.01));
          cells[px][py].wind.set(0, 0);
        }
      }
    }
    //straighten, collision, wind?
    if (gravity) {
      vel.add(new PVector(0, ag));
    }
    vel.add(acc);
    acc.set(0, 0);
    
    if (lock_p) { //If locked in place
      vel.set(0, 0);
    } else {
      pos.add(vel);
    }
    // wall collisions
    if (pos.x<r) {
      vel.x = -vel.x;
      pos.x = r;
    } else if (pos.x>c_width-r) {
      vel.x = -vel.x;
      pos.x = c_width-r;
    }
    if (pos.y<r) {
      vel.y = -vel.y;
      pos.y = r;
    } else if (pos.y>c_height-r) {
      vel.y = -vel.y;
      pos.y = c_height-r;
    }
  }
  void collide(Bead b1) { 
    PVector rp = PVector.sub(b1.pos, pos); //Relative position
    //Give slight repulsive push
    if (!lock_p) {
      PVector mrp = rp.copy();
      pos.add(mrp.mult(-.01)); 
    }
    if (!b1.lock_p) {
      PVector brp = rp.copy();
      b1.pos.add(brp.mult(.01));
    }
    //Calculate and apply collision force vector between balls
    rp.setMag(1);
    PVector rv = PVector.sub(b1.vel, vel); //Relative velocities
    float co = .7*rv.dot(rp); //Dot relative position and relative velocity
    rp.mult(co);
    acc.add(rp);
    b1.acc.add(rp.mult(-1));
  }
  void yank(Bead b1, float gap) {
    PVector rp = PVector.sub(b1.pos, pos); //Relative position
    //Apply force proportional to stretch or compression
    if (!lock_p) {
      PVector mrp = rp.copy();
      acc.add(mrp.mult(rp.mag()-gap).mult(.005));
    }
    if (!b1.lock_p) {
      PVector brp = rp.copy();
      b1.acc.add(brp.mult(gap-rp.mag()).mult(.005));
    }
  }
  void catch_up() {
    vel.add(acc);
    acc.set(0, 0);
  }
}
