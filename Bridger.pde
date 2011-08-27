// Author: "Golan Levin" <golan@flong.com>, 01 August, 2011
//================================================================
class RowInfo {
  int x0; 
  int x1;
  int y;
}



//================================================================
void bridgeCorners (color[] bufferToProcess, int bufW, int bufH) {
  // thicken the corners of grid units under certain geometric conditions. 

  int N = CORNER_THICKENING;
  if (N > 0) {
    
    color cornerColor = white;
    if (DO_WHITE_PAINT_STENCIL){
      cornerColor = black;
    }
    
    
    for (int y=N; y<(bufH-N); y++) {
      for (int x=N; x<(bufW-N); x++) {

        int indexC  = y*bufW + x;
        int indexE  = indexC + 1;
        int indexS  = indexC + bufW;
        int indexSE = indexS + 1;

        color colorC  = bufferToProcess [indexC];
        color colorE  = bufferToProcess [indexE];
        color colorS  = bufferToProcess [indexS];      
        color colorSE = bufferToProcess [indexSE];

        if (((colorC  == black)
          && (colorE  == white)
          && (colorS  == white)
          && (colorSE == black)) ||

          ((colorC  == white)
          && (colorE  == black)
          && (colorS  == black)
          && (colorSE == white))) {

          //------------------------------------------
          for (int i=0; i<=N; i++) {
            int Cx = indexC % bufW;
            int Cy = indexC / bufW; 
            int Ex = indexE % bufW;
            int Ey = indexE / bufW; 
            int Sx = indexS % bufW;
            int Sy = indexS / bufW;
            int SEx = indexSE % bufW;
            int SEy = indexSE / bufW;

            boolean bUseObsoleteRoundedCorners = false;
            if (bUseObsoleteRoundedCorners) {
              // legacy code block; remove or don't use. 
              for (int j=0; j<=N; j++) {
                int dx = N - i;
                int dy = N - j;
                float dh = sqrt(dx*dx + dy*dy); 
                if (dh >= N) {
                  int indexCc  = ((Cy-j) * bufW)  + (Cx-i);
                  int indexEc  = ((Ey-j) * bufW)  + (Ex+i);
                  int indexSc  = ((Sy+j) * bufW)  + (Sx-i);
                  int indexSEc = ((SEy+j) * bufW) + (SEx+i);
                  bufferToProcess [indexCc]  = cornerColor;
                  bufferToProcess [indexEc]  = cornerColor;
                  bufferToProcess [indexSc]  = cornerColor;
                  bufferToProcess [indexSEc] = cornerColor;
                }
              }
            }
            else {

              for (int j=0; j<i; j++) {
                int Cxc = Cx - (N-i);
                int Cyc = Cy -    j;
                int indexCc = (Cyc * bufW) + Cxc;
                bufferToProcess [indexCc] = cornerColor;

                int Exc = Ex + (N-i);
                int Eyc = Ey -    j;
                int indexEc = (Eyc * bufW) + Exc;
                bufferToProcess [indexEc] = cornerColor;

                int Sxc = Sx - (N-i);
                int Syc = Sy +    j;
                int indexSc = (Syc * bufW) + Sxc;
                bufferToProcess [indexSc] = cornerColor;

                int SExc = SEx + (N-i);
                int SEyc = SEy +    j;
                int indexSEc = (SEyc * bufW) + SExc;
                bufferToProcess [indexSEc] = cornerColor;
              }
            }
          }
        }
      }
    }
  }
}

//===============================================================
void  bridgeIslands (color[] inputBuffer, int inputW, int inputH) {
  // Dispatches the advanced or the simple bridging routine. 
  // SIMPLE: just one or two bridges on the top edge of islands. Produces fragile stencils.
  // ADVANCED: produces multiple, quasi-optimal bridges for each island, on multiple sides. 

  if (DO_ADVANCED_BRIDGING) {
    bridgeIslandsAdvanced (inputBuffer, inputW, inputH);
  } 
  else {
    bridgeIslandsSimple (inputBuffer, inputW, inputH);
  }
}


