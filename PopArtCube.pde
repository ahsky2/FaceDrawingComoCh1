
class PopArtCube {
  float x;
  float y;
  float width;
  float height;
  int imgCount = 2;
  PImage[] imgs = new PImage[imgCount]; // [front image, back image]
  int imgIndex = 0; // 0 : front image
  int status = 0; // 0 : image showing, 1 : transition

  boolean isRunning = false;
  
  PGraphics[] fadeOutMasks;
  PGraphics[] fadeInMasks;
  int transValue = 0;
  
  PImage colorImg;
  boolean isNextImg = false;

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

  void setImage(PImage img, boolean isFront) {
    if (isFront) {
      imgs[imgIndex].copy(img, 0, 0, (int)width, (int)height, 0, 0, (int)width, (int)height);
      imgIndex = (imgIndex + 1) % imgCount;
    } else {
      imgs[(imgIndex + 1) % imgCount].copy(img, 0, 0, (int)width, (int)height, 0, 0, (int)width, (int)height);
    }
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
//      beginShape();
//      texture(imgs[imgIndex]);
//      vertex(x, y, 0, 0);
//      vertex(x + width, y, 1, 0);
//      vertex(x + width, y + height, 1, 1);
//      vertex(x, y+ height, 0, 1);
//      endShape();
    } 
    else {
      if (!isNextImg) {
        
//      fadeOutMask = createGraphics(int(width), int(height));
//      fadeOutMask.beginDraw();
//      for(int h = 0; h < height; h++) {
//        fadeOutMask.stroke(map(h, 0, height, map(transValue, 0, height, 255, 0), 255));
//        fadeOutMask.line(0, h, width, h);
//      }
//      fadeOutMask.endDraw();
//      
        imgs[imgIndex].mask(fadeOutMasks[transValue]);
      
        beginShape();
        texture(imgs[imgIndex]);
        vertex(x, y, 0, 0);
        vertex(x + width, y, 1, 0);
        vertex(x + width, y + height - transValue, 1, 1);
        vertex(x, y + height - transValue, 0, 1);
        endShape();
      
//      fadeInMask = createGraphics(int(width), int(height));
//      fadeInMask.beginDraw();
//      for(int h = 0; h < height; h++) {
//        fadeInMask.stroke(map(h, 0, height, 255, map(transValue, 0, 80, 0, 255)));
//        fadeInMask.line(0, h, width, h);
//      }
//      fadeInMask.endDraw();
//      
        colorImg.mask(fadeInMasks[transValue]);

        beginShape();
        texture(colorImg);
        vertex(x, y + height - transValue, 0, 0);
        vertex(x + width, y + height - transValue, 1, 0);
        vertex(x + width, y + height, 1, 1);
        vertex(x, y + height, 0, 1);
        endShape();
        
        transValue = transValue + 1;
        if (transValue == height) {
          isNextImg = true;
          transValue = 0;
        }
      } else {
        colorImg.mask(fadeOutMasks[transValue]);
        
        beginShape();
        texture(colorImg);
        vertex(x, y, 0, 0);
        vertex(x + width, y, 1, 0);
        vertex(x + width, y + height - transValue, 1, 1);
        vertex(x, y + height - transValue, 0, 1);
        endShape();
        
        imgs[(imgIndex + 1) % imgCount].mask(fadeInMasks[transValue]);
          
        beginShape();
        texture(imgs[(imgIndex + 1) % imgCount]);
        vertex(x, y + height - transValue, 0, 0);
        vertex(x + width, y + height - transValue, 1, 0);
        vertex(x + width, y + height, 1, 1);
        vertex(x, y + height, 0, 1);
        endShape();
      
        transValue = transValue + 1;
        if (transValue == height) {
          isNextImg = false;
          status = 0; // change status to show
          imgIndex = (imgIndex + 1) % imgCount; // change front image index
          transValue = 0;
        }
      }
    }
  }

  boolean transition() {
    if (isRunning) {
      if (status == 0) {
        isRunning = false;
      }
    } 
    else {
      this.status = 1;

      isRunning = true;
    }

    return isRunning;
  }

}
