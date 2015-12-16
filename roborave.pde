//Patrick Cincotta
import java.util.*;

public static boolean testing = false;
World w;

void setup() {
  size(900, 900, P2D);
  ellipseMode(RADIUS);
  w = new World();
}

void draw() {
  background(100);
  w.turn();
}

public class World {
  Cat c;
  int trailSize = 3;
  int trailGroups = 4;
  float ringAcc = 0;
  float rots = 0;
  float[] trailx, traily;
  float[][] tlimitx, tlimity;
  color[] trailc;

  public World() {
    c = new Cat();

    trailx = new float[trailSize*trailGroups];
    traily = new float[trailSize*trailGroups];
    trailc = new color[trailSize*trailGroups];
    tlimitx = new float[trailGroups][2];
    tlimity = new float[trailGroups][2];

    initTrail();
  } 


  void turn() {
    backgroundPattern();
    rots += ringAcc;
    ringAcc = noise(random(-.02, .02));
    for (float i = 0; i < frameCount/30%10; i++) {
      fill(frameCount%255, (frameCount + 100) %255, random(255), random(100, 200));
      ring(width/2, height/2, 100, width/(3 + i/2), rots, i%2 == 0);
    }


    for (int g : activateLights ()) {
      float xs = tlimitx[g][0];
      float xb = tlimitx[g][1];
      float ys = tlimity[g][0];
      float yb = tlimity[g][1];
      updateTrail(g, random(xs, xb), random(ys, yb), color(random(255), random(255), random(255), random(100, 200)));
      bez(g);
    }

    c.move(mouseX, mouseY);
    c.posCat();
    c.drawCat();
  }

  void bez(int g) {
    beginShape();
    fill(trailc[g*trailSize]);
    float f1 = trailx[g*trailSize];
    float f2 = traily[g*trailSize];
    vertex(f1, f2);
    for (int i = 0; i < trailSize -1; i++) {
      bezierVertex(f1, f2, trailx[g*trailSize + i], traily[g*trailSize + i], trailx[g*trailSize + i + 1], traily[g*trailSize + i + 1]);
      f1 = trailx[g*trailSize+i];
      f2 = trailx[g*trailSize+i];
    }
    // bezierVertex(f1, f2, trailx[(g + 1)*trailSize - 1], traily[(g + 1)*trailSize - 1], trailx[(g + 1)*trailSize], traily[(g + 1)*trailSize]);
    endShape();
  }

  int[] activateLights() {
    List<Integer> tmp = new ArrayList<Integer>();
    for (int g = 0; g < trailGroups; g++) {
      float xs = tlimitx[g][0];
      float xb = tlimitx[g][1];
      float ys = tlimity[g][0];
      float yb = tlimity[g][1];
      float cx = c.x;
      float cy = c.y;
      if (cx >= xs
        && cx <= xb
        && cy >= ys
        && cy <= yb) {
        tmp.add(g);
      }
    }

    int[] ret =  new int[tmp.size()];

    for (int i = 0; i < tmp.size (); i++) {
      ret[i] = tmp.get(i);
    }

    return ret;
  }

  void initTrail() {
    //these should all over lap in the middle 2x2 square
    //first area is the top left 6x6 square
    tlimitx[0][0] = 0;
    tlimitx[0][1] = 6 * width/10;
    tlimity[0][0] = 0;
    tlimity[0][1] = 6 * height/10;
    //2nd area is top right 6x6 square
    tlimitx[1][0] = width - (6 * width/10);
    tlimitx[1][1] = width;
    tlimity[1][0] = 0;
    tlimity[1][1] = 6 * height/10;
    //3rd area is bottom right 6x6 square
    tlimitx[2][0] = width - (6 * width/10);
    tlimitx[2][1] = width;
    tlimity[2][0] = height - 6 * height/10;
    tlimity[2][1] = height;
    //4th area is bottom left 6x6 square
    tlimitx[3][0] = 0;
    tlimitx[3][1] = 6 * width/10;
    tlimity[3][0] = height - 6 * height/10;
    tlimity[3][1] = height;

    for (int i = 0; i < trailGroups; i++) {
      float xs = tlimitx[i][0];
      float xb = tlimitx[i][1];
      float ys = tlimity[i][0];
      float yb = tlimity[i][1];

      for (int j = 0; j < trailSize; j++) {
        trailx[i*trailSize + j] = random(xs, xb);
        traily[i*trailSize + j] =  random(ys, yb);
        trailc[i*trailSize + j] = color(random(255), random(255), random(255), random(100, 200));
      }
    }
  }

