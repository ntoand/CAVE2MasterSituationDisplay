class NodeDisplay
{
  int nodeID = 0;
  int nodeWidth = 250;
  int nodeHeight = 70;
  
  int cpuBorder = 5;
  
  color baseColor = color(10,250,10);
  color nodeColor = color(10,50,10);
  
  int[] CPU = new int[16];
  
  int[] conduitLength = new int[37];
  int[] conduitAngledLength = new int[37];
  int[] conduitAngle = new int[37];
  
  int gpuMem;
  
  NodeDisplay( int id )
  {
    nodeID = id;
    
    for( int i = 0; i < 16; i++)
    {
      CPU[i] = (int)random(0,100);
    }
    
    gpuMem = (int)random(0,100);
    
    conduitLength[1] = 0;
    conduitLength[2] = 0;
    conduitLength[3] = 550;
    conduitLength[4] = 520;
    conduitLength[5] = 460;
    conduitLength[6] = 460;
    conduitLength[7] = 440;
    conduitLength[8] = 420;
    
    conduitLength[9] = 410;
    conduitLength[10] = 410;
    
    conduitLength[11] = 420;
    conduitLength[12] = 440;
    conduitLength[13] = 460;
    conduitLength[14] = 460;
    conduitLength[15] = 520;
    conduitLength[16] = 550;
    conduitLength[17] = 0;
    conduitLength[18] = 0;

    conduitAngledLength[1] = 0;
    conduitAngledLength[2] = 0;
    conduitAngledLength[3] = 120;
    conduitAngledLength[4] = 75;
    conduitAngledLength[5] = 60;
    conduitAngledLength[6] = 5;
    conduitAngledLength[7] = 0;
    conduitAngledLength[8] = 0;
    conduitAngledLength[9] = 0;
    conduitAngledLength[10] = 0;
    conduitAngledLength[11] = 0;
    conduitAngledLength[12] = 0;
    conduitAngledLength[13] = 35;
    conduitAngledLength[14] = 80;
    conduitAngledLength[15] = 95;
    conduitAngledLength[16] = 140;
    conduitAngledLength[17] = 0;
    conduitAngledLength[18] = 0;
    
    conduitAngle[1] = 0;
    conduitAngle[2] = 0;
    conduitAngle[3] = -54;
    conduitAngle[4] = -54;
    conduitAngle[5] = -35;
    conduitAngle[6] = -40;
    conduitAngle[7] = 0;
    conduitAngle[8] = 0;
    conduitAngle[9] = 0;
    conduitAngle[10] = 0;
    conduitAngle[11] = 0;
    conduitAngle[12] = 0;
    conduitAngle[13] = 40;
    conduitAngle[14] = 35;
    conduitAngle[15] = 54;
    conduitAngle[16] = 54;
    conduitAngle[17] = 0;
    conduitAngle[18] = 0;

    conduitLength[19] = 0;
    conduitLength[20] = 0;
    conduitLength[21] = 0;
    conduitLength[22] = 0;
    conduitLength[23] = 0;
    conduitLength[24] = 0;
    conduitLength[25] = 0;
    conduitLength[26] = 0;
    conduitLength[27] = 0;
    conduitLength[28] = 0;
    conduitLength[29] = 0;
    conduitLength[30] = 0;
    conduitLength[31] = 0;
    conduitLength[32] = 0;
    conduitLength[33] = 0;
    conduitLength[34] = 0;
    conduitLength[35] = 0;
    conduitLength[36] = 0;
  }
  
  float conduitWidth = 40;
  int conduitSegments = 100;
    
  float curSegment;
  void drawLeft()
  {  
    CPU = allCPUs[nodeID];
    
    float avgCPU = 0;
    for( int i = 0; i < 16; i++)
    {
      //CPU[i] = (int)random(0,100);
      avgCPU += CPU[i];
    }
    
    avgCPU /= 16 * 100;

    text( "Avg CPU: " + String.format("%.2f", avgCPU * 100), 20 + nodeWidth, -16 * 2 );
    text( "GPU Memory: " + gpuMem, 20 + nodeWidth, -16 );
    
    // Bump up the CPU color effect
    avgCPU += 0.1;
    nodeColor = color( red(baseColor) * avgCPU, green(baseColor) * avgCPU, blue(baseColor) * avgCPU );
    
    // GPU conduit
    gpuMem = allGPUs[nodeID];
    curSegment += gpuMem / 20.0;
    
    
    
    float segments =  conduitLength[nodeID] / (1000 / conduitSegments);
    
    // Angled background segments
    float angledSegments = conduitAngledLength[nodeID] / (1000 / conduitSegments);
    
    pushMatrix();
    translate(20 + nodeWidth + segments * (1000 / conduitSegments), -conduitWidth/2);
    rotate( radians(conduitAngle[nodeID]) );
    fill(10, 100, 110);
    rect(0, 0, conduitAngledLength[nodeID], conduitWidth );
    popMatrix();
       
    // Straight background segment
    fill(10, 100, 110);
    rect( 20 + nodeWidth, -conduitWidth/2, conduitLength[nodeID], conduitWidth );
    
    // Angled animated segment
    for( int i = 0; i < angledSegments; i++ )
    {
      float segmentValue = 100 * (i / (float)segments);
      
      if( segments + i == curSegment )
        fill(10,220,110);
      else if( segments + i < curSegment )
        fill(10,220 * ((segments + i)/(float)curSegment), 110);
      else
        fill(10, 0, 110);
     
      pushMatrix();
      translate(20 + nodeWidth + segments * (1000 / conduitSegments), -conduitWidth/2);
      rotate( radians(conduitAngle[nodeID]) );
      rect( i * (1000 / conduitSegments), 0, 5, conduitWidth );
      popMatrix();
    }

    // Straight animated segment
    for( int i = 0; i < segments; i++ )
    {
      float segmentValue = 100 * (i / (float)segments);
      
      if( i == curSegment )
        fill(10,220,110);
      else if( i < curSegment )
        fill(10,220 * (i/(float)curSegment), 110);
      else
        fill(10, 0, 110);
      
      rect( 20 + nodeWidth + i * (1000 / conduitSegments), -conduitWidth/2, 5, conduitWidth );
    }

    
    if( curSegment > 300 )
      curSegment = 0;
    
    
    // Node info
    fill(nodeColor);
    noStroke();
    ellipse( 0, 0, nodeHeight, nodeHeight );
    
    fill(0);
    rect( 0, -nodeHeight/2, nodeHeight/2, nodeHeight );
    
    fill(nodeColor);
    rect( 0, -nodeHeight/2, 10, nodeHeight );
    
    fill(nodeColor);
    rect( 20, -nodeHeight/2, nodeWidth, nodeHeight );
    
    fill(10,200,10);
    textAlign(RIGHT);
    textFont( st_font, 24 );
    text( nodeID, -nodeHeight/2 + 42, 8 );
    
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
  }
  
  void drawRight()
  {
    CPU = allCPUs[nodeID];
    
    float avgCPU = 0;
    for( int i = 0; i < 16; i++)
    {
      //CPU[i] = (int)random(0,100);
      avgCPU += CPU[i];
    }
    
    avgCPU /= 16 * 100;

    text( "Avg CPU: " + String.format("%.2f", avgCPU * 100), 20 + nodeWidth, -16 * 2 );
    text( "GPU Memory: " + gpuMem, 20 + nodeWidth, -16 );
    
    // Bump up the CPU color effect
    avgCPU += 0.1;
    nodeColor = color( red(baseColor) * avgCPU, green(baseColor) * avgCPU, blue(baseColor) * avgCPU );
    
    // GPU conduit
    gpuMem = allGPUs[nodeID];
    curSegment += gpuMem / 20.0;
    
    int conduitOffset = -425;
    fill(10,100,110);
    rect( conduitOffset, -conduitWidth/2, conduitLength[nodeID], conduitWidth );

    float segments =  conduitLength[nodeID] / (1000 / conduitSegments);
    for( int i = 0; i < segments; i++ )
    {
      float segmentValue = 100 * (i / (float)segments);
      
      if( i == curSegment )
        fill(10,220,110);
      else if( i < curSegment )
        fill(10,220 * (i/(float)curSegment), 110);
      else
        fill(10,0,110);
      
      rect( conduitOffset - i * (1000 / conduitSegments) + segments * (1000 / conduitSegments), -conduitWidth/2, 5, conduitWidth );
    }
    
    if( curSegment > 300 )
      curSegment = 0;
      
    // Node info
    fill(nodeColor);
    noStroke();
    ellipse( nodeWidth * 2, 0, nodeHeight, nodeHeight );
    
    fill(0);
    rect( nodeWidth * 2 - nodeHeight/2, -nodeHeight/2, nodeHeight/2, nodeHeight );
    
    fill(nodeColor);
    rect( nodeWidth * 2 - 10, -nodeHeight/2, 10, nodeHeight );
    
    fill(nodeColor);
    rect( nodeWidth - 20, -nodeHeight/2, nodeWidth, nodeHeight );
    
    fill(10,200,10);
    textAlign(LEFT);
    textFont( st_font, 24 );
    text( nodeID, nodeWidth * 2 -nodeHeight/2 + 25, 8 );
    
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
    
  }
}// class NodeDisplay
