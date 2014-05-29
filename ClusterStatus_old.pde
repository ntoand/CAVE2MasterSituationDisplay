int loadCount = 24;
int fade;
int border = 5; 
int roundness = 0;

int x;
int y;
  
int big = 0; // big screen (1) or laptop (0)
  
int maxRows = 40;
int maxColumns = 26;
   
int lostConnectionTimer = 0;
   
int curv;
   
int scalarX;
int scalarY;

////////////////////////////////////////////////////////////////////
// set the current colour for the 0 to 100 data
// and slowly fade it towards black

void doColor (float c)
{
  float fadeAmount;
  float onePercentColor;
  float col;
 
  fadeAmount = 0.03 * fade;
  onePercentColor = 0.01 * 255;
  col = c*fadeAmount*onePercentColor;
  
  // cheat factor to make low values more visible
  float greenCheatFactor = 1.75;
  
  if (c > 75)
    fill(col, 0, 0);
  else if (c > 50)
    fill(col, col, 0);
  else
    fill(0, col*greenCheatFactor, 20);
}

////////////////////////////////////////////////////////////////////
// set the current colour for the network data
// and slowly fade it towards black

void doColorNet (float c)
{
  float fadeAmount;
  float onePercentColor;
  float greenCheatFactor = 1.25;
 
  fadeAmount = 0.03 * fade;
  onePercentColor = 0.01 * 255;
  
  if (c > 100000) // more than 10 megabytes in last couple seconds
    fill(c*fadeAmount*0.00001*255, 0, 0);
  else if (c > 1000) // more than 1 megabyte  in last couple seconds
    fill(c*fadeAmount*0.001*255, c*fadeAmount*0.001*255, 0);
  else // less than one megabyte  in last couple seconds
    fill(0, c*fadeAmount*0.01*greenCheatFactor*255, 20);
}

////////////////////////////////////////////////////////////////////

void doColorPing(int c)
{
  float fadeAmount;
  float onePercentColor;
  float col;
 
  fadeAmount = 0.03 * fade;
  onePercentColor = 0.01 * 255;
  col = 1*100*fadeAmount*onePercentColor;
  
  if (c > 255)
    c = 255;
  
  if (c  >= 1)
    fill(0, col, 0);
  else
    fill(col, 0, 0);
}

////////////////////////////////////////////////////////////////////

int curvature(int column)
{
  float convertee;
  int col;
  // would be nice to take the column number and use a sin/cos to curve it
  // 17/18 would have 0 change
  // 1/2 and 35/36 would have the most negative
  // sin needs radians in processing
  // -18 to +18
  int c;
  
  if (column == 0)
    col = column - 5;
    else
    col = column;
    
  convertee = (2*(col-9)+45) / 90.0  * 3.14159;
  // 
  return ((int) (scalarY * 1.5 * sin(convertee))-(scalarY));
 //return(0);
}

////////////////////////////////////////////////////////////////////

