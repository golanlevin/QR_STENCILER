// Author: "Golan Levin" <golan@flong.com>, 01 August, 2011
//================================================================
String getUserSelectedQRCodeImageFilename () {
  // Ask the user to load a QR code image file.
  // These commands to open a file chooser are taken from: 
  // http://processing.org/discourse/yabb2/YaBB.pl?board=Syntax;action=display;num=1210972905
  
  println("Please select a QR code image file."); 
  QRImageFilename = QRDefaultImageFilename;
  JFileChooser chooser = new JFileChooser();
  boolean bFailed = false;

  try
  {
    File dataDir = new File(sketchPath() + "/data/");
    if (!dataDir.exists()) {
      dataDir.mkdirs();
    }
    
    String fileExtensions[] = {"gif", "jpg", "jpeg", "png", "tiff", "tif"};
    ImageFileFilter IFF = new ImageFileFilter (fileExtensions, "Images");
    
    chooser.setAcceptAllFileFilterUsed (true); 
    chooser.addChoosableFileFilter(IFF);
    chooser.setFileFilter(IFF);
 
    chooser.setDialogTitle("Please select a QR code image!");
    chooser.setApproveButtonText("Load QR Image"); 
    chooser.setApproveButtonToolTipText ("Load the selected QR code. This should be a png, jpg, gif or tif."); 
    chooser.setCurrentDirectory(dataDir); 

    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {

      String tmpString = chooser.getSelectedFile().getName();
      String ext = tmpString.substring(tmpString.lastIndexOf('.') + 1);
      ext.toLowerCase();
      if (ext.equals("jpg") || ext.equals("jpeg") || ext.equals("gif") || ext.equals("png")) {
      //QRImageFilename = chooser.getSelectedFile().getName();
        QRImageFilename = chooser.getSelectedFile().getPath();
        println("You chose to open this file:\n  " + QRImageFilename);
        println();
      } 
      else {
        bFailed = true;
      }
    } 
    else {
      bFailed = true;
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }

  if (bFailed) {
    println("Loading default QR code image: " + QRImageFilename);
  }
  
  return QRImageFilename;
}


//===============================================================
// adapted from http://www.student.nada.kth.se/~u1eetop7/prost/ExampleFileFilter.java
class ImageFileFilter extends FileFilter { 

  private String TYPE_UNKNOWN = "Type Unknown";
  private String HIDDEN_FILE = "Hidden File";

  private Hashtable filters = null;
  private String description = null;
  private String fullDescription = null;
  private boolean useExtensionsInDescription = true;

  //----------------------------------------------------------------
  // Example: new ImageFileFilter (String {"gif", "jpg"}, "Gif and JPG Images");
  // "gif", "jpg", "jpeg", "png", "tiff", "tif"
  public ImageFileFilter(String[] filters, String description) {
    this.filters = new Hashtable();
    for (int i = 0; i < filters.length; i++) {
      addExtension(filters[i]);
    }
    if (description!=null) {
      setDescription(description);
    }
  }

  //----------------------------------------------------------------
  public void addExtension(String extension) {
    if (filters == null) {
      filters = new Hashtable(5);
    }
    filters.put(extension.toLowerCase(), this);
    fullDescription = null;
  }
  
  //----------------------------------------------------------------
  public void setDescription(String description) {
    this.description = description;
    fullDescription = null;
  }

  //----------------------------------------------------------------
  // Returns the human readable description of this filter. For
  // example: "JPEG and GIF Image Files (*.jpg, *.gif)"
  public String getDescription() {
    if (fullDescription == null) {
      if (description == null || isExtensionListInDescription()) {
        fullDescription = description==null ? "(" : description + " (";
        // build the description from the extension list
        Enumeration extensions = filters.keys();
        if (extensions != null) {
          fullDescription += "." + (String) extensions.nextElement();
          while (extensions.hasMoreElements ()) {
            fullDescription += ", " + (String) extensions.nextElement();
          }
        }
        fullDescription += ")";
      } 
      else {
        fullDescription = description;
      }
    }
    return fullDescription;
  }

  //----------------------------------------------------------------
  public boolean accept(File f) {
    if (f != null) {
      if (f.isDirectory()) {
        return true;
      }
      String extension = getExtension(f);
      if (extension != null && filters.get(getExtension(f)) != null) {
        return true;
      };
    }
    return false;
  }
  
  //----------------------------------------------------------------
  public boolean isExtensionListInDescription() {
    return useExtensionsInDescription;
  }

  //----------------------------------------------------------------
  public String getExtension(File f) {
    if (f != null) {
      String filename = f.getName();
      int i = filename.lastIndexOf('.');
      if (i>0 && i<filename.length()-1) {
        return filename.substring(i+1).toLowerCase();
      };
    }
    return null;
  }
  
  //----------------------------------------------------------------
  public void setExtensionListInDescription(boolean b) {
    useExtensionsInDescription = b;
    fullDescription = null;
  }
}
