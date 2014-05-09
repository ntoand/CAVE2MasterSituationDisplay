/**
 * ---------------------------------------------
 * ClusterStatus.pde
 * Description: CAVE2 Master Situation Display (MSD)
 *
 * Class: 
 * System: Processing 2.1, SUSE 12.1, Windows 7 x64
 * Author: Arthur Nishimoto
 * Copyright (C) 2012-2014
 * Electronic Visualization Laboratory, University of Illinois at Chicago
 *
 * Version Notes:
 * ---------------------------------------------
 */

color cpuBaseColor = color(250,200,10);
color gpuBaseColor = color(50,200,210);

class AppLabel
{
  String name;
  float cpu;
  float gpu;
  boolean flipLabel = false;
  int displayFlag = 0;
  
  AppLabel( String appName, float gpuValue, float cpuValue, boolean flipLabel, int displayFlag )
  {
    name = appName;
    cpu = cpuValue;
    gpu = gpuValue;
    this.flipLabel = flipLabel;
    this.displayFlag = displayFlag;
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
  
  public int getDisplayFlag()
  {
    return displayFlag;
  }
}



float peakCPU;
float peakGPU;

float updateTransitionTime = 0.1;
float targetCPU = 1;
float targetGPU = 1;

void drawClusterStatus()
{
  systemText = "CLUSTER PROCESSING UNIT STATUS";
  
  CAVE2_Scale = 64;
  CAVE2_3Drotation.x = 0;
  CAVE2_3Drotation.y = 0;
  CAVE2_displayMode = COLUMN;
  
  float averageCPU = 0;
  float averageGPU = 0;
  
  float verticalOffset = 125;
  
  // Master node
  pushMatrix();
  nodes[0].drawRight(targetWidth - 70 - borderDistFromEdge - 500, targetHeight - verticalOffset - borderDistFromEdge - verticalNodeSpacing * nNodesLeft + verticalNodeSpacing * (nNodes - nNodesLeft) );
  
  averageCPU += nodes[0].avgCPU;
  averageGPU += nodes[0].gpuMem;
  popMatrix();
  
  // Left display nodes
  for( int i = 1; i < nNodesLeft + 1; i++ )
  {
    pushMatrix();
    //translate( 70 + borderDistFromEdge, targetHeight - verticalOffset - borderDistFromEdge + 70 * -i );
    nodes[i].drawLeft( 70 + borderDistFromEdge, targetHeight - verticalOffset - borderDistFromEdge + verticalNodeSpacing * -i  );
    popMatrix();
    
    averageCPU += nodes[i].avgCPU;
    averageGPU += nodes[i].gpuMem;
  }
  
  // Right display nodes
  
  for( int i = nNodesLeft+1; i < nNodes; i++ )
  {
    pushMatrix();
    nodes[i].drawRight(targetWidth - 70 - borderDistFromEdge - 500, targetHeight - verticalOffset + rightNodeOffset - borderDistFromEdge - verticalNodeSpacing * nNodesLeft + verticalNodeSpacing * (i - (nNodesLeft+1)));
    popMatrix();
    
    averageCPU += nodes[i].avgCPU;
    averageGPU += nodes[i].gpuMem;
  }
  
  // Draw CAVE2 ------------------------------------------------------------------
  pushMatrix();
  translate( targetWidth/2, targetHeight/2 - 20, 0);
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
  fill(0);
  noStroke();
  rect( 0, targetHeight - 200, targetWidth, 180 );
  
  averageCPU = averageCPU / 37 * 100 - 10;
  averageGPU = (averageGPU - 10) / 37; // Remember the 10% padding done for vis?
  
  if( targetCPU > averageCPU )
    targetCPU -= updateTransitionTime;
  if( targetCPU < averageCPU )
    targetCPU += updateTransitionTime;
  
  if( targetGPU > averageGPU )
    targetGPU -= updateTransitionTime;
  if( targetGPU < averageGPU )
    targetGPU += updateTransitionTime;
  
  float horzBarPosX = borderDistFromEdge + borderWidth + 16;
  float horzBarPosY = targetHeight - borderDistFromEdge - 120 + 16 * 1.5;
  float barLength = targetWidth - horzBarPosX * 2;
  float barWidth = 20;
  
  float cpuMarkerHeight = 32;
  float gpuMarkerHeight = 32;
  
  textAlign(LEFT);
  fill(cpuBaseColor);
  text("CAVE2 CPU: " + String.format("%.2f", averageCPU) + " ("+String.format("%.2f", peakCPU)+" peak)", horzBarPosX + barLength * (targetCPU / 100.0) + 8, horzBarPosY + cpuMarkerHeight + 36);
  fill(gpuBaseColor);
  text("CAVE2 GPU: " + String.format("%.2f", averageGPU) + " ("+String.format("%.2f", peakGPU)+" peak)", horzBarPosX + barLength * (targetGPU / 100.0) + 8, horzBarPosY - gpuMarkerHeight - 8);
  
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
  translate( horzBarPosX + barLength * (targetCPU / 100.0), horzBarPosY + barWidth + cpuMarkerHeight );
  triangle( -triangleSize, triangleSize, 0, 0, 0, triangleSize );
  
  // Line to bar
  stroke( cpuBaseColor );
  line( 0, 0, 0, -gpuMarkerHeight );
  popMatrix();
  
  // GPU Triangle marker
  pushMatrix();
  noStroke();
  fill(100);
  translate( horzBarPosX + barLength * (targetGPU / 100.0), horzBarPosY - gpuMarkerHeight );
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
  
  fill( red(gpuBaseColor)/4, green(gpuBaseColor)/4, blue(gpuBaseColor)/4 );
  rect( horzBarPosX, horzBarPosY, barLength * (peakGPU / 100.0), barWidth/2 );
  
  fill( red(cpuBaseColor)/4, green(cpuBaseColor)/4, blue(cpuBaseColor)/4 );
  rect( horzBarPosX, horzBarPosY + barWidth/2, barLength * (peakCPU / 100.0), barWidth/2 );
  
  fill(gpuBaseColor);
  rect( horzBarPosX, horzBarPosY, barLength * (targetGPU / 100.0), barWidth/2 );
  
  fill(cpuBaseColor);
  rect( horzBarPosX, horzBarPosY + barWidth/2, barLength * (targetCPU / 100.0), barWidth/2 );
  
  popMatrix();
  
  for( int i = 0; i < appList.size(); i++ )
  {
    AppLabel app = (AppLabel)appList.get(i);
    if( app != null )
    {
      float gpuAppLabelHeight = gpuMarkerHeight/2;
      float cpuAppLabelHeight = cpuMarkerHeight;
      String appName = app.getName();
      float gpuValue = app.getGPU();
      float cpuValue = app.getCPU();
      boolean flipped = app.isFlipped();
      int displayFlag = app.getDisplayFlag();
      
      if( flipped )
        textAlign(RIGHT);
      else
        textAlign(LEFT);
      
      if( displayFlag == 0 || displayFlag == 1 )
      {
        fill(10,120,210);
        stroke(10,120,210);
        pushMatrix();
        translate( horzBarPosX + barLength * (gpuValue / 100.0), horzBarPosY - gpuAppLabelHeight, 1 );
        text( appName + " " + gpuValue + "   ", 8, 0 );
        line( 0, -8, 0, gpuAppLabelHeight );
        popMatrix();
      }
      
      if( displayFlag == 0 || displayFlag == 2 )
      {
        fill(150,100,10);
        stroke(150,100,10);
        pushMatrix();
        translate( horzBarPosX + barLength * (cpuValue / 100.0), horzBarPosY + barWidth + cpuAppLabelHeight, 1 );
        text( appName + " " + cpuValue + "   ", 8, 0 );
        line( 0, -cpuAppLabelHeight, 0, 0 );
        popMatrix();
      }
      
      textAlign(LEFT);
    }
  }
  noStroke();
  
  // Spiral P5 ------------------------------------------------------------------
  
  int nPoints = 1000;
  float k = 0.1;
  float t = 2;

  t = targetCPU;
  nPoints = (int)targetGPU + 1;
  
  fill(0,0,0,20);
  rect(0, 0, targetWidth, targetHeight);
  
  fill(200);
  noStroke();
  //ellipse( mouseX, mouseY, 50, 50 );
  
  // Linear spiral
  pushMatrix();
  translate(targetWidth/2, targetHeight/2 - 20 );
  rotate( millis() / t );
  for( int th = 0; th < 3600; th += (3600 / nPoints) )
  {
    float R = k * th;
    float X = R * sin(th);
    float Y = R * cos(th);
    float Z = R;
    
    pushMatrix();
    translate( X, Y );
    scale( 0.05 );
    tint(0, 250 * (100.0/R), 250 * (200.0/R) );
    
    image( circleImg, 0, 0 );
    popMatrix();
  }
  
  popMatrix();
  
  //nPoints = mouseX; //96 straight line spiral
  //k = mouseY / 1000.0;
  
  
  if( nPoints <= 0 )
    nPoints = 1;
    
  if( t <= 0 )
    t = 1;
  
}
