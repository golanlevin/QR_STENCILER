// Author: "Golan Levin" <golanlevin@gmail.com>
//=====================================================================
void QRStencilerInfo() {
  if (DO_PRINT_INSTRUCTIONS) {
    //
    //            ___  ___   ___ _____ ___ _  _  ___ ___ _    ___ ___
    //           / _ \| _ \ / __|_   _| __| \| |/ __|_ _| |  | __| _ \
    //          | (_) |   / \__ \ | | | _|| .` | (__ | || |__| _||   /
    //           \__\_\_|_\ |___/ |_| |___|_|\_|\___|___|____|___|_|_\
    //           By Golan Levin and Asa Foster III for FFFFF.AT, 2011-2025
    //
    println ();
    println (" ********************************************************");
    println (" *                                                      *");
    println (" *  QR_STENCILER                                        *");
    println (" *  Version: 19 September, 2025                         *");
    println (" *  https://github.com/golanlevin/QR_STENCILER          *");
    println (" *  http://fffff.at/qr-stenciler-and-qr-hobo-codes/     *");
    println (" *  By Golan Levin and Asa Foster III for FFFFF.AT      *");
    println (" *  Developed with Processing, a free, cross-platform   *");
    println (" *  Java programming toolkit for the arts.              *");
    println (" *                                                      *");
    println (" *  ABOUT                                               *");
    println (" *  This free program loads a user-specified QR code    *");
    println (" *  image, from which it generates a topologically      *");
    println (" *  correct stencil PDF, suitable for laser-cutting.    *");
    println (" *                                                      *");
    println (" *  COMPATIBILITY                                       *");
    println (" *  >> QR_STENCILER has been tested in MacOSX 15.6.     *");
    println (" *     and works with Processing v.3.5.4 and 4.4.7.     *");
    println (" *                                                      *");
    println (" *  INSTRUCTIONS                                        *");
    println (" *  1. Make a QR code image which embeds a brief text.  *");
    println (" *  2. Download and install 'Processing' from           *");
    println (" *     http://www.processing.org/download               *");
    println (" *  3. Unzip 'QR_STENCILER.zip' to a folder.            *");
    println (" *  4. Put your QR code image in 'QR_STENCILER/data/'   *");
    println (" *  5. Launch Processing and open 'QR_STENCILER.pde'    *");
    println (" *  6. Press 'Run' (Command-R) to start the stenciler.  *");
    println (" *  7. You will be prompted to Open your QR code image. *");
    println (" *     A default will be opened if none is provided.    *");
    println (" *  8. After doing so, the program will generate a      *");
    println (" *     stencil PDF in the 'data' folder.                *");
    println (" *  9. That PDF can now be opened in your favorite CAD  *");
    println (" *     software, for laser-cutting cardboard, etc.      *");
    println (" *  10. After marking your stencil, test it with a QR   *");
    println (" *     reader, such as your iPhone camera app.          *");
    println (" *                                                      *");
    println (" *  LICENSE                                             *");
    println (" *  QR_STENCILER shall be used for Good, not Evil.      *");
    println (" *  It is licensed under a Creative Commons             *");
    println (" *  Attribution-NonCommercial-ShareAlike 3.0 Unported   *");
    println (" *  License (by-nc-sa 3.0), as described at             *");
    println (" *  http://creativecommons.org/licenses/by-nc-sa/3.0/   *");
    println (" *  You are free to distribute, remix, and modify       *");
    println (" *  QR_STENCILER, so long as you share alike and        *");
    println (" *  provide attribution to FFFFF.AT. The repackaging    *");
    println (" *  of QR_STENCILER as or into commercial software, is  *");
    println (" *  expressly prohibited. Please note that QR_STENCILER *");
    println (" *  also enjoys protections under the GRL Repercussions *");
    println (" *  3.0 license, http://bit.ly/cc-repercussions.        *");
    println (" *  The 100 QR_HOBO_CODES and their respective stencils *");
    println (" *  are hereby dedicated to the public domain.          *");
    println (" *                                                      *");
    println (" *  WARRANTY                                            *");
    println (" *  This software is provided AS IS, without warranty   *");
    println (" *  of any kind, expressed or implied, including but    *");
    println (" *  not limited to the warranties of merchantibility,   *");
    println (" *  fitness for a particular purpose, and noninfringe-  *");
    println (" *  ment. In no event shall the authors be liable for   *");
    println (" *  any claim, damages or other liability, whether in   *");
    println (" *  an action of contract, tort or otherwise, arising   *");
    println (" *  from, out of or in connection with this software    *");
    println (" *  or its use.                                         *");
    println (" *                                                      *");
    println (" *  ACKNOWLEDGEMENTS                                    *");
    println (" *  The QR_STENCILER was created by Golan Levin and     *");
    println (" *  Asa Foster III with support from the STUDIO for     *");
    println (" *  Creative Inquiry and the School of Art at           *");
    println (" *  Carnegie Mellon University. Thanks to Ben Fry,      *");
    println (" *  Marcus Beausang, Neil Brown & Judy Robertson for    *");
    println (" *  great code. A tip of the hat to Fred Trotter,       *");
    println (" *  Jovino, le Suedois, Patrick Donnelly and others     *");
    println (" *  who have gone down similar paths. Additional        *");
    println (" *  thanks to Andrea Boykowycz for creative input.      *");
    println (" *  Some of the QR Hobo Codes are inspired by:          *");
    println (" *  http://www.worldpath.net/~minstrel/hobosign.htm     *");
    println (" *  http://cockeyed.com/archive/hobo/modern_hobo.html   *");
    println (" *  http://en.wikipedia.org/wiki/Warchalking            *");
    println (" * 'QR code' is trademarked by Denso Wave, Inc.         *");
    println (" *                                                      *");
    println (" *  CONTACT                                             *");
    println (" *  Inquiries about QR_STENCILER may be directed to:    *");
    println (" *  Golan Levin <golanlevin@gmail.com>                  *");
    println (" *                                                      *");
    println (" ********************************************************");
    println ();
  }
}


