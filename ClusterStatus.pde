color cpuBaseColor = color(250,200,10);
color gpuBaseColor = color(50,200,210);

class AppLabel
{
  String name;
  float cpu;
  float gpu;
  boolean flipLabel = false;
  AppLabel( String appName, float gpuValue, float cpuValue, boolean flipLabel )
  {
    name = appName;
    cpu = cpuValue;
    gpu = gpuValue;
    this.flipLabel = flipLabel;
  }
  
  public String getName()
  {
    return name;
  }
  
  public float getCPU()
  {
    return cpu;
  }
  
  public float getGPU()
  {
    return gpu;
  }
  
  public boolean isFlipped()
  {
    return flipLabel;
  }
}



float peakCPU;
float peakGPU;

void drawClusterStatus()
{
  systemText = "PROCESSING UNIT STATUS";
  
  CAVE2_Scale = 64;
  CAVE2_3Drotation.x = 0;
  CAVE2_3Drotation.y = 0;
  CAVE2_displayMode = COLUMN;
  
  float averageCPU = 0;
  float averageGPU = 0;
  
  // Master node
  pushMatrix();
  translate( width/2 - 10, height + 15 - borderDistFromEdge - 70 * 3 );
  nodes[0].drawLeft();
  averageCPU += nodes[0].avgCPU;
  averageGPU += nodes[0].gpuMem;
  popMatrix();
  
  // Left display nodes
  float verticalOffset = 125;
  for( int i = 1; i < 20; i++ )
  {
    pushMatrix();
    translate( 70 + borderDistFromEdge, height - verticalOffset - borderDistFromEdge + 70 * -i );
    nodes[i].drawLeft();
    popMatrix();
    
    averageCPU += nodes[i].avgCPU;
    averageGPU += nodes[i].gpuMem;
  }
  
  // Right display nodes
  for( int i = 20; i < 37; i++ )
  {
    pushMatrix();
    translate( width - 70 - borderDistFromEdge - 500, height - verticalOffset - borderDistFromEdge - 70 * 19 + 70 * (i - 20) );
    nodes[i].drawRight();
    popMatrix();
    
    averageCPU += nodes[i].avgCPU;
    averageGPU += nodes[i].gpuMem;
  }

  // Draw CAVE2 ------------------------------------------------------------------
  pushMatrix();
  translate( width/2, height/2 - 20, 0);
  rotateX( CAVE2_3Drotation.x ); 
  rotateZ( CAVE2_3Drotation.y );
  scale( 2, 2, 2 );
  translate( 0, 0, CAVE2_screenPos.z );
  
  drawCAVE2();
  popMatrix();
  
  for( int i = 0; i < columnPulse.length; i++ )
  {
    if( columnPulse[i] > 0 )
      columnPulse[i] = columnPulse[i] - pulseDecay;
    else
      columnPulse[i] = 0;
  }
  // CPU/GPU bar ----------------------------------------------------------------
    
  averageCPU = averageCPU / 37 * 100 - 10;
  averageGPU = (averageGPU - 10) / 37; // Remember the 10% padding done for vis?
  


  float horzBarPosX = borderDistFromEdge + borderWidth + 16;
  float horzBarPosY = height - borderDistFromEdge - 120 + 16 * 2;
  float barLength = width - horzBarPosX * 2;
  float barWidth = 20;
  
  float cpuMarkerHeight = 32;
  float gpuMarkerHeight = 32;
  
  textAlign(LEFT);
  fill(cpuBaseColor);
  text("CAVE2 CPU: " + String.format("%.2f", averageCPU) + " ("+String.format("%.2f", peakCPU)+" peak)", horzBarPosX + barLength * (averageCPU / 100.0) + 8, horzBarPosY + cpuMarkerHeight + 36);
  fill(gpuBaseColor);
  text("CAVE2 GPU: " + String.format("%.2f", averageGPU) + " ("+String.format("%.2f", peakGPU)+" peak)", horzBarPosX + barLength * (averageGPU / 100.0) + 8, horzBarPosY - gpuMarkerHeight - 8);
  
  if( averageCPU > peakCPU )
    peakCPU = averageCPU;
  if( averageGPU > peakGPU )
    peakGPU = averageGPU;
    
  for( int i = 0; i < 101; i += 10 )
  {
    stroke(255);
    line( horzBarPosX + barLength * (i / 100.0), horzBarPosY + barWidth + 10, horzBarPosX + barLength * (i / 100.0), horzBarPosY - 10 );
  }
  noStroke();
  
  float triangleSize = 25;
  
  // CPU Triangle marker
  pushMatrix();
  fill(100);
  translate( horzBarPosX + barLength * (averageCPU / 100.0), horzBarPosY + barWidth + cpuMarkerHeight );
  triangle( -triangleSize, triangleSize, 0, 0, 0, triangleSize );
  
  // Line to bar
  stroke( cpuBaseColor );
  line( 0, 0, 0, -gpuMarkerHeight );
  popMatrix();
  
  // GPU Triangle marker
  pushMatrix();
  noStroke();
  fill(100);
  translate( horzBarPosX + barLength * (averageGPU / 100.0), horzBarPosY - gpuMarkerHeight );
  triangle( -triangleSize, -triangleSize, 0, 0, 0, -triangleSize );
  
  // Line to bar
  stroke( gpuBaseColor );
  line( 0, 0, 0, gpuMarkerHeight );
  popMatrix();
  
  
  pushMatrix();
  translate( 0, 0, 5 );
  stroke(10,20,210);
  fill(20);
  rect( horzBarPosX, horzBarPosY, barLength, barWidth );
  
  fill(gpuBaseColor);
  rect( horzBarPosX, horzBarPosY, barLength * (averageGPU / 100.0), barWidth/2 );
  
  fill(cpuBaseColor);
  rect( horzBarPosX, horzBarPosY + barWidth/2, barLength * (averageCPU / 100.0), barWidth/2 );
  
  popMatrix();
  
  for( int i = 0; i < appList.size(); i++ )
  {
    AppLabel app = (AppLabel)appList.get(i);
    float gpuAppLabelHeight = gpuMarkerHeight/2;
    String appName = app.getName();
    float gpuValue = app.getGPU();
    boolean flipped = app.isFlipped();
    
    if( flipped )
      textAlign(RIGHT);
    else
      textAlign(LEFT);
      
    fill(10,120,210);
    stroke(10,120,210);
    pushMatrix();
    translate( horzBarPosX + barLength * (gpuValue / 100.0), horzBarPosY - gpuAppLabelHeight, 1 );
    text( appName + " " + gpuValue + "   ", 8, 0 );
    
    line( 0, -8, 0, gpuAppLabelHeight );
    popMatrix();
    textAlign(LEFT);
  }
  noStroke();
  
  // Spiral P5 ------------------------------------------------------------------
  
  int nPoints = 1000;
  float k = 0.1;
  float t = 2;

  
  
  fill(0,0,0,20);
  rect(0, 0, width, height);
  /*
  fill(200);
  noStroke();
  //ellipse( mouseX, mouseY, 50, 50 );
  
  // Linear spiral
  pushMatrix();
  translate(width/2, height/2 - 20 );
  rotate( millis() / t );
  for( int th = 0; th < 3600; th += (3600 / nPoints) )
  {
    float R = k * th;
    float X = R * sin(th);
    float Y = R * cos(th);
    float Z = R;
    
    fill(200);
    ellipse( X, Y, 5, 5 );
  }
  
  popMatrix();
  
  nPoints = mouseX; //96 straight line spiral
  //k = mouseY / 1000.0;
  t = mouseY;
  if( nPoints <= 0 )
    nPoints = 1;
    
  if( t <= 0 )
    t = 1;
  */
}
