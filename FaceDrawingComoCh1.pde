import java.util.*;

int imgCount = 12;
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

void setup() {
  size(720, 480, P2D);
  smooth();
  background(0);
  
  for(int i = 0; i < imgCount; i++) {
//    imgs[i] = loadImage("img" + (i + 1) + ".jpg");
    imgs[i] = loadImage("PFD_100x100_" + (i + 101 + "").substring(1) + ".jpg");
    if (imgs[i] == null)  {
      exit();
    }
    imgs[i].resize(80, 80);
  }
  
  func = new NonLinearFunc(0.0, 0.0, 255.0, 255.0, 3.0);
  func.make(4.0); // alpha value
  
  popArtVector = new Vector();
  for(int y = 0; y < (windowHeight / popArtHeight); y++) {
    for(int x = 0; x < (windowWidth / popArtWidth); x++) {
      if (x + y * (windowWidth / popArtWidth) < popArtCount) {
        PopArt popArt = new PopArt(x * 80, y * 80, 80, 80);
        int index = round(random(0, imgCount-1));
//        println(index);
        popArt.setImage(imgs[index], true);
        popArt.setImage(imgs[(index + 1) % imgCount], true);
        popArtVector.add(popArt);
        
        showIndexes[x + y * (windowWidth / popArtWidth)] = 0;
        showCounts[x + y * (windowWidth / popArtWidth)] = int(random(50, 100)); // 100;
        showDelayIndexes[x + y * (windowWidth / popArtWidth)] = 0;
        showDelays[x + y * (windowWidth / popArtWidth)] = 0; //5 * (x + y * (windowWidth / popArtWidth));
      }
    }
  }
}

void draw() {
  Iterator iter = popArtVector.iterator();
  int i = 0;
  while (iter.hasNext()) {
    PopArt popArt = (PopArt)iter.next();
    if (showDelayIndexes[i] < showDelays[i]) {
      showDelayIndexes[i]++;
    } else if (showIndexes[i] < showCounts[i]) {
      showIndexes[i]++;
    } else {
      
      isRunnings[i] = popArt.transition(50,func);
      if (isRunnings[i]) {
      } else {
//        showDelayIndexes[i] = 0;
        showIndexes[i] = 0;
        showCounts[i] = int(random(100, 200));
        
        int index = round(random(0, imgCount-1));
        popArt.setImage(imgs[index], false);
      }
    }
  
    popArt.update();
    popArt.display();
    
    i++;
  }
  
  if (isSave) {
    if (saveIndex < saveCount / 2 + 1) {
      saveFrame("frames/" +  String.valueOf(10000 + saveIndex).substring(1));
      saveFrame("frames/" +  String.valueOf(10000 + saveCount - saveIndex).substring(1));
      saveIndex++;
    }
  }
}

void mouseClicked() {
  isSave = true;
}
