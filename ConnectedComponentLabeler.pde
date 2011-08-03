// Author: "Golan Levin" <golan@flong.com>, 01 August, 2011
//================================================================
class ConnectedComponentLabeler {
  
  // Adapted from: 
  // http://courses.csail.mit.edu/6.141/spring2010/pub/labs/VisualServo/src/ConnectedComponents.java
  // ConnectedComponentLabeler is an algorithm that applies Connected Component Labeling
  // algorithm to an input image. Only mono images are catered for.
  // author: Neil Brown, DAI
  // author: Judy Robertson, SELLIC OnLine

  //----------------------------------------------------------------------
  //the width of the input image in pixels
  int i1_w;

  //the width and height of the output image
  int d_w;
  int d_h;
  
  int numberOfLabels;
  boolean labelsValid = false;
  int dest_1d[];
  int labels[];
  int labelColors[];
  

  //----------------------------------------------------------------------
  // Constructs a new Image Operator
  // param firstwidth  The width of the input image
  // param firstheight  The height of the input image
  ConnectedComponentLabeler( int firstwidth, int firstheight ) {
    labels = new int[firstwidth * firstheight];
    i1_w = firstwidth;
  }

  //----------------------------------------------------------------------
  // getNeighbors will get the pixel value of i's neighbor that's ox and oy
  // away from i, if the point is outside the image, then 0 is returned.
  // This version gets from source image.
  int getNeighbors( int [] src1d, int i, int ox, int oy ) {
    int x, y, result;

    x = ( i % d_w ) + ox; // d_w and d_h are assumed to be set to the
    y = ( i / d_w ) + oy; // width and height of scr1d

    if ( ( x < 0 ) || ( x >= d_w ) || ( y < 0 ) || ( y >= d_h ) ) {
      result = 0;
    } 
    else {
      result = src1d[ y * d_w + x ] & 0x000000ff;
    }
    return result;
  }

  //----------------------------------------------------------------------
  // getNeighbord will get the pixel value of i's neighbor that's ox and oy
  // away from i, if the point is outside the image, then 0 is returned.
  // This version gets from destination image.
  int getNeighbord( int [] src1d, int i, int ox, int oy ) {
    int x, y, result;

    x = ( i % d_w ) + ox; // d_w and d_h are assumed to be set to the
    y = ( i / d_w ) + oy; // width and height of scr1d

    if ( (x < 0) || (x >= d_w) || (y < 0) || (y >= d_h) ) {
      result = 0;
    } 
    else {
      result = src1d[ y * d_w + x ];
    }
    return result;
  }

  //----------------------------------------------------------------------
  // Associate(equivalence) a with b.
  // a should be less than b to give some ordering (sorting)
  // if b is already associated with some other value, then propagate
  // down the list.
  void associate( int a, int b ) {

    if ( a > b ) {
      associate( b, a );
      return;
    }
    if ( ( a == b ) || ( labels[ b ] == a ) ) return;
    if ( labels[ b ] == b ) {
      labels[ b ] = a;
    } 
    else {
      associate ( labels[ b ], a );
      if (labels[ b ] > a) {             
        labels[ b ] = a;
      }
    }
  }

  //----------------------------------------------------------------------
  // Reduces the number of labels.
  int reduce( int a ) {
    if ( labels[ a ] == a ) {
      return a;
    } 
    else {
      return reduce( labels[ a ] );
    }
  }

