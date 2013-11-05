import java.util.*;

int imgCount = 30;
int imgIndex = 31;
PImage imgs[] = new PImage[imgCount];

NonLinearFunc func;

int windowWidth = 720;
int windowHeight = 480;
int popArtWidth = 80;
int popArtHeight = 80;
int popArtCount = (windowWidth / popArtWidth) * (windowHeight / popArtHeight) - 1;
Vector popArtVector;

int[] showIndexes = new int[popArtCount];
int[] showCounts = new int[popArtCount];
int[] showDelayIndexes = new int[popArtCount];
int[] showDelays = new int[popArtCount];
boolean[] isRunnings = new boolean[popArtCount];

boolean isSave = false;
int saveIndex = 0;
int saveCount = 1000;

color[] vividColors = 
//  {#FEFD0B, #FA0307, #2F9A1C, #CC00FF, #1086FF,
//   #FA003F, #2CE1B8, #118CFF, #DE00FC, #FEFD0B};
     {#2CDAA7, #1473FD};

PImage[] vividColorImgs = new PImage[vividColors.length];
   
PGraphics[] fadeOutMasks;
PGraphics[] fadeInMasks;

boolean isColorStart = true; // 0 : color to PopArt, 1 : PopArt to PopArt
boolean isNextLast = false;
boolean isLast = false;
int transitionCount = 3;
int transitionIndex = 0;

void setup() {
  size(720, 480, P2D);
  smooth();
  background(0);
  
  for(int i = 0; i < imgCount; i++) {
//    imgs[i] = loadImage("img" + (i + 1) + ".jpg");
    imgs[i] = loadImage("PFD_100x100_" + (i + imgIndex + 100 + "").substring(1) + ".jpg");
    if (imgs[i] == null)  {
      exit();
    }
    imgs[i].resize(80, 80);
  }
  
//  func = new NonLinearFunc(0.0, 0.0, 255.0, 255.0, 3.0);
//  func.make(4.0); // alpha value

  fadeOutMasks = new PGraphics[popArtHeight];
  fadeInMasks = new PGraphics[popArtHeight];
  for(int i = 0; i < popArtHeight; i++) {
    fadeOutMasks[i] = createMask(i, popArtWidth, popArtHeight, true);
    fadeInMasks[i] = createMask(i, popArtWidth, popArtHeight, false);
  }
  
  for(int i = 0; i < vividColorImgs.length; i++) {
    vividColorImgs[i] = createImage(popArtWidth, popArtHeight, RGB);
    vividColorImgs[i].loadPixels();
    for (int p = 0; p < vividColorImgs[i].pixels.length; p++) {
      vividColorImgs[i].pixels[p] = vividColors[i];
    }
    vividColorImgs[i].updatePixels();
  }

//  vividColorIndex = int(random(vividColors.length));
  vividColorIndex = 0;
  
  popArtVector = new Vector();
  for(int y = 0; y < (windowHeight / popArtHeight); y++) {
    for(int x = 0; x < (windowWidth / popArtWidth); x++) {
      if (x + y * (windowWidth / popArtWidth) < popArtCount) {
//        PopArt popArt = new PopArt(x * 80, y * 80, 80, 80);
        PopArtCube popArt = new PopArtCube(x * 80, y * 80, 80, 80);

        int index = round(random(0, imgCount-1));
//        println(index);

        if(isColorStart) {
          popArt.setImage(vividColorImgs[vividColorIndex], true);
          popArt.setImage(imgs[index], true);
        } else {
          popArt.setImage(imgs[index], true);
          popArt.setImage(imgs[(index + 1) % imgCount], false);
        }
        popArt.setMasks(fadeOutMasks, fadeInMasks);
        popArtVector.add(popArt);
        
        showIndexes[x + y * (windowWidth / popArtWidth)] = 0;
        showCounts[x + y * (windowWidth / popArtWidth)] = 0; //int(random(50, 100)); // 100;
        showDelayIndexes[x + y * (windowWidth / popArtWidth)] = 0;
        showDelays[x + y * (windowWidth / popArtWidth)] = 10 * (x + y * (windowWidth / popArtWidth));//100; //5 * (x + y * (windowWidth / popArtWidth));
      }
    }
  }
}

int vividColorIndex;

void draw() {
  Iterator iter = popArtVector.iterator();
  int i = 0;
  while (iter.hasNext()) {
//    PopArt popArt = (PopArt)iter.next();
    PopArtCube popArt = (PopArtCube)iter.next();
    if (showDelayIndexes[i] < showDelays[i]) {
      showDelayIndexes[i]++;
    } else if (showIndexes[i] < showCounts[i]) {
      showIndexes[i]++;
    } else {

//      isRunnings[i] = popArt.transition(100,func);
      isRunnings[i] = popArt.transition();
      if (isRunnings[i]) {
      } else {
//        println(transitionIndex);
//        showDelayIndexes[i] = 0;
        showIndexes[i] = 0;
        showCounts[i] = 10 * ((windowHeight / popArtHeight) * (windowWidth / popArtWidth)); //int(random(100, 200));
        
        if (i == 0) {
//          vividColorIndex = int(random(vividColors.length));
          vividColorIndex = 1;
          
          transitionIndex = transitionIndex + 1;
          if(transitionIndex == transitionCount) {
            isNextLast = true;
          }
        }
        
        if(!isNextLast) {
          int index = round(random(0, imgCount-1));
          popArt.setImage(imgs[index], false);
        } else {
          popArt.setImage(vividColorImgs[vividColorIndex], false);
        }
        
        if (i == popArtVector.size() - 1) {
          if(isLast) {
            noLoop();
          }
          if(isNextLast) {
            isLast = true;
          }
        }
      }
    }
  
    popArt.update();
    popArt.display();
    
    i++;
  }
  
  if (isSave) {
//    if (saveIndex < saveCount / 2 + 1) {
      saveFrame("frames/" +  String.valueOf(10000 + saveIndex).substring(1));
//      saveFrame("frames/" +  String.valueOf(10000 + saveCount - saveIndex).substring(1));
      saveIndex++;
//    }
  }
}

void mouseClicked() {
//  isSave = true;
}

PGraphics createMask(int t, int maskWidth, int maskHeight, boolean isFadeOut) {
  PGraphics mask = createGraphics(maskWidth, maskHeight);
  mask.beginDraw();
  for(int h = 0; h < maskHeight; h++) {
    if (isFadeOut) {
      mask.stroke(map(h, 0, maskHeight, map(t, 0, maskHeight, 255, 0), 255));
    } else {
      mask.stroke(map(h, 0, maskHeight, 255, map(t, 0, maskHeight, 0, 255)));
    }
    mask.line(0, h, maskWidth, h);
  }
  mask.endDraw();
  
  return mask;
}