//===============================================================
void bridgeIslandsSimple (color[] inputBuffer, int inputW, int inputH) {
  // inputBuffer is an array of colors(i.e. ints), which 
  // are a 'pure' black-and-white version of the QR code. 

  gridSize = computeGridSize (inputBuffer, inputW, inputH); // see Utils.pde

  int ccLabelColors[] = CCL.getLabelColors();
  int nLabelColors = ccLabelColors.length;
  while (nLabelColors > 2) {
    
    //---------------------
    // Find out where to build the bridge(s).
    // Get the first color other than black or white.
    // (Assuming white and black are colors 0 and 1.)
    color firstLabelCol = ccLabelColors[2];

    RowInfo responseTop = getRowInfoOfTheTopRowOfABlobWithACertainColor (firstLabelCol, coloredLabeledImage, inputW, inputH);
    int topLeftXValue  = responseTop.x0; 
    int topRightXValue = responseTop.x1; 
    int topRowYValue   = responseTop.y; 

    //----------
    // If I have found the row of that color, then build the bridges.
    if ((topLeftXValue > -1) && (topRightXValue > -1)) {
      int bridgeBottomY = topRowYValue;
      if (((topRightXValue - topLeftXValue)/gridSize) > 2) {
        buildABridge (topLeftXValue, bridgeBottomY, gridSize, DIR_UP, gridSize, inputBuffer, inputW, inputH);

        int bridgeWidth = getBridgeWidthFromGridSize (gridSize);
        int rightHandBridgeX = topRightXValue - (bridgeWidth-1);
        buildABridge (rightHandBridgeX, bridgeBottomY, gridSize, DIR_UP, gridSize, inputBuffer, inputW, inputH);
      } 
      else {
        int centerX = (topLeftXValue + topRightXValue)/2;
        buildABridge (centerX, bridgeBottomY, gridSize, DIR_UP, gridSize, inputBuffer, inputW, inputH);
      }
    }

    //----------
    // re-compute the connected components now that the bridge exists.
    coloredLabeledImage = CCL.doLabel( inputBuffer, inputW, inputH);

    //----------
    // re-extract the number of current labels.
    // presumably, because we built a bridge, it's one less than it was before.
    ccLabelColors = CCL.getLabelColors();
    nLabelColors = ccLabelColors.length;
  }
}