import processing.pdf.*;
import javax.swing.*;
import javax.swing.filechooser.FileFilter;
import java.util.Collections;
import java.util.Hashtable;
import java.util.Enumeration;
import controlP5.*;


//=====================================================================
// ADJUSTABLE PARAMETERS: You can change these, if you so desire
//
float BRIDGE_THICKNESS             = 0.17;   // Ratio of bridge thickness to QR grid size, i.e. 1:6
float PDF_LINE_THICKNESS           = 0.50;   // For 0.001" thick lines, use 0.072.
float BRIDGE_CULLING_FACTOR        = 0.60;   // Set between 0..1; Higher values cull more bridges.
int   MIN_BRIDGES_PER_ISLAND       = 3;      // Just what it says
int   CORNER_THICKENING            = 3;      // Number of pixels of corner thickening.
int   ARC_RESOLUTION               = 12;     // Number of points on a generated circular arc corner.
boolean DO_WHITE_PAINT_STENCIL     = false;
boolean DO_ROUNDED_CORNERS         = true;   // Enables corner rounding and path simplification.
boolean USE_BEZIER_NOT_ARCS        = false;  // Enables Bezier exporting instead of generating arc points.
boolean DO_ADVANCED_BRIDGING       = true;   // Chooses between advanced and simple bridging.
boolean DO_ALL_COMPUTED_BRIDGES    = false;  // Invalidates RANDOM_BRIDGE_CULLING_FACTOR
boolean DO_OPEN_PDF_WHEN_DONE      = false;  // Open the stencil PDF in Acrobat when done?
boolean DO_PRINT_INSTRUCTIONS      = false;  // Execute QRStencilerInfo()
boolean B_VERBOSE                  = false;  // Print detailed algorithm status.

//=====================================================================
String QRDefaultImageFilename;
String QRImageFilename;
String QRStencilPDFFilename;
boolean bComputedStencilPDF = false;
PImage QR;

ControlP5 controlP5;
CheckBox  checkbox;
Slider    slider0;
Slider    slider1;
Slider    slider2;
Slider    slider3;
Slider    slider4;
Bang      bang1;
Bang      bang2;
Textlabel myTextlabelA;

//=====================================================================
// Other internal (global) variables and constants.
//
ConnectedComponentLabeler CCL;  // Determines which pixels are holes/islands
ContourTracer CT;   // Traces hole contours for PDF output
PFont tinyPdfFont;
boolean bCompleted;
boolean bSetupPhase;

