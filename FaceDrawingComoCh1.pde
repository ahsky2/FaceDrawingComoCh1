import java.util.*;

int imgCount = 90;
int imgIndex = 1;
PImage imgs[] = new PImage[imgCount];

int windowWidth = 720;
int windowHeight = 480;
int popArtWidth = 80;
int popArtHeight = 80;
int popArtCount = (windowWidth / popArtWidth) * (windowHeight / popArtHeight) - 1;
Vector popArtVector;

int[] savedIndexes = new int[popArtCount];
int[] viewedIndexes = new int[popArtCount];

int[] showIndexes = new int[popArtCount];
int[] showCounts = new int[popArtCount];
int[] showDelayIndexes = new int[popArtCount];
int[] showDelays = new int[popArtCount];
boolean[] isRunnings = new boolean[popArtCount];

boolean isSave = false;
int saveIndex = 0;

int maskCount = 120; // velocity of transition
PGraphics[] fadeOutMasks;
PGraphics[] fadeInMasks;

int transitionCount = 10; // # of transition

void setup() {
  frameRate(30);
  size(720, 480, P2D);
  smooth();
  background(0);
  
  for(int i = 0; i < imgCount; i++) {
    imgs[i] = loadImage("PFD_100x100_" + (i + imgIndex + 100 + "").substring(1) + ".jpg");
    if (imgs[i] == null)  {
      exit();
    }
    imgs[i].resize(popArtWidth, popArtHeight);
  }

  fadeOutMasks = new PGraphics[maskCount];
  fadeInMasks = new PGraphics[maskCount];
  for(int i = 0; i < maskCount; i++) {
    fadeOutMasks[i] = createMask(i, maskCount, popArtWidth, popArtHeight, true);
    fadeInMasks[i] = createMask(i, maskCount, popArtWidth, popArtHeight, false);
  }
  
  int i = 0;
  popArtVector = new Vector();
  for(int y = 0; y < (windowHeight / popArtHeight); y++) {
    for(int x = 0; x < (windowWidth / popArtWidth); x++) {
      if (x + y * (windowWidth / popArtWidth) < popArtCount) {
        PopArtCube popArt = new PopArtCube(x * 80, y * 80, 80, 80);
        
        boolean isSame = true;
        while(isSame) {
          int index = round(random(0, imgCount-1));
          
          isSame = false;
          for(int j = 0; j < i; j++) {
            if(savedIndexes[j] == index) {
              isSame = true;
              break;
            }
          }
          if (!isSame) {
            viewedIndexes[i] = savedIndexes[i] = index;
            break;
          }
        }
        
        popArt.addImage(imgs[savedIndexes[i]], savedIndexes[i]);
        popArt.addImage(imgs[(savedIndexes[i] + 1) % imgCount], (savedIndexes[i] + 1) % imgCount);
        popArt.setDirection();
        popArt.setMasks(fadeOutMasks, fadeInMasks);
        popArtVector.add(popArt);
        
        showIndexes[x + y * (windowWidth / popArtWidth)] = int(random(0, 600));
        showCounts[x + y * (windowWidth / popArtWidth)] = 600;
        showDelayIndexes[x + y * (windowWidth / popArtWidth)] = 0;
        showDelays[x + y * (windowWidth / popArtWidth)] = int(random(0, 100));;
        
        i++;
      }
    }
  }
}

void draw() {
  Iterator iter = popArtVector.iterator();
  int i = 0;
  while (iter.hasNext()) {
    PopArtCube popArt = (PopArtCube)iter.next();
    if (showDelayIndexes[i] < showDelays[i]) {
      showDelayIndexes[i]++;
    } else if (showIndexes[i] < showCounts[i]) {
      showIndexes[i]++;
    } else {
      isRunnings[i] = popArt.transition();
      if (isRunnings[i]) {
      } else {
        if (popArt.transitionCount < transitionCount) {
          showDelayIndexes[i] = int(random(0, 100));
          showIndexes[i] = 0;
          showCounts[i] = int(random(400, 600));
          
          int index;
          if (popArt.transitionCount == transitionCount - 1) {
            index = savedIndexes[i];
          } else {
            index = (popArt.getImgIndex() + 1) % imgCount;
          }
          popArt.addImage(imgs[index], index);
          popArt.setDirection();
        } else {
          popArt.transitionStop();
        }
      }
    }
  
    popArt.update();
    popArt.display();
    
    i++;
  }
  
  if (isSave) {
    saveFrame("frames/" +  String.valueOf(10000 + saveIndex).substring(1));
    saveIndex++;
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    if (isSave) {
      isSave = false;
      println("Save End");
    } else {
      isSave = true;
      println("Save Start");
    }
  }
}

PGraphics createMask(int maskIndex, int maskCount, int maskWidth, int maskHeight, boolean isFadeOut) {
  PGraphics mask = createGraphics(maskWidth, maskHeight);
  mask.beginDraw();
  for(int h = 0; h < maskHeight; h++) {
    if (isFadeOut) {
      mask.stroke(map(h, 0, maskHeight - 1, map(maskIndex, 0, maskCount - 1, 255, 0), 255));
    } else {
      mask.stroke(map(h, 0, maskHeight - 1, 255, map(maskIndex, 0, maskCount - 1, 0, 255)));
    }
    mask.line(0, h, maskWidth, h);
  }
  mask.endDraw();
  
  return mask;
}