//===============================================================
void bridgeIslandsAdvanced (color[] inputBuffer, int inputW, int inputH) {

  gridSize = computeGridSize (inputBuffer, inputW, inputH); // see Utils.pde
  int ccLabelColors[] = CCL.getLabelColors();
  int nLabelColors = ccLabelColors.length;
  //while (nLabelColors > 2) {
  for (int LC=2; LC<nLabelColors; LC++) {

    //---------------------
    // Find out where to build the bridge(s); get the first color other than black or white.
    // firstLabelCol = ccLabelColors[2];
    color firstLabelCol = ccLabelColors[LC];

    //---------------------------------------------------------
    // Find the extreme locations of the blob with that color.
    // Note that e.g. indexA might be the same as indexE, etc. 
    final int UNDEFINED = -1;
    int indexA = UNDEFINED; // (A) the first pixel of the top row;    top's left
    int indexB = UNDEFINED; // (B) the last  pixel of the top row;    top's right 
    int indexC = UNDEFINED; // (C) the first pixel of the bottom row; bottom's left
    int indexD = UNDEFINED; // (D) the last  pixel of the bottom row; bottom's right
    int indexE = UNDEFINED; // (E) the top pixel of leftmost column;  left's top
    int indexF = UNDEFINED; // (F) the bot pixel of leftmost column;  left's bottom
    int indexG = UNDEFINED; // (G) the top pixel of rightmost column; right's top
    int indexH = UNDEFINED; // (H) the bot pixel of rightmost column; right's bottom

    int topRowY    = UNDEFINED;
    int bottomRowY = UNDEFINED;
    int leftRowX   = UNDEFINED; 
    int rightRowX  = UNDEFINED;

    //        A---B
    //        |   |
    //     E---   ---G
    //     |         |
    //     F---   ---H
    //        |   |
    //        C---D
    //

    // find indexA and indexB
    for (int y = 0; y < inputH; y++) {
      for (int x = 0; x < inputW; x++) { 
        int index = y*inputW + x;
        color someCol = coloredLabeledImage[index];
        if ((someCol == firstLabelCol) && (indexA == UNDEFINED)) {
          indexA  = index;
          topRowY  = y;
        }
        if ((someCol == firstLabelCol) && (y == topRowY)) {
          indexB = index;
        }
      }
    }

    // find indexC and indexD
    for (int y = (inputH-1); y >= 0; y--) {
      for (int x = (inputW-1); x >= 0; x--) { 
        int index = y*inputW + x;
        color someCol = coloredLabeledImage[index];
        if ((someCol == firstLabelCol) && (indexD == UNDEFINED)) {
          indexD  = index;
          bottomRowY  = y;
        }
        if ((someCol == firstLabelCol) && (y == bottomRowY)) {
          indexC = index;
        }
      }
    }

    // find indexE and indexF
    for (int x=0; x< inputW; x++) {
      for (int y=0; y< inputH; y++) {
        int index = y*inputW + x;
        color someCol = coloredLabeledImage[index];
        if ((someCol == firstLabelCol) && (indexE == UNDEFINED)) {
          indexE = index;
          leftRowX = x;
        }
        if ((someCol == firstLabelCol) && (x == leftRowX)) {
          indexF = index;
        }
      }
    }

    // find indexG and indexH
    for (int x=(inputW-1); x>=0; x--) {
      for (int y=(inputH-1); y>=0; y--) {
        int index = y*inputW + x;
        color someCol = coloredLabeledImage[index];
        if ((someCol == firstLabelCol) && (indexH == UNDEFINED)) {
          indexH = index;
          rightRowX = x;
        }
        if ((someCol == firstLabelCol) && (x == rightRowX)) {
          indexG = index;
        }
      }
    }

    //---------------------------------------------------------
    // for each of the locations (A-H), search in the appropriate direction
    // until the next non-black pixel is encountered. Store that distance (dA, dB, dC, ...) in a Pier object
    final int idA = 0; 
    final int idB = 1; 
    final int idC = 2; 
    final int idD = 3;
    final int idE = 4; 
    final int idF = 5; 
    final int idG = 6; 
    final int idH = 7;

    ArrayList<Pier> piers; 
    piers = new ArrayList<Pier>();  // Constructor requests: int id_, int index_, int bearing_, int distance_
    piers.clear();

    if (indexA != UNDEFINED) { // check UP and LEFT from A
      piers.add (new Pier (idA, indexA, DIR_UP, getVDistanceToNearestNonBlackPixel (indexA, inputW, inputH, DIR_UP)    )); 
      piers.add (new Pier (idA, indexA, DIR_LEFT, getHDistanceToNearestNonBlackPixel (indexA, inputW, inputH, DIR_LEFT ) ));
    }
    if (indexB != UNDEFINED) { // check UP and RIGHT from B
      piers.add (new Pier (idB, indexB, DIR_UP, getVDistanceToNearestNonBlackPixel (indexB, inputW, inputH, DIR_UP)    )); 
      piers.add (new Pier (idB, indexB, DIR_RIGHT, getHDistanceToNearestNonBlackPixel (indexB, inputW, inputH, DIR_RIGHT) ));
    }
    if (indexC != UNDEFINED) { // check DOWN and LEFT from C
      piers.add (new Pier (idC, indexC, DIR_DOWN, getVDistanceToNearestNonBlackPixel (indexC, inputW, inputH, DIR_DOWN ) )); 
      piers.add (new Pier (idC, indexC, DIR_LEFT, getHDistanceToNearestNonBlackPixel (indexC, inputW, inputH, DIR_LEFT ) ));
    }
    if (indexD != UNDEFINED) { // check DOWN and RIGHT from D
      piers.add (new Pier (idD, indexD, DIR_DOWN, getVDistanceToNearestNonBlackPixel (indexD, inputW, inputH, DIR_DOWN ) )); 
      piers.add (new Pier (idD, indexD, DIR_RIGHT, getHDistanceToNearestNonBlackPixel (indexD, inputW, inputH, DIR_RIGHT) ));
    }

    if ((indexE != UNDEFINED) && (indexE != indexA)) { // check UP and LEFT from E
      piers.add (new Pier (idE, indexE, DIR_UP, getVDistanceToNearestNonBlackPixel (indexE, inputW, inputH, DIR_UP)    )); 
      piers.add (new Pier (idE, indexE, DIR_LEFT, getHDistanceToNearestNonBlackPixel (indexE, inputW, inputH, DIR_LEFT ) ));
    }
    if ((indexG != UNDEFINED) && (indexG != indexB)) { // check UP and RIGHT from G
      piers.add (new Pier (idG, indexG, DIR_UP, getVDistanceToNearestNonBlackPixel (indexG, inputW, inputH, DIR_UP)    )); 
      piers.add (new Pier (idG, indexG, DIR_RIGHT, getHDistanceToNearestNonBlackPixel (indexG, inputW, inputH, DIR_RIGHT) ));
    }
    if ((indexF != UNDEFINED) && (indexF != indexC)) { // check DOWN and LEFT from F
      piers.add (new Pier (idF, indexF, DIR_DOWN, getVDistanceToNearestNonBlackPixel (indexF, inputW, inputH, DIR_DOWN ) )); 
      piers.add (new Pier (idF, indexF, DIR_LEFT, getHDistanceToNearestNonBlackPixel (indexF, inputW, inputH, DIR_LEFT ) ));
    }
    if ((indexH != UNDEFINED) && (indexH != indexD)) { // check DOWN and RIGHT from H
      piers.add (new Pier (idH, indexH, DIR_DOWN, getVDistanceToNearestNonBlackPixel (indexH, inputW, inputH, DIR_DOWN ) )); 
      piers.add (new Pier (idH, indexH, DIR_RIGHT, getHDistanceToNearestNonBlackPixel (indexH, inputW, inputH, DIR_RIGHT) ));
    }


    // Compute the area of the blob with that color. 
    // We'll use the area as a direct basis for deciding how many bridges to build. 
    int nPixelsInThatBlob = getAreaOfBlobWithACertainColor (firstLabelCol, coloredLabeledImage, inputW, inputH);
    int nGridCellsInThatBlob = nPixelsInThatBlob/ (gridSize*gridSize); 
    int N_BRIDGES_TO_MAKE = 4; // default.
    if (DO_ALL_COMPUTED_BRIDGES) {
      N_BRIDGES_TO_MAKE = piers.size();
    } 
    else {
      N_BRIDGES_TO_MAKE = min(piers.size(), max(MIN_BRIDGES_PER_ISLAND, nGridCellsInThatBlob));
    }


    for (int Br=0; Br < N_BRIDGES_TO_MAKE; Br++) {

      // Select (at least 2 of) the shortest distances (that are not on the same side), and build bridges there. 
      // We can build more bridges (as appropriate) depending on the area of the blob:
      // extremely large blobs (whose areas contain many grid units) deserve more bridges. 
      // Sort the Piers by their length. 
      Collections.sort (piers, new Comparator<Pier>() {
        public int compare(Pier e0, Pier e1) {
          return ((Integer)(e0.distance)).compareTo((Integer)(e1.distance));
        }
      }
      ); 
      boolean bPrintPiers = false;
      if (bPrintPiers) {
        println("------------------"); 
        for (int i=0; i<piers.size(); i++) {
          piers.get(i).print();
        }
      }

      //------------------------------------
      // First: bridge the shortest pier:
      // Get the length of the shortest pier. (Remember, we sorted piers, above.)
      if (piers.size() > 0) { // safety check
        int lengthOfShortestPier = piers.get(0).distance;

        // (Discard degenerate piers (if any!) which are shorter than gridSize.)
        if (lengthOfShortestPier < gridSize) { 
          int len = 9999999;
          for (int i=0; i<piers.size(); i++) {
            if (piers.get(i).distance >= gridSize) { // kosher
              lengthOfShortestPier = min(lengthOfShortestPier, piers.get(i).distance);
            }
          }
        }

        Pier shortestPier = null; 
        int countOfPiersWithTheShortestLength = 0; 
        for (int i=0; i<piers.size(); i++) {
          if (piers.get(i).distance == lengthOfShortestPier) {
            countOfPiersWithTheShortestLength++;
            shortestPier = piers.get(i);
          }
        }

        if (countOfPiersWithTheShortestLength > 1) {
          // This is rather ridiculous, but it's late.
          // If there is more than one pier with the shortest length, 
          // Tally the total number of piers for each bearing (up, down, left, right) that has a pier with that length
          // And select the pier (with that length) from the direction with the fewest piers.
          // This leaves the maximum number of other possible piers for connecting later. 
          int nPiersU = 0; // UP
          int nPiersD = 0; // DOWN
          int nPiersL = 0; // LEFT
          int nPiersR = 0; // RIGHT
          boolean bHasShortestU = false;
          boolean bHasShortestD = false;
          boolean bHasShortestL = false;
          boolean bHasShortestR = false;

          for (int i=0; i<piers.size(); i++) {
            int bearing = piers.get(i).bearing;
            switch(bearing) {
            case DIR_UP: 
              if (piers.get(i).distance == lengthOfShortestPier) {
                bHasShortestU = true;
              } 
              nPiersU++;
              break;
            case DIR_DOWN:  
              if (piers.get(i).distance == lengthOfShortestPier) {
                bHasShortestD = true;
              } 
              nPiersD++; 
              break;
            case DIR_LEFT:
              if (piers.get(i).distance == lengthOfShortestPier) {
                bHasShortestL = true;
              }   
              nPiersL++;
              break;
            case DIR_RIGHT: 
              if (piers.get(i).distance == lengthOfShortestPier) {
                bHasShortestR = true;
              } 
              nPiersR++;
              break;
            }
          }

          int nPiersInBearingsWithShortestPiers[] = new int[4];
          nPiersInBearingsWithShortestPiers[DIR_UP]    = (bHasShortestU) ? nPiersU : 0; 
          nPiersInBearingsWithShortestPiers[DIR_DOWN]  = (bHasShortestD) ? nPiersD : 0; 
          nPiersInBearingsWithShortestPiers[DIR_LEFT]  = (bHasShortestL) ? nPiersL : 0; 
          nPiersInBearingsWithShortestPiers[DIR_RIGHT] = (bHasShortestR) ? nPiersR : 0; 

          int bearingWithFewestPiersThatAlsoHasAShortestPier = UNDEFINED;
          int minNumPiers = 999;
          for (int i=0; i<4; i++) {
            if (nPiersInBearingsWithShortestPiers[i] > 0) {
              if (nPiersInBearingsWithShortestPiers[i] < minNumPiers) {
                minNumPiers = nPiersInBearingsWithShortestPiers[i];
                bearingWithFewestPiersThatAlsoHasAShortestPier = i;
              }
            }
          }

          // Therefore, search for the pier that (1) has the shortest length and (2) has the bearingWithFewestPiersThatAlsoHasAShortestPier.
          for (int i=0; i<piers.size(); i++) {
            int bearing = piers.get(i).bearing;
            if (bearing == bearingWithFewestPiersThatAlsoHasAShortestPier) {
              int len = piers.get(i).distance;
              if (len == lengthOfShortestPier) {
                shortestPier = piers.get(i);
              }
            }
          }
          // Now we have found the shortest pier, and from an underrepresented side, to boot!
        } 
        else if (countOfPiersWithTheShortestLength == 1) {
          ; // Solo case. Just use shortestPier. We're good!
        }

        // Actually do the BRIDGING. 
        if (shortestPier != null) {
          int bridgeIndex = shortestPier.index;
          int bridgeX     = bridgeIndex % inputW;
          int bridgeY     = bridgeIndex / inputW;
          int bearing     = shortestPier.bearing;
          int distance    = shortestPier.distance;

          // Hey, why not do some bridge pixel HINTING!
          int bridgeWidth = getBridgeWidthFromGridSize (gridSize);
          int id = shortestPier.ID;
          switch (id) {
          case idA: 
          case idE:
            ; // should be good to go
            break;

          case idB: 
          case idG:
            if (bearing == DIR_UP) {
              bridgeX -= (bridgeWidth-1);
            } 
            break;

          case idC: 
          case idF: 
            if (bearing == DIR_LEFT) {
              bridgeY -= (bridgeWidth-1);
            }
            break;

          case idD: 
          case idH: 
            if (bearing == DIR_DOWN) {
              bridgeX -= (bridgeWidth-1);
            } 
            else if (bearing == DIR_RIGHT) {
              bridgeY -= (bridgeWidth-1);
            }
            break;
          }

          buildABridge (bridgeX, bridgeY, gridSize, bearing, distance, inputBuffer, inputW, inputH);
        }

        // Remove shortestPier. 
        // Also, with some probability, remove all piers with the same bearing. 
        piers.remove(shortestPier); 
        if (DO_ALL_COMPUTED_BRIDGES == false) {
          ArrayList<Pier> PiersToRemove = new ArrayList<Pier>();
          for (int i=0; i<(piers.size()); i++) {
            if (piers.get(i).bearing == shortestPier.bearing) {
              // the higher BRIDGE_CULLING_FACTOR is closer to 1.0, 
              // the more likely to enforce only having single bridges per side.
              if ((random(0, 1) < BRIDGE_CULLING_FACTOR)) { // !!!!!!!!!!!!!!!!! DITHER
                PiersToRemove.add (piers.get(i));
              }
            }
          }
          for (int i=0; i<PiersToRemove.size(); i++) {
            piers.remove (PiersToRemove.get(i));
          }
        }
      }
    } // repeat the adding of bridges!




    /*
    //----------
     // re-compute the connected components now that the bridge exists, and re-extract the number of current labels.
     coloredLabeledImage = CCL.doLabel( inputBuffer, inputW, inputH);
     ccLabelColors = CCL.getLabelColors();
     nLabelColors = ccLabelColors.length;
     */
  }
}


