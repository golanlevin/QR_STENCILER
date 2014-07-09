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
  
  if(ARTK_MODE) {
    return ARTK_MARKER_SCALE;
  }
  
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
// Author: "Karl D.D. Willis" <karl@karlddwillis.com>, 27 August, 2011
//================================================================
PImage createMarkerImage(int markerID) {
  
  // Create an image from a given BCH marker ID
    
  if(markerID > 4096 || markerID < 0) {
    println("Marker ID out of range");
    return null;
  }

  int BCH_MARKER_COUNT = 64;
  int BCH_EDGE_SIZE = 3;
  int BCH_GAP_SIZE = 2;
  
  // Index in the marker array
  int ix = (int) (markerID % BCH_MARKER_COUNT);
  int iy = (int) (markerID / BCH_MARKER_COUNT);

  // Pixel location
  int x = BCH_EDGE_SIZE + ix * BCH_MARKER_SIZE;
  if(ix > 0) {
    x += ix * BCH_GAP_SIZE;
  }
  int y = BCH_EDGE_SIZE + iy * BCH_MARKER_SIZE;
  if(iy > 0) {
    y += iy * BCH_GAP_SIZE;
  }

  PImage subImage = new PImage(ARTK_MARKER_SIZE, ARTK_MARKER_SIZE);
  PImage markers = loadImage("data/ARTK_AllBchThinMarkers.png");
  
  // For each pixel in the 10x10 sub area of the markers png file
  for (int i=0; i<BCH_MARKER_SIZE; i++) {
    for (int j=0; j<BCH_MARKER_SIZE; j++) {
			
	int mainPixelPos = ((j+y) * markers.width + (i+x));
			
	int sx = i * ARTK_MARKER_SCALE;
	int sy = j * ARTK_MARKER_SCALE;
	int subPixelPos = (sy * ARTK_MARKER_SIZE + sx);			
			
	// Enlarge the 10x10 marker area to the display size
	for (int k=0; k<ARTK_MARKER_SCALE; k++) {
	  int krow = k * ARTK_MARKER_SIZE;
	  for (int l=0; l<ARTK_MARKER_SCALE; l++) {
	    int subDisplayPixelPos = krow + subPixelPos + l;
	    subImage.pixels[subDisplayPixelPos] = markers.pixels[mainPixelPos];
	  }
	}
    }
  }
	
  subImage.updatePixels();
  return subImage;
}

/** Zero Pad an int 
 * 
 * @param i     The number to pad
 * @param len   The length required
 * @return      The padded number
 */
public static String zeroPad(int i, int len) {
    // converts integer to left-zero padded string, len chars long.
    String s = Integer.toString(i);
    if (s.length() > len) {
        return s.substring(0, len);
    // pad on left with zeros
    } else if (s.length() < len) {
        return "000000000000000000000000000".substring(0, len - s.length()) + s;
    } else {
        return s;
    }
}

