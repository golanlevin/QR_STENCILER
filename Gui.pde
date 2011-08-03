


//===============================================================
void setupGUI() {
  controlP5 = new ControlP5(this);
  
  myTextlabelA = controlP5.addTextlabel("label","QR_STENCILER BY F.A.T. LAB      ",30,50);
  
  bang1    = controlP5.addBang("recomputeStencil", 30, 80, 20, 20);
  bang2    = controlP5.addBang("openPDFInAcrobat", 30, 350, 20, 20);

  bang1.setTriggerEvent(Bang.RELEASE);
  bang1.setLabel("RE-COMPUTE STENCIL");
  bang2.setTriggerEvent(Bang.RELEASE);
  bang2.setLabel("OPEN PDF IN ACROBAT"); 

  checkbox = controlP5.addCheckBox("checkBox", 30, 130);
  checkbox.setColorForeground(color(120));
  checkbox.setColorActive(color(255));
  checkbox.setColorLabel(color(255));
  checkbox.setItemsPerRow(1);
  checkbox.setSpacingColumn(0);
  checkbox.setSpacingRow(10);
  // add items to a checkbox.
  checkbox.addItem("INVERT STENCIL", 1);
  checkbox.addItem("DO ALL COMPUTED BRIDGES", 1); 
  checkbox.addItem("DO ROUNDED CORNERS", 1);
  checkbox.addItem("USE BEZIER NOT ARCS", 1);

  // float sliders
  slider0  = controlP5.addSlider("BRIDGE_CULLING_FACTOR", 0.00, 0.99, 0.50,   30, 230, 100, 10);
  slider1  = controlP5.addSlider("BRIDGE_THICKNESS", 0.05, 0.30, 0.17,        30, 250, 100, 10);
  slider2  = controlP5.addSlider("PDF_LINE_THICKNESS", 0.0072, 1.00, 0.50,    30, 270, 100, 10);

  // int sliders
  slider3  = controlP5.addSlider("MIN_BRIDGES_PER_ISLAND", 1, 4, 3,           30, 290, 100, 10);
  slider4  = controlP5.addSlider("CORNER_THICKENING", 1, 10, 3,               30, 320, 100, 10);

  slider3.setNumberOfTickMarks(4);
  slider3.setSliderMode(Slider.FLEXIBLE);
  slider4.setNumberOfTickMarks(10);
  slider4.setSliderMode(Slider.FLEXIBLE);


  int n = 0;
  if (DO_WHITE_PAINT_STENCIL) { 
    checkbox.activate(n);
  } 
  else {
    checkbox.deactivate(n);
  }
  n++;

  if (DO_ALL_COMPUTED_BRIDGES) {
    checkbox.activate(n);
  } 
  else {
    checkbox.deactivate(n);
  }
  n++;

  if (DO_ROUNDED_CORNERS) {
    checkbox.activate(n);
  } 
  else {
    checkbox.deactivate(n);
  }
  n++;

  if (USE_BEZIER_NOT_ARCS) {
    checkbox.activate(n);
  } 
  else {
    checkbox.deactivate(n);
  }
  n++;
}



//===============================================================
public void recomputeStencil() {
  bCompleted = false;
}

//===============================================================
public void openPDFInAcrobat() {
  if (bComputedStencilPDF) {
    open (QRStencilPDFFilename);
  }
}

//===============================================================
void controlEvent(ControlEvent theEvent) {
  if (!bSetupPhase) {
    if (theEvent.isGroup()) {
      recomputeStencil();
      // println("got an event from "+theEvent.group().name()+"\t");
      // checkbox uses arrayValue to store the state of individual checkbox-items:
      for (int i=0;i<theEvent.group().arrayValue().length;i++) {
        int val = (int)theEvent.group().arrayValue()[i];

        int n = 0;
        if (i== n++) {
          DO_WHITE_PAINT_STENCIL = (val==1);
        } 
        else if (i==n++) {
          DO_ALL_COMPUTED_BRIDGES= (val==1);
        }
        else if (i==n++) {
          DO_ROUNDED_CORNERS     = (val==1);
        } 
        else if (i==n++) {
          USE_BEZIER_NOT_ARCS    = (val==1);
        }
        println (i + " " + val);
      }
    } 
    else {
      String name = theEvent.name();
      if (name.equals("BRIDGE_CULLING_FACTOR") || 
        name.equals("BRIDGE_THICKNESS") || 
        name.equals("PDF_LINE_THICKNESS") || 
        name.equals("MIN_BRIDGES_PER_ISLAND") || 
        name.equals("CORNER_THICKENING")) {
          if (mouseX != pmouseX){
            recomputeStencil();
          }
      }
    }
  }
}

