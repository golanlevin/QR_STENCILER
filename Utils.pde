// Author: "Golan Levin" <golan@flong.com>, 01 August, 2011
//================================================================
void copyBlackAndWhiteImageFromPImage (PImage img) {
  for (int i=0; i<nPixels; i++) {
    blackAndWhiteImage[i] = img.pixels[i];
  }
}


//===============================================================
void copyBufferToScreen(color[] imageBuffer, int nPix) {
  // Note: no safety checks here. 
  loadPixels();
  for (int i=0; i<nPix; i++) {
    pixels[i] = imageBuffer[i];
  }
  updatePixels();
}


//===============================================================
void computeBlackAndWhiteInverseBuffer (color[] srcBuffer, color[] dstBuffer, int nPix) {
  for (int i=0; i<nPix; i++) {
    if (srcBuffer[i] == black) {
      dstBuffer[i] = white;
    } 
    else {
      dstBuffer[i] = black;
    }
  }
}


//===============================================================
void binarizeTheImage (color[] bufferToProcess, int bufW, int bufH) {
  // We clobber the image to ensure that .JPG artifacts don't confuse us. 
  // This forces pixels to pure black and pure white. 

  int binarizationThreshold = 127;
  for (int y=0; y<bufH; y++) {
    for (int x=0; x<bufW; x++) {

      int index  = y*bufW + x;
      color c = bufferToProcess[index];
      float bri = brightness(c); 

      if (bri < binarizationThreshold) {
        bufferToProcess[index] = black;
      } 
      else {
        bufferToProcess[index] = white;
      }
    }
  }
}


//===============================================================
int computeGridSize (color[] qrImageBuffer, int qrImageW, int qrImageH) {
  // calculate the size of the QR code's grid units. 
  // we know that the first thing is a black square which is 7 units wide.
  // use this information to automatically calculate the number of pixels per unit.  
  
  int marginX = 0;
  int marginY = 0;  
  color searchColor = black;
  if (DO_WHITE_PAINT_STENCIL){
    marginX = inverseMargin+1;
    marginY = inverseMargin+1; 
    searchColor = white;
  }

  boolean bFoundFirstSearchColorPixel = false;
  boolean bColorHasntChangedSinceIFoundTheFirstSearchColorPixel = true;
  int searchColorLocStartX = -1; 
  int searchColorLocEndX   = -1; 
  int searchColorLocY      = -1; 

  for (int y = marginY; y < (qrImageH-marginY); y++) {
    for (int x = marginX; x < (qrImageW-marginX); x++) { 

      int index = y*qrImageW + x;
      color someCol = qrImageBuffer[index];

      if ((someCol == searchColor) && (bFoundFirstSearchColorPixel == false)) {
        bFoundFirstSearchColorPixel = true;
        searchColorLocStartX = x;
        searchColorLocY = y;
      }

      if (y == searchColorLocY) { // if we are still in the same row
        if (bColorHasntChangedSinceIFoundTheFirstSearchColorPixel) {
          if (someCol != searchColor) {
            bColorHasntChangedSinceIFoundTheFirstSearchColorPixel = false;
          } 
          else {
            searchColorLocEndX = x;
          }
        }
      }
    }
  }

  if (bFoundFirstSearchColorPixel && (searchColorLocStartX > -1) && (searchColorLocEndX > -1)) {
    int distance = 1 + searchColorLocEndX - searchColorLocStartX; // +1 corrects off-by-one err
    int gridSize = distance / 7; // fixed.
    return gridSize;
  }
  
  println ("Error determining QR code grid size. Is your image a valid QR code?"); 
  return -1;
}


//===============================================================
void handleInverseStencil(){
  if (DO_WHITE_PAINT_STENCIL) {
    
    // put a narrow margin around everything
    int m = inverseMargin;
    for (int y=0; y<QR.height; y++) {
      for (int x=0; x<m; x++) {
        int index = y*QR.width + x;
        blackAndWhiteImage[index] = black;
      }
      for (int x=(QR.width-m); x<QR.width; x++) {
        int index = y*QR.width + x;
        blackAndWhiteImage[index] = black;
      }
    }
    for (int y=0; y<m; y++) {
      for (int x=0; x<QR.width; x++) {
        int index = y*QR.width + x;
        blackAndWhiteImage[index] = black;
      }
      for (int x=0; x<QR.width; x++) {
        int index = (QR.height-1-y)*QR.width + x;
        blackAndWhiteImage[index] = black;
      }
    }
    
    // invert the image for further processing
    for (int y=0; y<QR.height; y++) {
      for (int x=0; x<QR.width; x++) {
        int index = y*QR.width + x;
        if (blackAndWhiteImage[index] == black){
          blackAndWhiteImage[index] = white; 
        } else {
          blackAndWhiteImage[index] = black; 
        }
        
      }
    }
  }
}