//===============================================================
class Pier {    // A starting point for a possible bridge!

  //-------------
  Pier (int id_, int index_, int bearing_, int distance_) {
    ID = id_;
    index = index_;
    bearing = bearing_;
    distance = distance_;
  }

  //-------------
  void print() {

    String dir = ""; 
    switch(bearing) {
    case DIR_UP:    
      dir = "UP"; 
      break;
    case DIR_DOWN:  
      dir = "DOWN"; 
      break;
    case DIR_LEFT:  
      dir = "LEFT"; 
      break;
    case DIR_RIGHT: 
      dir = "RIGHT"; 
      break;
    }
    println("Pier: From point " + ID + "\t" + distance + "\t" + dir);
  }

  //-------------
  int ID;       // the "name" of the start point
  int index;    // the index (in the QR-image sized buffer) of the start point
  int bearing;  // which way the bridge would go from here
  int distance; // how long the bridge would need to be
}


//===============================================================
int getVDistanceToNearestNonBlackPixel (int startIndex, int inputW, int inputH, int direction) {
  int distance = 0;

  if (startIndex > -1) {
    int x = startIndex % inputW;
    int y = startIndex / inputW;

    if (direction == DIR_UP) {
      y = y-1; 
      int testIndex = y*inputW + x; 
      color testColor = coloredLabeledImage[testIndex]; 
      while ( (testColor == black) && (y > 0)) {
        y = y-1;
        testIndex = y*inputW + x; 
        testColor = coloredLabeledImage[testIndex];
      }
      distance = abs(y - (startIndex/inputW)) -1;
    } 
    else if (direction == DIR_DOWN) {
      y = y+1; 
      int testIndex = y*inputW + x; 
      color testColor = coloredLabeledImage[testIndex]; 
      while ( (testColor == black) && (y < (inputH-1))) {
        y = y+1;
        testIndex = y*inputW + x; 
        testColor = coloredLabeledImage[testIndex];
      }
      distance = abs(y - (startIndex/inputW)) -1;
    }
  }
  return distance;
}


