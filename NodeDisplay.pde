/**
 * ---------------------------------------------
 * NodeDisplay.pde
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

class Pulse
{
  float curPos = 0;

  public void setPosition(float val)
  {
    curPos = val;
  }
  
  public float getPosition()
  {
    return curPos;
  }
}
  
class NodeDisplay
{
  int nodeID = 0;
  int nodeWidth = 250;
  int nodeHeight = 60;
  
  int cpuBorder = 5;
  
  color baseColor = color(250,200,10);
  color nodeColor = color(10,50,10);

  int[] CPU = new int[16];
   
  int gpuMem;
  int nSegments;
  int nAngledSegments;
  int[] segments;

  boolean nodeDown = false;
  float avgCPU = 0;
    
  ArrayList conduitPulses = new ArrayList();
  
  NodeDisplay( int id )
  {
    nodeID = id;
    
    for( int i = 0; i < 16; i++)
    {
      CPU[i] = (int)random(0,101);
    }
      
    gpuMem = (int)random(0,101);
    
    //nSegments =  conduitLength[nodeID] / (1000 / conduitSegments);
    //nAngledSegments = conduitAngledLength[nodeID] / (1000 / conduitSegments);
    //segments = new int[nSegments+nAngledSegments];
    
    conduitPulses.add( new Pulse() );
  }
  
  float conduitWidth = 40;
  int conduitSegments = 100;
  int decayRate = 10;
  float curSegment;
  int segmentSizeRange = 1;

  float pulseDelay = 2.0;
  float pulseTimer = 0;
  float pulseSpeed = 20;
  
  void update()
  {    
    pulseTimer += deltaTime;
    if( pulseTimer > pulseDelay )
    {
      pulseTimer = 0;
      
      if( !connectToClusterData )
      {
        for( int i = 0; i < 16; i++)
        {
          if( nodeID == 15 )
            CPU[i] = 0;
          else if( nodeID == 0 ) // Master
            CPU[i] = (int)random(23,100);
          else
            CPU[i] = (int)random(0,15);
        }
        
        gpuMem = (int)random(25,70);
        
        
        if( nodeID == 15 )
        {
          gpuMem = 0;
        }
      }
    }

    if( connectToClusterData )
      CPU = allCPUs[nodeID];
    
    avgCPU = 0;
    for( int i = 0; i < 16; i++)
    {
      avgCPU += CPU[i];
    }
    
    avgCPU /= 16 * 100;
    
    // GPU conduit 
    if( connectToClusterData )
      gpuMem = allGPUs[nodeID];
 
    if( gpuMem == 0 && avgCPU == 0 )
      nodeDown = true;
    else
      nodeDown = false;
    
    if( connectToClusterData && (nodePing[nodeID] == false || nodeCavewavePing[nodeID] == false) )
    {
      nodeDown = true;
      gpuMem = 0;
      avgCPU = 0;
    }
    else
      nodeDown = false;
    
    // Demo mode
    if( !connectToClusterData && nodeID == 15 )
    {
      nodeDown = true;
      gpuMem = 0;
      avgCPU = 0;
    }
    
    curSegment += gpuMem / pulseSpeed;
    
    // Bump up the CPU color effect
    avgCPU += 0.1;
    nodeColor = color( red(baseColor) * avgCPU, green(baseColor) * avgCPU, blue(baseColor) * avgCPU );
  }
  
  void drawLeft( float xPos, float yPos )
  {  
    int columnID = (nodeID - 1) / nodesPerColumn;
    int columnPos = (nodeID - 1) % nodesPerColumn;
    
    float displayPosX = 0; // CAVE2 column screen position
    float displayPosY = 0;
    float angledDistance = 0;
    float intersectionX = 0; // Vertical intersection point between line from CAVE2 column to node horizontal
    float intersectionY = 0;
    float angle = 0;
    float straightDistance = 0;
    
    if( displayColumnTransform[columnID] != null )
    {
      stroke( 255 );
      displayPosX = displayColumnTransform[columnID].x * 2 + (targetWidth/2);
      displayPosY = displayColumnTransform[columnID].y * 2 + (targetHeight/2 - 20);
      angle = displayColumnTransform[columnID].z;
      
      float offset = CAVE2_displayWidth/nodesPerColumn * CAVE2_Scale;
      if( nodesPerColumn == 2 )
      {
        float offsetAngle = 90;
        if( columnPos == 0 )
          offsetAngle = -90;
        displayPosX += offset * cos(angle + radians(offsetAngle));
        displayPosY += offset * sin(angle + radians(offsetAngle));
      }
      
      // Position node display location vertically intersects ray from CAVE2 display
      angledDistance = ((yPos - displayPosY) / sin(angle));
      float intersectionDistX = (xPos - displayPosX) / cos(angle);
      
      if( angledDistance < 0 )
        angledDistance = 0;
      
      // Line should stop at node display
      if( angledDistance > displayPosX - xPos )
        angledDistance = displayPosX - xPos - nodeWidth;
      
      // Don't use really small angles - use a straight conduit instead
      if( abs((180 - degrees(angle))) < 2 )
        angledDistance = 0;
          
      intersectionX = displayPosX + angledDistance * cos(angle);
      intersectionY = displayPosY + angledDistance * sin(angle);

      //line( displayPosX, displayPosY, intersectionX, intersectionY );

      noStroke();
      
      straightDistance = intersectionX - (xPos + nodeWidth) - 5;
      if( straightDistance < 0 )
        straightDistance *= -1;
          
      if( segments == null )
      {
        
        nSegments = (int)(straightDistance - 10) / (1000 / conduitSegments);
        nAngledSegments = ((int)angledDistance / (1000 / conduitSegments));
        segments = new int[nSegments+nAngledSegments];
        
        //println(nodeID + " " + straightDistance);
      }
    }
    
    
    // Flip angle since origin is at intersection point, not the display column
    angle += PI;
    
    translate( xPos, yPos );
    update();
    
    textAlign(RIGHT);
    fill(cpuBaseColor);
    text(String.format("%.2f", avgCPU * 100), 20 + nodeWidth + 180, -24 );
    fill(gpuBaseColor);
    text(gpuMem, 365 + nodeWidth, -24 );
    
    textAlign(LEFT);
    fill(cpuBaseColor);
    text("Avg. CPU: ", 20 + nodeWidth, -24 );
    fill(gpuBaseColor);
    text("GPU Mem.: ", 210 + nodeWidth, -24 );

    
    rectMode(CENTER);

    // Angled background segments
    float horzOffset = 0;
    float vertOffset = 0;

    pushMatrix();
    translate( intersectionX - xPos, intersectionY - yPos );
      
    rotate( angle );
    fill(10, 100, 110);
    rect(angledDistance/2, 0, angledDistance, conduitWidth );
    
    //println( nodeID + " " + angledDistance );
    if( angledDistance > 10 )
      ellipse( 0, 0, conduitWidth, conduitWidth );
    popMatrix();
    
    // Straight background segment
    rectMode(CORNER);
    fill(10, 100, 110);
    rect( nodeWidth, -conduitWidth/2, straightDistance, conduitWidth );

    rectMode(CENTER);
    
    // Angled animated segment
    if( nodeDown )
      stroke(0,0,20);
    else
      stroke(200 * (gpuMem / 100.0), 50, 250 * ( 1 - (gpuMem / 100.0)) );

    for( int i = 0; i < nAngledSegments; i++ )
    {
      float segmentValue = 100 * (i / (float)nSegments);
      
      if( (nSegments + i) > curSegment - segmentSizeRange && (nSegments + i) < curSegment + segmentSizeRange )
        segments[nSegments + i] = 100;
      else
        segments[nSegments + i] = segments[nSegments + i] - decayRate;
      
      fill(10,220 * segments[nSegments + i]/100.0, 110);
      
      pushMatrix();
      translate( intersectionX - xPos, intersectionY - yPos, vertOffset);
      rotate( angle );
      rect( i * (1000 / conduitSegments), 0, 5, conduitWidth );
      popMatrix();
    }

    // Straight animated segment
    rectMode(CORNER);
    for( int i = 0; i < nSegments; i++ )
    {
      float segmentValue = 100 * (i / (float)nSegments);
      
      if( i > curSegment - segmentSizeRange && i < curSegment + segmentSizeRange )
        segments[i] = 100;
      else
        segments[i] = segments[i] - decayRate;
      
      fill(10,220 * segments[i]/100.0, 110);
      
      rect( 20 + nodeWidth + i * (1000 / conduitSegments), -conduitWidth/2, 5, conduitWidth );
    }
    
    if( curSegment > nSegments + nAngledSegments )
    {
      curSegment = 0;
      if( nodeID > 0 )
        columnPulse[(nodeID-1)/2] = 1;
    }
    
    // Node info
    rectMode(CORNER);
    pushMatrix();
    translate(0,0,10);
    noStroke();
    
    if( nodeDown )
      fill(250 * (1 - (pulseTimer / pulseDelay)),0,0);
    else
      fill(nodeColor);
      
    ellipse( 0, 0, nodeHeight, nodeHeight );
    
    fill(0);
    rect( 0, -nodeHeight/2, nodeHeight/2, nodeHeight );
    
    fill(nodeColor);
    
    if( nodeDown )
      fill(250 * (1 - (pulseTimer / pulseDelay)),0,0);
    else
      fill(nodeColor);

    rect( 0, -nodeHeight/2, 10, nodeHeight );
    rect( 20, -nodeHeight/2, nodeWidth, nodeHeight );
    
    if( avgCPU < 0.5 )
      fill(baseColor);
    else
      fill(0);
    textAlign(RIGHT);
    textFont( st_font, 20 );
    if( nodeID != 0 )
      text( nodeID, -nodeHeight/2 + 38, 8 );
    else
      text( "M", -nodeHeight/2 + 38, 8 );
      
    textAlign(LEFT);
    textFont( st_font, 16 );

    // CPU Display
    for( int i = 0; i < 16; i++ )
    {
      fill(210,100,10);
      rect( 10 + 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), nodeHeight - cpuBorder * 2 );
      
      fill(0);
      rect( 10 + 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), (1 - (CPU[i] / 100.0)) * (nodeHeight - cpuBorder * 2)  );
    }
    popMatrix();
  }
  
  void drawRight( float xPos, float yPos )
  {
    
    int columnID = (nodeID - 1) / nodesPerColumn;
    int columnPos = (nodeID - 1) % nodesPerColumn;
    
    float displayPosX = 0; // CAVE2 column screen position
    float displayPosY = 0;
    float angledDistance = 0;
    float intersectionX = 0; // Vertical intersection point between line from CAVE2 column to node horizontal
    float intersectionY = 0;
    float angle = 0;
    float straightDistance = 0;

    if( columnID >= 0 && displayColumnTransform[columnID] != null )
    {
      stroke( 255 );
      displayPosX = displayColumnTransform[columnID].x * 2 + (targetWidth/2);
      displayPosY = displayColumnTransform[columnID].y * 2 + (targetHeight/2 - 20);
      angle = displayColumnTransform[columnID].z + PI; // flip 180 for right nodes
      
      float offset = CAVE2_displayWidth/nodesPerColumn * CAVE2_Scale;
      if( nodesPerColumn == 2 )
      {
        float offsetAngle = -90;
        if( columnPos == 0 )
          offsetAngle = 90;
        displayPosX += offset * cos(angle + radians(offsetAngle));
        displayPosY += offset * sin(angle + radians(offsetAngle));
      }
      
      // Position node display location vertically intersects ray from CAVE2 display
      angledDistance = ((yPos - displayPosY) / sin(angle));
      float intersectionDistX = (xPos - displayPosX) / cos(angle);

      if( angledDistance > 0 )
        angledDistance *= -1;
      
      // Make sure angle is 0 to 360
      if( angle > 2 * PI )
        angle -= 2 * PI;
        
      // Don't use really small angles - use a straight conduit instead
      int minAngle = 2;
      if( abs((180 - degrees(angle))) < minAngle || abs((180 - degrees(angle))) > 360 - minAngle )
        angledDistance = 0;
      
      intersectionX = displayPosX + angledDistance * cos(angle);
      intersectionY = displayPosY + angledDistance * sin(angle);

      //line( displayPosX, displayPosY, intersectionX, intersectionY );
      //line( xPos, yPos, intersectionX, intersectionY );
      
      noStroke();
      
      straightDistance = intersectionX - (xPos + nodeWidth) - 5;
      if( straightDistance < 0 )
        straightDistance *= -1;
      else
        straightDistance = 0;
      
      //println(nodeID + " " + straightDistance);
      
      // Master node
      if( nodeID == 0 )
      {
        straightDistance = 350;
        angledDistance = 0;
      }
      
      if( segments == null )
      {
        //println(nodeID + " " + straightDistance);
        nSegments = (int)(straightDistance - 15) / (1000 / conduitSegments);
        if( nSegments < 0 )
          nSegments = 0;
          
        nAngledSegments = ((int)-angledDistance / (1000 / conduitSegments));
        segments = new int[nSegments+nAngledSegments];
        //println(nodeID + " " + nSegments + " " + nAngledSegments);
      }
    }
    
    update();
    
    translate( xPos, yPos );
    
    pushMatrix();
    translate( 108, 0 );
    
    textAlign(RIGHT);
    fill(cpuBaseColor);
    text(String.format("%.2f", avgCPU * 100), 20 - nodeWidth + 180, -24 );
    fill(gpuBaseColor);
    text(gpuMem, 365 - nodeWidth, -24 );
    
    textAlign(LEFT);
    fill(cpuBaseColor);
    text("Avg. CPU: ", 20 - nodeWidth, -24 );
    fill(gpuBaseColor);
    text("GPU Mem.: ", 210 - nodeWidth, -24 );
    popMatrix();
    
    rectMode(CENTER);
    pushMatrix();
    translate( 500, 0 );
    rotate( radians(180) );
    
    // Angled background segments
    float horzOffset = 0;
    float vertOffset = 0;

    pushMatrix();
    translate( xPos - intersectionX + 500, 0 );
      
    rotate( angle );
    fill(10, 100, 110);
    rect(angledDistance/2, 0, angledDistance, conduitWidth );
    
    //println( nodeID + ": " + angledDistance );
    if( angledDistance < -5 )
      ellipse( 0, 0, conduitWidth, conduitWidth );
    popMatrix();
    
    // Straight background segment
    rectMode(CORNER);
    fill(10, 100, 110);
    rect( nodeWidth, -conduitWidth/2, straightDistance - 6, conduitWidth );

    // Straight animated segment
    rectMode(CORNER);
    for( int i = 0; i < nSegments; i++ )
    {
      float segmentValue = 100 * (i / (float)nSegments);
      
      if( i > curSegment - segmentSizeRange && i < curSegment + segmentSizeRange )
        segments[i] = 100;
      else
        segments[i] = segments[i] - decayRate;
      
      fill(10,220 * segments[i]/100.0, 110);
      
      rect( 20 + nodeWidth + i * (1000 / conduitSegments), -conduitWidth/2, 5, conduitWidth );
    }
    
    // Angled animated segment
    rectMode(CENTER);
    if( nodeDown )
      stroke(0,0,20);
    else
      stroke(200 * (gpuMem / 100.0), 50, 250 * ( 1 - (gpuMem / 100.0)) );
    
    for( int i = 0; i < nAngledSegments; i++ )
    {
      float segmentValue = 100 * (i / (float)nSegments);
      
      if( (nSegments + i) > curSegment - segmentSizeRange && (nSegments + i) < curSegment + segmentSizeRange )
        segments[nSegments + i] = 100;
      else
        segments[nSegments + i] = segments[nSegments + i] - decayRate;
      
      fill(10,220 * segments[nSegments + i]/100.0, 110);
      
      pushMatrix();
      translate( xPos - intersectionX + 500, intersectionY - yPos, vertOffset);
      //translate( intersectionX - xPos, intersectionY - yPos, vertOffset);
      rotate( angle + PI );
      rect( i * (1000 / conduitSegments), 0, 5, conduitWidth );
      popMatrix();
    }
        
    // Update segments
    if( curSegment > nSegments + nAngledSegments )
    {
      curSegment = 0;
      if( nodeID > 0 )
        columnPulse[(nodeID-1)/2] = 1;
    }
    
    popMatrix();

    // Node info
    rectMode(CORNER);
    pushMatrix();
    translate( 0, 0, 1 );
    noStroke();
    
    if( nodeDown )
      fill(250 * (1 - (pulseTimer / pulseDelay)),0,0);
    else
      fill(nodeColor);
      
    ellipse( nodeWidth * 2, 0, nodeHeight, nodeHeight );
    
    fill(0);
    rect( nodeWidth * 2 - nodeHeight/2, -nodeHeight/2, nodeHeight/2, nodeHeight );
    
    fill(nodeColor);
    
    if( nodeDown )
      fill(250 * (1 - (pulseTimer / pulseDelay)),0,0);
    else
      fill(nodeColor);

    rect( nodeWidth * 2 - 10, -nodeHeight/2, 10, nodeHeight );
    rect( nodeWidth - 20, -nodeHeight/2, nodeWidth, nodeHeight );
    
    if( avgCPU < 0.5 )
      fill(baseColor);
    else
      fill(0);
    textAlign(LEFT);
    textFont( st_font, 20 );
    if( nodeID != 0 )
      text( nodeID, nodeWidth * 2 -nodeHeight/2 + 20, 8 );
    else
      text( "M", nodeWidth * 2 -nodeHeight/2 + 20, 8 );
    
    textAlign(LEFT);
    textFont( st_font, 16 );
    
    // CPU Display
    for( int i = 0; i < 16; i++ )
    {
      fill(200,100,10);
      rect( nodeWidth - 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), nodeHeight - cpuBorder * 2 );
      
      fill(0);
      rect( nodeWidth - 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), (1 - (CPU[i] / 100.0)) * (nodeHeight - cpuBorder * 2)  );
    }
    popMatrix();
  }
}// class NodeDisplay
