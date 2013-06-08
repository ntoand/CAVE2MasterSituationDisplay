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
    
    nSegments =  conduitLength[nodeID] / (1000 / conduitSegments);
    nAngledSegments = conduitAngledLength[nodeID] / (1000 / conduitSegments);
    segments = new int[nSegments+nAngledSegments];
    
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

  void drawLeft()
  {  
    pulseTimer += deltaTime;
    if( pulseTimer > pulseDelay && !connectToClusterData )
    {
      pulseTimer = 0;
      
      if( !connectToClusterData )
      {
        for( int i = 0; i < 16; i++)
        {
          if( nodeID == 15 )
            CPU[i] = 0;
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
      //CPU[i] = (int)random(100,100);
      avgCPU += CPU[i];
    }
    
    avgCPU /= 16 * 100;
    
    
    
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
  
    
    
    // GPU conduit
    if( connectToClusterData )
      gpuMem = allGPUs[nodeID];
    curSegment += gpuMem / pulseSpeed;
    
    if( gpuMem == 0 && avgCPU == 0 )
      nodeDown = true;
    else
      nodeDown = false;
    
    // Bump up the CPU color effect
    avgCPU += 0.1;
    nodeColor = color( red(baseColor) * avgCPU, green(baseColor) * avgCPU, blue(baseColor) * avgCPU );
    
    rectMode(CENTER);

    // Angled background segments
    float horzOffset = 0;
    float vertOffset = 0;

    pushMatrix();
    translate(horzOffset + 20 + nodeWidth + nSegments * (1000 / conduitSegments), vertOffset);
      
    rotate( radians(conduitAngle[nodeID]) );
    fill(10, 100, 110);
    rect(conduitAngledLength[nodeID]/2, 0, conduitAngledLength[nodeID], conduitWidth );

    if( conduitAngledLength[nodeID] > 0 )
      ellipse( 0, 0, conduitWidth, conduitWidth );
    popMatrix();
    
    
    // Straight background segment
    fill(10, 100, 110);
    rect( 20 + nodeWidth + conduitLength[nodeID]/2, 0, conduitLength[nodeID], conduitWidth );
    
    /*
    ArrayList nextPulseList = new ArrayList();
    
    for( int p = 0; p < conduitPulses.size(); p++ )
    {
      Pulse curPulse = (Pulse)conduitPulses.get(p);
      curSegment = curPulse.getPosition();
      */
    
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
      translate(horzOffset + 20 + nodeWidth + nSegments * (1000 / conduitSegments), vertOffset);
      rotate( radians(conduitAngle[nodeID]) );
      rect( i * (1000 / conduitSegments), 0, 5, conduitWidth );
      popMatrix();
    }

    // Straight animated segment
    for( int i = 0; i < nSegments; i++ )
    {
      float segmentValue = 100 * (i / (float)nSegments);
      
      if( i > curSegment - segmentSizeRange && i < curSegment + segmentSizeRange )
        segments[i] = 100;
      else
        segments[i] = segments[i] - decayRate;
      
      fill(10,220 * segments[i]/100.0, 110);
      
      rect( 20 + nodeWidth + i * (1000 / conduitSegments), 0, 5, conduitWidth );
    }
    if( curSegment > nSegments + nAngledSegments )
    {
      curSegment = 0;
      if( nodeID > 0 )
        columnPulse[(nodeID-1)/2] = 1;
    }
    
    /*
      if( curSegment < 100 )
      {
        curPulse.setPosition( curSegment + gpuMem / 55.0 );
        nextPulseList.add( curPulse );
      }
    }
    conduitPulses = nextPulseList;
    */
    
    rectMode(CORNER);
    
    // Node info
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
      fill(10,200,10);
      rect( 10 + 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), nodeHeight - cpuBorder * 2 );
      
      fill(0);
      rect( 10 + 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), (1 - (CPU[i] / 100.0)) * (nodeHeight - cpuBorder * 2)  );
    }
    popMatrix();
  }
  
  void drawRight()
  {
    pulseTimer += deltaTime;
    if( pulseTimer > pulseDelay && !connectToClusterData )
    {
      for( int i = 0; i < 16; i++)
      {
        CPU[i] = (int)random(0,54);
      }
      
      gpuMem = (int)random(0,15);
      pulseTimer = 0;
    }
    
    if( connectToClusterData )
      CPU = allCPUs[nodeID];
    
    avgCPU = 0;
    for( int i = 0; i < 16; i++)
    {
      //CPU[i] = (int)random(100,100);
      avgCPU += CPU[i];
    }
    
    avgCPU /= 16 * 100;
    
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

    // GPU conduit
    if( connectToClusterData )
      gpuMem = allGPUs[nodeID];
    curSegment += gpuMem / pulseSpeed;
    
    if( gpuMem == 0 && avgCPU == 0 )
      nodeDown = true;
    else
      nodeDown = false;
      
    // Bump up the CPU color effect
    avgCPU += 0.1;
    nodeColor = color( red(baseColor) * avgCPU, green(baseColor) * avgCPU, blue(baseColor) * avgCPU );
    
    rectMode(CENTER);
    pushMatrix();
    translate( 500, 0 );
    rotate( radians(180) );
    
    // Angled background segments
    float horzOffset = 0;
    float vertOffset = 0;

    pushMatrix();
    translate(horzOffset + 20 + nodeWidth + nSegments * (1000 / conduitSegments), vertOffset);
      
    rotate( radians(conduitAngle[nodeID]) );
    fill(10, 100, 110);
    rect(conduitAngledLength[nodeID]/2, 0, conduitAngledLength[nodeID], conduitWidth );

    if( conduitAngledLength[nodeID] > 0 )
      ellipse( 0, 0, conduitWidth, conduitWidth );
    popMatrix();
    
    
    // Straight background segment
    fill(10, 100, 110);
    rect( 20 + nodeWidth + conduitLength[nodeID]/2, 0, conduitLength[nodeID], conduitWidth );
    
    /*
    ArrayList nextPulseList = new ArrayList();
    
    for( int p = 0; p < conduitPulses.size(); p++ )
    {
      Pulse curPulse = (Pulse)conduitPulses.get(p);
      curSegment = curPulse.getPosition();
      */
    
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
      translate(horzOffset + 20 + nodeWidth + nSegments * (1000 / conduitSegments), vertOffset);
      rotate( radians(conduitAngle[nodeID]) );
      rect( i * (1000 / conduitSegments), 0, 5, conduitWidth );
      popMatrix();
    }

    // Straight animated segment
    for( int i = 0; i < nSegments; i++ )
    {
      float segmentValue = 100 * (i / (float)nSegments);
      
      if( i > curSegment - segmentSizeRange && i < curSegment + segmentSizeRange )
        segments[i] = 100;
      else
        segments[i] = segments[i] - decayRate;
      
      fill(10,220 * segments[i]/100.0, 110);
      
      rect( 20 + nodeWidth + i * (1000 / conduitSegments), 0, 5, conduitWidth );
    }
    if( curSegment > nSegments + nAngledSegments )
    {
      curSegment = 0;
      if( nodeID > 0 )
        columnPulse[(nodeID-1)/2] = 1;
    }
    
    popMatrix();
    
    rectMode(CORNER);
    
    // Node info
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
      fill(10,200,10);
      rect( nodeWidth - 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), nodeHeight - cpuBorder * 2 );
      
      fill(0);
      rect( nodeWidth - 3 * cpuBorder + ( 2 + nodeWidth / 18) * i, cpuBorder - nodeHeight/2, (nodeWidth / 18), (1 - (CPU[i] / 100.0)) * (nodeHeight - cpuBorder * 2)  );
    }
    popMatrix();
  }
}// class NodeDisplay
