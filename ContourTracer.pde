// Author: "Golan Levin" <golan@flong.com>, 01 August, 2011
//================================================================
class Point2d {
  int x, y;
  Point2d (int inx, int iny) {
    x = inx;
    y = iny;
  }
}


//===============================================
class ContourTracer {

  Point2d firstPixel;  
  ArrayList<ArrayList> chains;
  ArrayList colorLabels;

  ContourTracer () {
    chains      = new ArrayList<ArrayList>(); // a collection of contours.
    colorLabels = new ArrayList();
    firstPixel  = new Point2d(0, 0);
  }


  //===============================================================
  void traceBlobContours (color[] coloredBlobBuffer, int bufW, int bufH) {
    int nLabels = compileLabelColors ( coloredBlobBuffer, bufW, bufH);

    chains.clear(); 
    for (int i=0; i<nLabels; i++) {
      findBlobStartPixel(i, coloredBlobBuffer, bufW, bufH);
      compute8NeighborChainCode (firstPixel.x, firstPixel.y, coloredBlobBuffer, bufW, bufH);
      repairLeftTurningInteriorCorners();
    }
  }


  //===============================================
  void drawAllChains() {

    for (int n=0; n<chains.size(); n++) {
      ArrayList aContour = (ArrayList)chains.get(n);

      beginShape();
      for (int i=0; i<aContour.size(); i++) {
        Point2d P = (Point2d) aContour.get(i);
        vertex(P.x, P.y);
      }
      endShape(CLOSE);
    }
  }


  //===============================================
  void drawAllChainsWithFilletedCorners() {

    for (int n=0; n<chains.size(); n++) {
      ArrayList aContour = (ArrayList)chains.get(n);
      if (aContour.size() > 0) {

        float px0, py0; 
        float px1, py1; 
        float px2, py2;
        Point2d P0 = (Point2d) aContour.get(0);
        px2 = px1 = px0 = P0.x;
        py2 = py1 = py0 = P0.y;

        int orientationPrev = -1; 
        int orientationCurr = -1;
        int indexOfPrevAppendedPoint = -1;

        beginShape();
        boolean pPrevWasDiagonal = true;
        int nPointsInContour = aContour.size();

        for (int i=0; i<(2+nPointsInContour); i++) {
          int index = i%nPointsInContour;
          Point2d P2 = (Point2d) aContour.get(index);
          px2 = P2.x;
          py2 = P2.y;

          if ((px2 != px1) && (py2 != py1)) {
            // if this (P2) point's x and y are BOTH different from the previous points',
            // then this point is DIAGONAL from the previous one. Don't include it, but store it as a start point (p0).
            if (pPrevWasDiagonal == false) {
              pPrevWasDiagonal = true;
              // if we have just begun a diagonal span, make a note of the first point, P0.
              px0 = px1;
              py0 = py1;
            }
          } 
          else {
            // Since this (P2's) x and y are (horizontally or vertically) aligned with the previous, 
            // then -- if we had been tracing a diagonal -- the previous point was the last in the diagonal.
            // Add it (p1) to the output chain/drawing, and also the new one (p2) as well. 

            if (pPrevWasDiagonal) {
              pPrevWasDiagonal = false; 
              orientationPrev = -1; 
              orientationCurr = -1;

              // NOTE: we'll need to detect whether it was an interior corner.
              // check whether p00 (before 0) is left or down from p0

              // Add the bezier corner curve. For more details on the math, see:
              // http://www.cgafaq.info/wiki/B%C3%A9zier_circle_approximation
              // http://www.tinaja.com/glib/ellipse4.pdf
              vertex(px0, py0); 
              float dx = px1 - px0; 
              float dy = py1 - py0;
              float r  = dx; // dx and dy are the same -- but the sign matters. 
              float d  = r * 4.0*(sqrt(2.0) - 1.0)/3.0; //i.e. 0.55228475

              //---------------
              if (((px1 > px0) && (py1 < py0)) || ((px1 < px0) && (py1 > py0))) {
                if (USE_BEZIER_NOT_ARCS) {
                  float cxa = px0    ; 
                  float cya = py0 - d; 
                  float cxb = px1 - d; 
                  float cyb = py1    ; 
                  bezierVertex(cxa, cya, cxb, cyb, px1, py1);
                } 
                else {
                  for (int t=1; t<=ARC_RESOLUTION; t++) {
                    float angle = PI + HALF_PI * (float)t/ (float)ARC_RESOLUTION;
                    float cx = px1 + r * cos(angle);
                    float cy = py0 + r * sin(angle);
                    vertex(cx, cy);
                  }
                }
              } 
              //---------------
              else if (((px1 < px0) && (py1 < py0)) || ((px1 > px0) && (py1 > py0))) {
                if (USE_BEZIER_NOT_ARCS) {
                  float cxa = px0 + d; 
                  float cya = py0    ; 
                  float cxb = px1    ; 
                  float cyb = py1 - d; 
                  bezierVertex(cxa, cya, cxb, cyb, px1, py1);
                } 
                else {
                  for (int t=1; t<=ARC_RESOLUTION; t++) {
                    float angle = HALF_PI + HALF_PI * (float)t/ (float)ARC_RESOLUTION;
                    float cx = px0 - r * cos(angle);
                    float cy = py1 - r * sin(angle);
                    vertex(cx, cy);
                  }
                }
              } 

              else {
                if (i > 0) {
                  // no good reason why this would be the case, but...
                  vertex(px1, py1);
                }
              }

              indexOfPrevAppendedPoint = index;
            } 
            else if (!pPrevWasDiagonal) {

              // Point p2 is aligned (horizontally or vertically) with the previous point, p1. 
              // We only append p1 if the orientation has changed (i.e., turned a corner). 
              if ((px2 > px1) && (py2 == py1)) {
                orientationCurr = DIR_RIGHT;
              } 
              else if ((px2 < px1) && (py2 == py1)) {
                orientationCurr = DIR_LEFT;
              } 
              else if ((px2 == px1) && (py2 > py1)) {
                orientationCurr = DIR_DOWN;
              } 
              else if ((px2 == px1) && (py2 < py1)) {
                orientationCurr = DIR_UP;
              } 
              else { 
                // WTF; not sure how this would happen.
              }

              if (orientationCurr != orientationPrev) { // if there has been a change in orientation
                if (true) { //index != (indexOfPrevAppendedPoint +1)) { // if it's not just the next point
                  if (i < nPointsInContour) { // prevent extra looparoundie
                    vertex(px1, py1);
                    indexOfPrevAppendedPoint = index;
                  }
                }
              }
              orientationPrev = orientationCurr;
            }
          }
          px1 = px2; 
          py1 = py2;
        }
        endShape(CLOSE);
      }
    }
  }


