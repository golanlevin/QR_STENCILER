// Author: "Golan Levin" <golan@flong.com>, 01 August, 2011
//================================================================
// Code in this file is NOT USED OR REQUIRED by the QR_STENCILER program. 
// It was used to process the 100 QR hobo codes that accompany QR_STENCILER. 
// Feel free to delete this file. 

// in keyPressed():
// QRImageFilename = getNextHoboFile();
// QR = loadImage (QRImageFilename);
// println("Loading:\t" + QRImageFilename);


ArrayList<String> hoboQRFiles;
int currentHoboFileIndex; 
//===============================================================
void loadHoboFileList(){
  
  hoboQRFiles = new ArrayList<String>();
  currentHoboFileIndex = 0; 
  
  String aFilename;
  String myPath = sketchPath + "/data/QR_hobo_codes/";
  File aFolder = new File(myPath);
  File[] listOfFiles = aFolder.listFiles(); 

  int count = 0;
  for (int i = 0; i < listOfFiles.length; i++) {
    if (listOfFiles[i].isFile()) {
      aFilename = listOfFiles[i].getName();
      if (aFilename.endsWith (".png")) {
        aFilename = myPath + aFilename;
        hoboQRFiles.add(aFilename); 
      }
    }
  }
}

//===============================================================
String getNextHoboFile(){
  String hoboFilename = QRDefaultImageFilename;
  if (currentHoboFileIndex < hoboQRFiles.size()){
    hoboFilename = hoboQRFiles.get(currentHoboFileIndex); 
    currentHoboFileIndex = currentHoboFileIndex+1;
  } 
  return hoboFilename;
}


//===============================================================
void generateHoboCodeHtml() {
  // generates a fragment of an HTML table to present all of the QR hobo codes. 
  String aFilename;
  String myPath = sketchPath + "/data/QR_hobo_codes/";
  File aFolder = new File(myPath);
  File[] listOfFiles = aFolder.listFiles(); 

  int count = 0;
  for (int i = 0; i < listOfFiles.length; i++) {
    if (listOfFiles[i].isFile()) {
      aFilename = listOfFiles[i].getName();
      if (aFilename.endsWith (".png")) {

        String aPDFFile = aFilename.substring(0, aFilename.lastIndexOf('.')) + ".pdf"; 
        String transcription = aFilename.substring(0, aFilename.lastIndexOf('.'));

        String newTranscription = ""; 
        for (int j=0; j<transcription.length(); j++) {
          char c = transcription.charAt(j); 
          if (c == '_') {
            c = ' ';
          }
          newTranscription += c;
        }

        if (count%4 == 0) {
          println("<tr>");
        }

        print("\t<td width=\"125\" align=\"center\" valign=\"top\">");
        print("<a href=\"QR_hobo_codes/" + aFilename + "\">");
        print("<img \n\t\tsrc=\"QR_hobo_codes/" + aFilename + "\" "); 
        print("width=\"108\" height=\"108\" border=\"0\" /></a><br />"); 
        print("<em>" + newTranscription + "</em><br />"); 
        println();
        print("\t\t<a href=\"QR_hobo_codes/" + aFilename + "\">png</a> | "); 
        print("<a href=\"QR_hobo_codes/" + aPDFFile  + "\">stencil</a></td>"); 
        println();

        if ((count%4 == 3) || (i==(listOfFiles.length - 1))) {
          println("</tr>");
        }
        count++;
      }
    }
  }
}