//===============================================================
int getHDistanceToNearestNonBlackPixel (int startIndex, int inputW, int inputH, int direction) {
  int distance = 0;

  if (startIndex > -1) {
    int x = startIndex % inputW;
    int y = startIndex / inputW;

    if (direction == DIR_LEFT) {
      x = x-1; // to get started, on the pixel above
      int testIndex = y*inputW + x; 
      color testColor = coloredLabeledImage[testIndex]; 
      while ( (testColor == black) && (x > 0)) {
        x = x-1;
        testIndex = y*inputW + x; 
        testColor = coloredLabeledImage[testIndex];
      }
      distance = abs(x - (startIndex%inputW)) -1;
    }
    else if (direction == DIR_RIGHT) {
      x = x+1; // to get started, on the pixel above
      int testIndex = y*inputW + x; 
      color testColor = coloredLabeledImage[testIndex]; 
      while ( (testColor == black) && (x < (inputW-1))) {
        x = x+1;
        testIndex = y*inputW + x; 
        testColor = coloredLabeledImage[testIndex];
      }
      distance = abs(x - (startIndex%inputW)) -1;
    }
  }
  return distance;
}



//===============================================================
void buildABridge (int bridgeX, int bridgeY, int gridSize, int direction, int distance, color[] inputBuffer, int inputW, int inputH) {

  int bridgeWidth = getBridgeWidthFromGridSize (gridSize);

  if (direction == DIR_UP) {
    // bridgeY is interpreted as the Y end value.
    int yStart = bridgeY - distance - 1;
    for (int y=bridgeY; y>=yStart; y--) {
      for (int x=bridgeX; x<(bridgeX+bridgeWidth); x++) {
        if ((y >= 0) && (x >= 0)) {
          int index = y*inputW + x;
          inputBuffer[index] = white;
        }
      }
    }
  } 

  else if (direction == DIR_DOWN) {
    // bridgeY is interpreted as the Y start value.
    int yEnd = bridgeY + distance + 1;
    for (int y=bridgeY; y<yEnd; y++) {
      for (int x=bridgeX; x<(bridgeX+bridgeWidth); x++) {
        if ((y < inputH) && (x < inputW)) {
          int index = y*inputW + x;
          blackAndWhiteImage[index] = white;
        }
      }
    }
  }

  else if (direction == DIR_LEFT) {
    int xStart = bridgeX;
    int xEnd   = bridgeX - distance - 1;
    for (int x=xStart; x >= xEnd; x--) {
      for (int y=bridgeY; y<(bridgeY+bridgeWidth); y++) {
        if ((y >= 0) && (x >= 0)) {
          int index = y*inputW + x;
          blackAndWhiteImage[index] = white;
        }
      }
    }
  }

  else if (direction == DIR_RIGHT) {
    int xStart = bridgeX;
    int xEnd   = bridgeX + distance + 1; 
    for (int x=xStart; x<= xEnd; x++) {
      for (int y=bridgeY; y<(bridgeY+bridgeWidth); y++) {
        if ((y < inputH) && (x < inputW)) {
          int index = y*inputW + x;
          blackAndWhiteImage[index] = white;
        }
      }
    }
  }
}