  void updateTrail(int g, float _x, float _y, color _c) {

    for (int i = trailSize - 1; i > 0; i--) {
      trailx[g*trailSize + i] = trailx[g*trailSize + i - 1];
      traily[g*trailSize + i] = traily[g*trailSize + i - 1];
      trailc[g*trailSize + i] = trailc[g*trailSize + i - 1];
    }
    trailx[g*trailSize] = _x;
    traily[g*trailSize] = _y;
    trailc[g*trailSize] = _c;
  }

  void backgroundPattern() {
    int hn = 10;
    int hx = height/hn;
    int wn = 5;
    int wx = width/wn;
    int q  = 1;

    for (int i = -hx - frameCount% (2*hx); i < (hn + 1)*hx; i += hx) {
      noStroke();
      fill(i*222/width%255, -i*222/height%255, 77, random(100, 200));
      rect(0, i, width, hx);

      fill(random(255)*222/width%255, -random(255)*222/width%255, random(100, 200), random(10, 100));
      for (int j = 0; j < wn; j++) {
        stroke(35);
        float w = j * wx;

        if (q % 2 == 0) {
          triangle(w, i, w, i + hx, w + wx, (2 * i + hx)/2);
        } else {
          triangle(w + wx, i, w + wx, i + hx, w, (2 * i + hx)/2);
          fill(w*222/width%255, -w*222/width%255, random(100, 200), random(10, 100));
        }
        q++;
      }
    }
    noStroke();
  }
}


public class Cat {
  float x, y, s, xa, ya, bob, rate; // x position, y position, and size (in pixels)
  PShape cat, head, leye, reye, body, larm, rarm, tail, bodyArt;
  PVector larma, rarma;

  // 1 = left -> right, -1 = right -> left
  int direction;
  public Cat(float _x, float _y, float _s, int _d) {
    x = _x;
    y = _y;
    s = _s;
    direction = _d;
    xa = 0;
    ya = 0;
    bob = 0;
    rate = .05;
    larma = new PVector();
    rarma = new PVector();
    posCat();
  }

  public Cat() {
    this((float) width/2, (float)  height/2, (float)  70, 1);
  }

  public void drawCat() {
    shape(cat, x, y);
  }

  public void move(float _x, float _y) {
    
    PVector pos = new PVector(x, y);
    PVector mouse = new PVector(_x, _y);
    
    rarma = PVector.sub(pos, mouse);
    rarma.normalize();
    larma.set(rarma);

    if (_x > x && _x - x > 1) {
      xa += 0.1; 

      if (xa < 0) {
        xa += 1;
      }

      xa = min(xa, 10);
      direction = 1;
    } else if (_x < x && x - _x > 1) {
      xa -= 0.1;

      if (xa > 0) {
        xa -= 1;
      }

      xa = max(xa, -10);
      direction = -1;
    } else {
      xa = 0;
    }

    if (_y > y && _y - y > 1) {
      ya += 0.1; 
      if (ya < 0) {
        ya += 1;
      }
      ya = min(ya, 10);
    } else if (_y < y && y - _y > 1) {
      ya -= 0.1;
      if (ya > 0) {
        ya -= 1;
      }
      ya = max(ya, -10);
    } else {
      ya = 0;
    }

    x += xa;
    y += ya;

    x = min(x, width);
    x = max(x, 0);
    y = min(y, height);
    y = max(y, 0);

    bob += rate;

    if (bob > .75 || bob < -.25) {
      rate *= -1;
    }
  }