void drawClusterStatus_old() {

  background(0);

  int tsec = second();  // Values from 0 - 59
  int tmin = minute();  // Values from 0 - 59
  int thr = hour();    // Values from 0 - 23

  int tday = day();    // Values from 1 - 31
  int tmon = month();  // Values from 1 - 12
  int tyr = year();   // 2003, 2004, 2005, etc.

  String ssec = String.valueOf(tsec);
  String smin = String.valueOf(tmin);
  String shr = String.valueOf(thr);
  String sday = String.valueOf(tday);
  String smon = String.valueOf(tmon);
  String syr = String.valueOf(tyr);
  
  // add leading zeros to the minutes and seconds if needed
  String ssec2;
  String zero = "0";
  String old_ssec2 = " ";
  
  if (ssec.length() == 1)
    ssec2 = zero + ssec;
    else
    ssec2 = ssec;

  String smin2;
  
  if (smin.length() == 1)
    smin2 = zero + smin;
  else
    smin2 = smin;

  frame.setTitle(int(frameRate) + " fps");

// on the tower of tiles I am getting REALLY low frame rates (3-4 fps) so I am using the clock to reload once per second
// if I draw nothing I still only get 10 fps

  if (big == 1)
  {
    if (ssec2 != old_ssec2)
    {
      getData();
      old_ssec2 = ssec2;
      loadCount = 0;
    }
  }
  else
  {
    // once every 30 seconds load in new data from the text file on the website
    // this will load in 37 lines - currently the master is first then the 36 display nodes

    if (loadCount >= 30)
    {
      getData();
      loadCount = 0;
      }
    }
    
    loadCount++;
    fade = 50-loadCount;

    // scale the graphics based on the size of the window
    scalarX = width / maxColumns;
    scalarY = height / maxRows;
   
    // horizontal border
    int borderX = scalarX / 2;
  
    float xAxis = maxRows - 1.75; //42.25;
    float xAdjust = 0;

    // heading and clock at the top of the screen

    textFont(myFontBig, width / 33);
 
    fill(255, 255, 255);
    textAlign(LEFT, CENTER);
    text ("cave2  monitor - " + smon + " / " + sday + " / " + syr + " - " + shr + " : " + smin2 + " : " + ssec2, 3*scalarX, 3*scalarY);


    textFont(myFontBig, width / 60);

    stroke(150, 150, 150);
   // textAlign(CENTER, CENTER);
 
   // master on left
   // odd 18 on top
   // even 18 on bottom

  int move_y = 3;

  int topYgpu = 25 + move_y;
    
  int topYnetping = 2 + move_y;
 
  int topYnetout = 3 + move_y;

  int topYnetin = 4 + move_y;

  int topYmem = 6 + move_y;

  int topYcpu = 8 + move_y;

  int topYtext = 26 + move_y;

  float xlabel = 23.25;

  textAlign(LEFT, CENTER);
  text("Net up?", scalarX * xlabel ,topYnetping*scalarY+1.4*scalarY);

  text("Net in", scalarX * xlabel ,topYnetin*scalarY+1.4*scalarY);

  text("Net out", scalarX * xlabel ,topYnetout*scalarY+1.4*scalarY);

  text("GPU0 U", scalarX * xlabel ,topYgpu*scalarY+1.4*scalarY);
  text("GPU0 M", scalarX * xlabel ,topYgpu*scalarY+2.4*scalarY);

  text("Memory", scalarX * xlabel ,topYmem*scalarY+1.4*scalarY);

  text("CPU",   scalarX * xlabel ,(topYcpu)*scalarY+1.4*scalarY);
  text("Cores", scalarX * xlabel ,(topYcpu+1)*scalarY+1.4*scalarY);

  textAlign(CENTER, CENTER);
  // draw the core status
  
  for (int j = 0; j < 21; j+=1) {
    
    curv = curvature(j);
    
    for (int i = 0; i < 16; i++) {

    if (j == 0) // master
      {
      x = scalarX;
      y = scalarY*topYcpu + i*scalarY;
      }
    else
      {
      x = (j+2)*scalarX;
      y = scalarY*topYcpu + i*scalarY;
      }
        
      // draw a coloured rectangle for a particular cpu core
      doColor(allCPUs[j][i]);
      rect(x+xAdjust,y+scalarY-curv,scalarX/2-2*border,scalarY-border, roundness);
     }

    for (int i = 16; i < 32; i++) {
    if (j == 0) // master
      {
      x = scalarX + (scalarX/2);
      y = scalarY*topYcpu + (i-16)*scalarY;
      }
    else
      {
      x = (j+2)*scalarX  + (scalarX/2);
      y = scalarY*topYcpu + (i-16)*scalarY;
      }
      
      // draw a coloured rectangle for a particular cpu core
      doColor(allCPUs[j][i]);
      rect(x+xAdjust-border,y+scalarY-curv,scalarX/2-2*border,scalarY-border, roundness);
     }


    fill(255, 255, 255);

    if (j == 0) // master
      {
      x = scalarX + scalarX/2;
      y = scalarY*topYtext + scalarY;
      }
    else
      {
      x = (j+2)*scalarX + scalarX/2;
      y = scalarY*topYtext + scalarY;
      }
      
      // draw the core number for each node 

      if (j == 0)
        text("master", x+xAdjust,y+2*scalarY-curv);
      else
        text(j, x+xAdjust,y+2*scalarY-curv);
     
      // show the network status of the two connections
      
      if (j == 0) // master
      {
      x = scalarX;
      y = topYnetping* scalarY+scalarY/2 - curv;
      }
    else
      {
      x = (j+2)*scalarX;
      y = topYnetping * scalarY-curv+scalarY/2;
      }

      doColorPing(int(nodePing[j]));
      rect(x+xAdjust,y+scalarY,scalarX-3*border,scalarY/2-border, roundness);  

      if (j == 0) // master
      {
      x = scalarX;
      y = topYnetping* scalarY - curv;
      }
    else
      {
      x = (j+2)*scalarX;
      y = topYnetping * scalarY-curv;
      }
       
      doColorPing(int(nodeCavewavePing[j]));
      rect(x+xAdjust,y+scalarY,scalarX-3*border,scalarY/2-border, roundness);  


  //////

      doColor(allGPUs_usage[j]);
      if (j == 0) // master
      {
      x = scalarX;
      y = topYgpu* scalarY - curv;
      rect(x+scalarX/2-1.5*border, y, 0, 0.8*scalarY);
      }
    else
      {
      x = (j+2)*scalarX;
      y = topYgpu * scalarY-curv;
       rect(x+scalarX/2-1.5*border, y, 0, 0.8*scalarY);
      }
      rect(x+xAdjust,y+scalarY,scalarX-3*border,scalarY-border, roundness);  
      
      //draw GPU mem
      doColor(allGPUs_mem[j]);
      rect(x+xAdjust,y+2*scalarY,scalarX-3*border,scalarY-border, roundness); 
      
      /////
      
      doColorNet(netIn[j]);
      if (j == 0) // master
      {
      x = scalarX;
      y = topYnetin* scalarY - curv;
      
      }
    else
      {
      x = (j+2)*scalarX;
      y = topYnetin * scalarY-curv;
      }
       
      rect(x+xAdjust,y+scalarY,scalarX-3*border,scalarY-border, roundness);  
      
      /////
      
      doColorNet(netOut[j]);
      if (j == 0) // master
      {
      x = scalarX;
      y = topYnetout* scalarY - curv;
      
      }
    else
      {
      x = (j+2)*scalarX;
      y = topYnetout * scalarY-curv;
      }
       
      rect(x+xAdjust,y+scalarY,scalarX-3*border,scalarY-border, roundness); 
      
      /////
      
      doColor(memUsed[j]);
      if (j == 0) // master
      {
      x = scalarX;
      y = topYmem* scalarY - curv;
      rect(x+scalarX/2-1.5*border, y, 0, 0.8*scalarY);
      rect(x+scalarX/2-1.5*border, 2*scalarY + y, 0, 0.8*scalarY);
      }
    else
      {
      x = (j+2)*scalarX;
      y = topYmem * scalarY-curv;
      rect(x+scalarX/2-1.5*border, y, 0, 0.8*scalarY);
      rect(x+scalarX/2-1.5*border, 2*scalarY + y, 0, 0.8*scalarY);
      }
       
      rect(x+xAdjust,y+scalarY,scalarX-3*border,scalarY-border, roundness); 

  }
  
  // center line
  //////////////
  
  fill(255, 255, 255);
 // rect(scalarX*3,20*scalarY,scalarX*18, 0, roundness);

    // draw the legend
    //////////////////
  
     textAlign(LEFT, CENTER);

    doColor(95);
    rect(10*scalarX,34*scalarY,scalarX-2*border,scalarY-border, roundness);
    fill(165, 0, 0);
    text("High", 10*scalarX,36*scalarY); 
  
    doColor(70);
    rect(12*scalarX,34*scalarY,scalarX-2*border,scalarY-border, roundness); 
    fill(165, 165, 0);
    text("Med", 12*scalarX,36*scalarY); 

    doColor(45);
    rect(14*scalarX,34*scalarY,scalarX-2*border,scalarY-border, roundness);
    fill(0, 165, 0);
    text("Low", 14*scalarX,36*scalarY); 
    
    // if we have lost connection then do something more dramatic
    /////////////////////////////////////////////////////////////

    textAlign(CENTER, CENTER);
    textFont(myFontHuge, width / 18);
    
    doColor(95);
    
    // make sure the mpi script is still talking to all of the nodes
   if (lostConnectionTimer > 10)
     {
       text("Connection    Lost", scalarX*12,12*scalarY);
       text("Connection    Lost", scalarX*12,28*scalarY);
     }
     
     // make sure we can still ping all of the nodes
     
    textFont(myFontHuge, width / 25);     
       text(badNode, scalarX*12,14*scalarY);
       text(badNode, scalarX*12,30*scalarY);
}