//===============================================================
int getBridgeWidthFromGridSize (int grs) {
  int bridgeWidth = (int)(grs * BRIDGE_THICKNESS); // ratio: bridge is ~1/6 of gridSize
  if ((bridgeWidth > 1) && (bridgeWidth %2 == 1)) {
    bridgeWidth--;
  }

  bridgeWidth = max(1, bridgeWidth); 
  return bridgeWidth;
}


//===============================================================
RowInfo getRowInfoOfTheTopRowOfABlobWithACertainColor (color firstLabelCol, color[] coloredBuffer, int inputW, int inputH) {
  RowInfo response = new RowInfo();
  response.x0 = -1;
  response.x1 = -1;
  response.y  = -1;

  // find the indexes of the first & last pixels in the top row of the blob with that color.
  int topLeftIndex  = -1; // this will hold the index of the first pixel to contain that color.
  int topRightIndex = -1; // this will hold the index of the last pixel to contain that color, from the same row. 
  int topRowYValue  = -1; 
  int topLeftXValue = -1;
  int topRightXValue = -1;
  boolean bFoundTopLeft = false;

  for (int y = 0; y < inputH; y++) {
    for (int x = 0; x < inputW; x++) { 
      int index = y*inputW + x;
      color someCol = coloredBuffer[index];

      if ((someCol == firstLabelCol) && (bFoundTopLeft == false)) {
        topLeftIndex  = index;
        bFoundTopLeft = true;
        topLeftXValue = x;
        topRowYValue  = y;
      }

      if ((y == topRowYValue) && (someCol == firstLabelCol)) {
        topRightIndex = index;
        topRightXValue = x;
      }
    }
  }

  response.x0 = topLeftXValue; 
  response.x1 = topRightXValue; 
  response.y  = topRowYValue; 
  return response;
}


//===============================================================
int getAreaOfBlobWithACertainColor (color testColor, color[] colorBuffer, int inputW, int inputH) {

  int pixelCount = 0;
  for (int y=0; y<inputH; y++) {
    for (int x=0; x<inputW; x++) {
      int index = y*inputW + x; 
      if (colorBuffer[index] == testColor) {
        pixelCount++;
      }
    }
  }

  return pixelCount;
}