  public void posCat() {

    cat = createShape(GROUP);
    bodyArt = createShape(GROUP);
    head = createShape();
    body = createShape();
    larm = createShape();
    rarm = createShape();
    tail = createShape();

    fill(255);
    stroke(random(255), random(255), random(255), random(100, 200));
    leye = createShape(ELLIPSE, 1.5, -5.5 + bob, 1, 1);

    reye = createShape(ELLIPSE, -1.5, -5.5 + bob, 1, 1);

    //body segment is 5x4
    body.beginShape();
    body.fill(max(-ya,0)*-ya, 0, 0);
    body.noStroke();
    body.vertex(-2, 2);
    body.vertex(2, 2);
    body.vertex(2.5, -2);
    body.vertex(-2.5, -2);
    body.endShape(CLOSE);

    PShape underShirt = createShape();
    underShirt.beginShape();
    underShirt.fill(255, 255, 255);
    underShirt.noStroke();
    underShirt.vertex(1, -2);
    underShirt.vertex(0.2, -1);
    underShirt.vertex(0.4, 2);
    underShirt.vertex(-0.4, 2);
    underShirt.vertex(-0.2, -1);
    underShirt.vertex(-1, -2);
    underShirt.endShape(CLOSE);

    PShape tie = createShape();
    tie.beginShape();
    tie.fill(200, 0, 0);
    tie.noStroke();
    tie.vertex(0.1, -2);
    tie.vertex(0.2-xa/5*direction, 1.5);
    tie.vertex(-xa/5*direction, 1.85);
    tie.vertex(-0.2-xa/5*direction, 1.5);
    tie.vertex(-0.1, -2);    
    tie.endShape(CLOSE);

    bodyArt.addChild(body);
    bodyArt.addChild(underShirt);
    bodyArt.addChild(tie);

    tail.beginShape(TRIANGLES);
    tail.noStroke();
    for (int i = 0; i < 20; i++) {
      float rr = random(0, 25*-3*ya);
      float rg = random(100-10*ya, 200);
      float rb = random(200, 255);
      float ro = random(20, 60);
      tail.fill(rr, rg, rb, ro);
      float rx = random(-2, 2);
      float ry = random(3, 6)*max(-ya, 1);
      tail.vertex(2, 2);
      tail.vertex(-2, 2);
      tail.vertex(rx, ry);
    }
    tail.endShape();

    //head segment is 5x3 + 1 tall ears
    head.beginShape();
    head.fill(0, 0, 0);
    head.noStroke();
    head.vertex(-3.5, -5.5 + bob);
    head.vertex(-2, -7 + bob);
    head.vertex(-1, -5.5 + bob);
    head.vertex(1, -5.5 + bob);
    head.vertex(2, -7 + bob);
    head.vertex(3.5, -5.5 + bob);
    head.vertex(2, -2.5 + bob);
    head.vertex(-2, -2.5 + bob);
    head.endShape(CLOSE);
    //no rotation for head planned

    //arms are .7 x 3.6
    pushMatrix();
    larm.beginShape();
    larm.fill(0, 0, 0);
    larm.noStroke();
    larm.vertex(-2.55, -1.8);
    larm.vertex(-3.2, -1.8);
    larm.vertex(-3.2, 1.6);
    larm.vertex(-2.55, 1.6);
    larm.endShape(CLOSE);
    larm.translate(-2.755, -1.8);
    larm.rotate((larma.heading()+90)*direction);
    larm.translate(2.755, 1.8);
    popMatrix();

    pushMatrix();
    rarm.beginShape();
    rarm.fill(0, 0, 0);
    rarm.noStroke();
    rarm.vertex(2.55, -1.8);
    rarm.vertex(3.2, -1.8);
    rarm.vertex(3.2, 1.6);
    rarm.vertex(2.55, 1.6);
    rarm.endShape(CLOSE);
    rarm.translate(2.755, -1.8);
    rarm.rotate((rarma.heading()+90)*direction);
    rarm.translate(-2.755, 1.8);
    popMatrix();

    //cat is the parent shape for all the other parts
    pushMatrix();
    cat.addChild(rarm);
    cat.addChild(tail);
    cat.addChild(bodyArt);
    cat.addChild(head);
    cat.addChild(leye);
    cat.addChild(reye);
    cat.addChild(larm);
    cat.scale(s/7*direction, s/7);
    cat.rotate(xa*direction*.05);
    popMatrix();

    if (testing) {

      println("x: ", x, " , y: ", y);
      stroke(255, 255, 255);
      for (int i = 0; i < width; i += width/10) {
        line(i, height, i, 0);
      }

      for (int i = 0; i < height; i += height/10) {
        line(width, i, 0, i);
      }
    }
  }
}

//creates a ring of outward facing triangles
void ring(float _x, float _y, int _n, float _r, float rot, Boolean ori) {
  // _x, _y = center point
  // _n = number of triangles in ring
  // _r = radius of ring (measured to tri center point)
  // ori = orientation true = out, false = in
  if (testing) {
    println("\nring: ", _x, ", ", _y, " #", _n, " radius:", _r);
  }

  float rads = 0;
  float s = (_r*PI/_n)*.9;
  float diff = TWO_PI/_n; 

  pushMatrix();
  translate(_x, _y);
  rotate(rot);
  for (int i = 0; i < _n; i++) {
    float tx = sin(rads)*_r;
    float ty = cos(rads)*_r;
    tri(tx, ty, rads, s, ori);
    rads += diff;
  }
  popMatrix();
}

//creates an triangle with its center at _x, _y rotated by _r
void tri(float _x, float _y, float _r, float _s, boolean ori) {
  // _x, _y = center point
  // _r = rotation (radians)
  // _s = triangle size (edge length in pixels)
  // ori = determines if it starts pointed up or down

  if (testing) {
    println("triangle: ", _x, ", ", _y, " rot: ", (int) _r*360/PI, " s: ", _s, "ori: ", ori);
  }

  pushMatrix();
  translate(_x, _y);

  if (ori) {
    rotate(PI/2.0-_r);
  } else {
    rotate(PI+PI/2.0-_r);
  }

  polygon(0, 0, _s, 3);
  popMatrix();
}

// for creating regular polygons
void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void stop() {
  exit();
}

