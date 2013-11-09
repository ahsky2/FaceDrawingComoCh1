
class PopArtCube {
  float x;
  float y;
  float width;
  float height;
  int imgCount = 2;
  PImage[] imgs = new PImage[imgCount]; // [front image, back image]
  int[] imgIndexes = new int[imgCount];
  int imgAddIndex = 0;
  int imgIndex = 0; // 0 : front image
  int status = 0; // 0 : image showing, 1 : transition

  boolean isRunning = false;
  
  PGraphics[] fadeOutMasks;
  PGraphics[] fadeInMasks;
  int maskCount;
  int maskIndex = 0;
  
  PImage colorImg;
  boolean isNextImg = false;
  
  int transitionCount = 0;
  boolean isStop = false;
  
  boolean isUpside = false;

  PopArtCube (float x, float y, float w, float h) {
    // empty frame
    this.x = x;
    this.y = y;  
    this.width = w;
    this.height = h;
    
    for(int i = 0; i < imgCount; i++) {
      imgs[i] = createImage((int)width, (int)height, RGB);
    }
  }

  void addImage(PImage img, int index) {
    imgIndexes[imgAddIndex] = index;
    imgs[imgAddIndex].copy(img, 0, 0, (int)width, (int)height, 0, 0, (int)width, (int)height);
    imgAddIndex = (imgAddIndex + 1) % imgCount;
  }
  
  void setColor(color cubeColor) {
    this.colorImg = createImage(int(width), int(height), RGB);
    colorImg.loadPixels();
    for (int i = 0; i < colorImg.pixels.length; i++) {
      colorImg.pixels[i] = cubeColor; 
    }
    colorImg.updatePixels();
  }
  
  void setMasks(PGraphics[] fadeOutMasks, PGraphics[] fadeInMasks) {
    this.fadeOutMasks = fadeOutMasks;
    this.fadeInMasks = fadeInMasks;
    this.maskCount = fadeOutMasks.length;
  }

  void update() {
    if (status == 1) {
      
    }
  }

  void display() {

    fill(0);
    noStroke();
    rect(x, y, width, height);

    textureMode(NORMAL);
    
    if (status == 0) {
      image(imgs[imgIndex], x, y);
    } 
    else {
      if (isUpside) {
        
        float transValue = map(maskIndex, 0, maskCount, 0, height);
        
        imgs[imgIndex].mask(fadeOutMasks[maskIndex]);
      
        beginShape();
        texture(imgs[imgIndex]);
        vertex(x, y, 0, 0);
        vertex(x + width, y, 1, 0);
        vertex(x + width, y + height - transValue, 1, 1);
        vertex(x, y + height - transValue, 0, 1);
        endShape();
        
        imgs[(imgIndex + 1) % imgCount].mask(fadeInMasks[maskIndex]);
          
        beginShape();
        texture(imgs[(imgIndex + 1) % imgCount]);
        
        vertex(x, y + height - transValue, 0, 0);
        vertex(x + width, y + height - transValue, 1, 0);
        vertex(x + width, y + height, 1, 1);
        vertex(x, y + height, 0, 1);
        endShape();
      } else {
        float transValue = map(maskIndex, 0, maskCount, 0, height);
        
        imgs[imgIndex].mask(fadeInMasks[maskCount - maskIndex - 1]);
      
        beginShape();
        texture(imgs[imgIndex]);
        vertex(x, y + transValue, 0, 0);
        vertex(x + width, y + transValue, 1, 0);
        vertex(x + width, y + height, 1, 1);
        vertex(x, y + height, 0, 1);
        endShape();
        
        imgs[(imgIndex + 1) % imgCount].mask(fadeOutMasks[maskCount - maskIndex - 1]);
          
        beginShape();
        texture(imgs[(imgIndex + 1) % imgCount]);
        
        vertex(x, y, 0, 0);
        vertex(x + width, y, 1, 0);
        vertex(x + width, y + transValue, 1, 1);
        vertex(x, y + transValue, 0, 1);
        endShape();
      }
      
      maskIndex++;
      if (maskIndex == maskCount) {
        status = 0; // change status to show
        imgIndex = (imgIndex + 1) % imgCount; // change front image index
        maskIndex = 0;
        transitionCount++;
      }
    }
  }

  boolean transition() {
    if (isStop) {
      isRunning = false;
    } else {
      if (isRunning) {
        if (status == 0) {
          isRunning = false;
        }
      } 
      else {
        this.status = 1;
  
        isRunning = true;
      }
    }

    return isRunning;
  }
  
  void transitionStop() {
    isStop = true;
  }
  
  int getImgIndex() {
    return imgIndexes[imgIndex];
  }
  
  void setDirection() {
    if (random(1) > 0.5) {
      isUpside = true;
    } else {
      isUpside = false;
    }
  }

}