  //===============================================
  int compileLabelColors(int buffer[], int bufW, int bufH) {

    colorLabels.clear();
    color black = color(0, 0, 0);
    for (int y=0; y<bufH; y++) {
      for (int x=0; x<bufW; x++) {
        color val = buffer[y*bufW + x];

        if (val != black) {
          if (colorLabels.size() == 0) {
            colorLabels.add(val);
          }
          else {

            boolean bFound = false;
            for (int i=0; i<colorLabels.size(); i++) {
              color col = (color)(((Integer)(colorLabels.get(i))).intValue()); // yech
              if (val == col) {
                bFound = true;
              }
            }
            if (bFound == false) {
              colorLabels.add(val);
            }
          }
        }
      }
    }

    return colorLabels.size();
  }


  //===============================================
  void findBlobStartPixel (int whichLabel, int[] buffer, int bufW, int bufH) {

    color searchColor = (color)(((Integer)(colorLabels.get(whichLabel))).intValue());
    boolean foundBlobStartPixel = false;
    color black = color(0, 0, 0);

    for (int y=0; y<bufH; y++) {
      for (int x=0; x<bufW; x++) {
        color val = buffer[y*bufW + x];

        if (!foundBlobStartPixel && (val == searchColor)) {
          firstPixel.x = x;
          firstPixel.y = y;
          foundBlobStartPixel = true;
        }
      }
    }
  }


  //===============================================
  boolean isPixelLocationLegal (int x, int y, int bufW, int bufH) {
    if (x < 0 || x >= bufW) return false;
    if (y < 0 || y >= bufH) return false;
    return true;
  }


  //===============================================
  /*  Compute the chain code of the object beginning at pixel (i,j).
   Return the code as NN integers in the array C.          */
  void compute8NeighborChainCode (int i, int j, int[] buffer, int bufW, int bufH) {
    int val, m, q, r, ii, d, dii;
    int lastdir, jj;

    ArrayList aContour = new ArrayList<Point2d>();
    aContour.clear();

    // Table given index offset for each of the 8 directions.
    int di[] = {
      0, -1, -1, -1, 0, 1, 1, 1
    };
    int dj[] = {
      1, 1, 0, -1, -1, -1, 0, 1
    };


    val = buffer[j*bufW+i]; 
    q = i;   
    r = j; 
    lastdir = 4;

    do {
      m = 0;
      dii = -1;  
      d = 100;
      for (ii=lastdir+1; ii<lastdir+8; ii++) {     /* Look for next */
        jj = ii%8;
        if (isPixelLocationLegal (di[jj]+q, dj[jj]+r, bufW, bufH)) {
          if ( buffer[(dj[jj]+r)*bufW + (di[jj]+q)] == val) {
            dii = jj;
            m = 1;
            break;
          }
        }
      }

      if (m != 0) { /* Found the next pixel ... */
        Point2d P = new Point2d(q, r);
        aContour.add(P);  

        q += di[dii];
        r += dj[dii];
        lastdir = (dii+5)%8;
      }
      else {
        break;    /* NO next pixel */
      }
    }
    while ( (q!=i) || (r!=j) );   /* Stop when next to start pixel */
    chains.add(aContour);
  }


  //===============================================
  void repairLeftTurningInteriorCorners () {
    // left-turning interior corners were clipped by one pixel. Fix 'em.

    for (int n=0; n<chains.size(); n++) {
      ArrayList aContour = (ArrayList)chains.get(n);

      for (int i=1; i<(aContour.size()-1); i++) {
        Point2d P0 = (Point2d) aContour.get(i-1);
        Point2d P1 = (Point2d) aContour.get(i  );
        Point2d P2 = (Point2d) aContour.get(i+1);

        if      ((P1.x == P0.x) && (P1.y <  P0.y) && (P2.x < P1.x) && (P2.y < P1.y)) {
          Point2d P = new Point2d(P1.x, P2.y);
          aContour.add(i+1, P);
        } 
        else if ((P1.x >  P0.x) && (P1.y == P0.y) && (P2.x > P1.x) && (P2.y < P1.y)) {
          Point2d P = new Point2d(P2.x, P1.y);
          aContour.add(i+1, P);
        } 
        else if ((P1.x <  P0.x) && (P1.y == P0.y) && (P2.x < P1.x) && (P2.y > P1.y)) {
          Point2d P = new Point2d(P2.x, P1.y);
          aContour.add(i+1, P);
        } 
        else if ((P1.x == P0.x) && (P1.y >  P0.y) && (P2.x > P1.x) && (P2.y > P1.y)) {
          Point2d P = new Point2d(P1.x, P2.y);
          aContour.add(i+1, P);
        }
      }
    }
  }

  // end ContourTracer class
}