  //----------------------------------------------------------------------
  // doLabel applies the Labeling algorithm plus offset and scaling
  // The input image is expected to be 8-bit mono, 0=black everything else=white
  // param src1_1d The input pixel array
  // param width width of the destination image in pixels
  // param height height of the destination image in pixels
  // return A pixel array containing the labelled image
  // NB For images  0,0 is the top left corner.
  int [] doLabel(int [] src1_1d, int wid, int hig) {

    int nextlabel = 1;
    int nbs[]  = new int[ 4 ];
    int nbls[] = new int[ 4 ];

    //Get size of image and make 1d_arrays
    d_w = wid;
    d_h = hig;

    dest_1d = new int[d_w*d_h];
    labels  = new int[d_w*d_h / 2]; // the most labels there can be is 1/2 of the points in checkerboard

    int src1rgb;
    int result = 0;
    int px, py, count, found;

    labelsValid = false; // only set to true once we've complete the task
    //initialise labels
    for (int i=0; i<labels.length; i++) labels[ i ] = i;

    //now Label the image
    for (int i=0; i< src1_1d. length; i++) {

      src1rgb = src1_1d[ i ] & 0x000000ff;

      if ( src1rgb == 0 ) {
        result = 0;  //nothing here
      } 
      else {

        //The 4 visited neighbors
        nbs[ 0 ]  = getNeighbors( src1_1d, i, -1,  0 );
        nbs[ 1 ]  = getNeighbors( src1_1d, i,  0, -1 );
        nbs[ 2 ]  = getNeighbors( src1_1d, i, -1, -1 );
        nbs[ 3 ]  = getNeighbors( src1_1d, i,  1, -1 );

        //Their corresponding labels
        nbls[ 0 ] = getNeighbord( dest_1d, i, -1,  0 );
        nbls[ 1 ] = getNeighbord( dest_1d, i,  0, -1 );
        nbls[ 2 ] = getNeighbord( dest_1d, i, -1, -1 );
        nbls[ 3 ] = getNeighbord( dest_1d, i,  1, -1 );

        //label the point
        if ( (nbs[0] == nbs[1]) && (nbs[1] == nbs[2]) && (nbs[2] == nbs[3])
          && (nbs[0] == 0 )) { 
          // all neighbors are 0 so gives this point a new label
          result = nextlabel;
          nextlabel++;
        } 
        else { //one or more neighbors have already got labels
          count = 0;
          found = -1;
          for ( int j=0; j<4; j++) {
            if ( nbs[ j ] != 0 ) {
              count +=1;
              found = j;
            }
          }
          if ( count == 1 ) {
            // only one neighbor has a label, so assign the same label to this.
            result = nbls[ found ];
          } 
          else {
            // more than 1 neighbor has a label
            result = nbls[ found ];
            // Equivalence the connected points
            for ( int j=0; j<4; j++) {
              if ( ( nbls[ j ] != 0 ) && (nbls[ j ] != result ) ) {
                associate( nbls[ j ], result );
              }
            }
          }
        }
      }
      dest_1d[i] = result;
    }

    // reduce labels ie 76=23=22=3 -> 76=3
    // done in reverse order to preserve sorting
    for ( int i= labels.length -1; i > 0; i-- ) {
      labels[ i ] = reduce( i );
    }

    // now labels will look something like 1=1 2=2 3=2 4=2 5=5.. 76=5 77=5
    // this needs to be condensed down again, so that there is no wasted
    // space. E.g. in the above, the labels 3 and 4 are not used, instead it jumps to 5
    int condensed[] = new int[ nextlabel ]; // cant be more than nextlabel labels

    count = 0;
    for (int i=0; i< nextlabel; i++) {
      if ( i == labels[ i ] ) condensed[ i ] = count++;
    }
    // Record the number of labels
    numberOfLabels = count - 1;

    // now run back through our preliminary results, replacing the raw label
    // with the reduced and condensed one, and do the scaling and offsets too

    // Now generate an array of colours which will be used to label the image
    labelColors = new int[numberOfLabels+1];
  
    // The likelihood that two colors would be the same... is very small. 
    for (int i = 0; i < labelColors.length; i++) {
      int rr = (int) random(1, 254); 
      int rg = (int) random(1, 254); 
      int rb = (int) random(1, 254); 
      color randomColor = color(rr, rg, rb, 255); 
      labelColors[i] = randomColor;

      if (i == 0) labelColors[i] = black;
      if (i == 1) labelColors[i] = white;
    }

    for (int i=0; i< src1_1d. length; i++) {
      result = condensed[ labels[ dest_1d[ i ] ] ];
      dest_1d[i] = labelColors[result];
    }

    labelsValid = true; // only set to true now we've complete the task
    return dest_1d;
  }

  //----------------------------------------------------------------------
  //return the number of unique, non zero colours. -1 if not valid
  int getColors() {
    if ( labelsValid ) {
      return numberOfLabels;
    } 
    else {
      return -1;
    }
  }

  //----------------------------------------------------------------------
  //Returns the number of labels.
  int getNumberOfLabels() {
    return numberOfLabels;
  }

  //----------------------------------------------------------------------
  int[] getLabelColors() {
    return labelColors;
  }
}