int blackAndWhiteImage[];
int blackAndWhiteImageInverse[];
int coloredLabeledImage[];
int nPixels;

final color white = color(255);
final color black = color(0);
final int inverseMargin = 1;
final int controlPanelWidth = 250;

final int DIR_UP    = 0;
final int DIR_DOWN  = 1;
final int DIR_LEFT  = 2;
final int DIR_RIGHT = 3;


//===============================================================
void setup() {
  bSetupPhase = true;
  QRStencilerInfo();

  size (1000, 750, JAVA2D);
  pixelDensity(1); // Required after Processing 4.4.6+
  setupGUI(); // see Gui.pde

  QRDefaultImageFilename = sketchPath() + "/data/" + "QR_hello_world.png";
  QRImageFilename = getUserSelectedQRCodeImageFilename(); // See FileLoading.pde
  QR = loadImage (QRImageFilename);

  nPixels = QR.width * QR.height;
  blackAndWhiteImage        = new int[nPixels];
  blackAndWhiteImageInverse = new int[nPixels];
  coloredLabeledImage       = new int[nPixels];

  CCL = new ConnectedComponentLabeler (QR.width, QR.height);
  CT  = new ContourTracer();
  bCompleted = false;

  tinyPdfFont = createFont("Arial", 6);
  bSetupPhase = false;
}


//===============================================================
void draw() {
  if (bCompleted == false) {
    doMainProcess();
    bCompleted = true;
  }
}


//===============================================================
void keyPressed() {
  // Restart computation of a new stencil. Useful if you have some randomization enabled.
  if (key == ' ') {
    bCompleted = false;
  }
}


//===============================================================
void doMainProcess() {
  // This is the main processing routine for the program.
  // Assuming PImage QR contains a valid QR code image,
  // this routine will export a PDF stencil file for it.

  // 1. Extract the pixels (as a color[] array) from the loaded QR image.
  // See Utils.pde for implementation.
  copyBlackAndWhiteImageFromPImage (QR); // see Utils.pde
  if (B_VERBOSE) {
    println("* Extracted pixels.");
  }

  // 2. Some jpgs have compression artifacts that produce "near-black" or "near-white"; enforce pure colors.
  // See Utils.pde for implementation.
  binarizeTheImage (blackAndWhiteImage, QR.width, QR.height); // see Utils.pde
  if (B_VERBOSE) {
    println("* Input image binarized.");
  }

  // 3. Thicken the corners of adjacent grid units, creating a stronger and more effective stencil.
  // See Bridger.pde for implementation.
  bridgeCorners (blackAndWhiteImage, QR.width, QR.height);
  if (B_VERBOSE) {
    println("* Stencil interior corners bridged.");
  }

  // 4. Deal with white-painted QR stenciling, if requested.
  // Involves adding a margin and inversion.
  // See Utils.pde for implementation.
  handleInverseStencil();

  // 5. Uniquely label (with individual colors) each of the blobs; this identifies "islands".
  // See: http://en.wikipedia.org/wiki/Connected-component_labeling
  // See: http://en.wikipedia.org/wiki/Stencil
  // See ConnectedComponentLabeler.pde for implementation.
  coloredLabeledImage = CCL.doLabel(blackAndWhiteImage, QR.width, QR.height);
  if (B_VERBOSE) {
    println("* Stencil islands identified.");
  }

  // 6. Create bridges from the main stencil body to all floaters... so they don't fall out!
  // See Bridger.pde for implementation.
  // bridgeIslands (blackAndWhiteImage, QR.width, QR.height);
  bridgeIslands (blackAndWhiteImage, QR.width, QR.height);
  if (B_VERBOSE) {
    println("* Stencil islands bridged.");
  }

  // 7. Invert the QR image, so that we can find its *holes* with the contour tracer.
  // See Utils.pde for implementation.
  computeBlackAndWhiteInverseBuffer (blackAndWhiteImage, blackAndWhiteImageInverse, nPixels);
  if (B_VERBOSE) {
    println("* Stencil inverted, for hole-finding.");
  }

  // 8. Uniquely label all of the holes in the stencil.
  // See ConnectedComponentLabeler.pde for implementation.
  coloredLabeledImage = CCL.doLabel(blackAndWhiteImageInverse, QR.width, QR.height);
  if (B_VERBOSE) {
    println("* Stencil holes identified.");
  }

  // 9. Trace all of the holes, producing vector-based 8-connected chain codes. See:
  // http://imageprocessingplace.com/downloads_V3/root_downloads/tutorials/contour_tracing_Abeer_George_Ghuneim/alg.html
  // See ContourExtraction.pde for implementation.
  CT.traceBlobContours (coloredLabeledImage, QR.width, QR.height);
  if (B_VERBOSE) {
    println("* Stencil holes traced.");
  }

  // 10. Draw the contours (chain codes) of the holes, and export a PDF of the result.
  // This PDF can now be loaded into Illustrator, etc. and used for laser-cutting.
  String QrPdfFileName = drawAndExportPDF(); // See below for implementation.
  println("* Your stencil PDF has been exported to the 'data' folder, here:\n  " + QrPdfFileName);

  // 11. Draw the QR to the screen, as it will appear and with the exported stencil contour lines.
  drawPrettyResultsToScreen();
  println ("  Done creating QR stencil at " + hour() + ":" + minute() + ":" + second() + " \n");
}


//===============================================================
void drawPrettyResultsToScreen() {

  background ((DO_WHITE_PAINT_STENCIL) ? black : white);
  fill (100);
  rect(0, 0, controlPanelWidth, height);


  boolean bCenterVersusScale = true;
  pushMatrix();

  float drawMargin = 50;
  float scaleFactor = (float)(height - drawMargin*2) / (float)(max(QR.height, QR.width));
  translate(controlPanelWidth, 0);
  translate(drawMargin, drawMargin);
  scale (scaleFactor, scaleFactor);


  stroke(255, 0, 128);
  strokeWeight(1.0/scaleFactor);
  fill ((DO_WHITE_PAINT_STENCIL) ? white : black);
  if (DO_ROUNDED_CORNERS) {
    CT.drawAllChainsWithFilletedCorners();
  } else {
    CT.drawAllChains();
  }

  popMatrix();
}


//===============================================================
String drawAndExportPDF() {

  // generate the filename for the stencil PDF.
  int QRImageFilenameLen = QRImageFilename.length();
  String QR_PDFFilename = QRImageFilename.substring(0, QRImageFilename.lastIndexOf('.'));
  String QR_PdfFullFilename  = QR_PDFFilename;
  if (DO_WHITE_PAINT_STENCIL) {
    QR_PdfFullFilename += "_inverse";
  }
  QR_PdfFullFilename += ".pdf";
  QRStencilPDFFilename = QR_PdfFullFilename;
  beginRecord(PDF, QR_PdfFullFilename);

  // Generate the text written on the QR code stencil
  boolean bDrawTitleText = true;
  if (bDrawTitleText) {
    String QR_StencilText = QRImageFilename.substring(QRImageFilename.lastIndexOf('/')+1, QRImageFilename.lastIndexOf('.'));
    if (DO_WHITE_PAINT_STENCIL) {
      QR_StencilText += " (for LIGHT/WHITE marking) ";
    } else {
      QR_StencilText += " (for DARK/BLACK marking) ";
    }
    QR_StencilText += " --- Generated by QR_STENCILER, http://fffff.at/qr-stenciler-and-qr-hobo-codes/";
    fill(0, 0, 0);
    textFont(tinyPdfFont, 6);
    text(QR_StencilText, 10, 10);
  }


  pushMatrix();
  translate((width - QR.width)/2.0, (height - QR.height)/2.0);

  strokeWeight (PDF_LINE_THICKNESS);
  stroke(0, 0, 0);
  noFill();
  if (DO_ROUNDED_CORNERS) {
    CT.drawAllChainsWithFilletedCorners();
  } else {
    CT.drawAllChains();
  }

  popMatrix();
  endRecord();

  bComputedStencilPDF = true;
  if (DO_OPEN_PDF_WHEN_DONE) {
    launch (QR_PdfFullFilename);
  }
  return QR_PdfFullFilename;
}
