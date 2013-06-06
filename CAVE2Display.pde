void drawCAVE2()
{
  // CAVE2 vertical supports
  noFill();
  stroke(20,200,200);
  //strokeWeight(2);
  for( int i = 0; i < 9; i++ )
  {
    pushMatrix();
    rotate( radians(CAVE2_rotation) );
    rotate( radians(45) * i );
    translate( CAVE2_diameter/2 * CAVE2_Scale - CAVE2_legBaseWidth / 2 * CAVE2_Scale, -CAVE2_legBaseWidth/2 * CAVE2_Scale, CAVE2_legHeight/2 * CAVE2_Scale );
    
    //rectMode(CENTER);
    box( CAVE2_legBaseWidth * CAVE2_Scale, CAVE2_legBaseWidth * CAVE2_Scale, CAVE2_legHeight * CAVE2_Scale );
    popMatrix();
  }
  
  // CAVE2 displays
  for( int i = 0; i < 21; i++ )
  {
    /*
    // Display individual screens
    for( int j = 0; j < 4; j++ )
    {
      pushMatrix();
      rotate( radians(18) * i ); 
    
      translate( CAVE2_diameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth + CAVE2_displayDepth) * CAVE2_Scale, 0, (CAVE2_displayHeight * 0.5 + CAVE2_displayToFloor + CAVE2_displayHeight * j) * CAVE2_Scale );
      //rectMode(CENTER);
      stroke(0,50,200);
      if( !(i == 4 || i == 5) )
        box( CAVE2_displayDepth * CAVE2_Scale, CAVE2_displayWidth * CAVE2_Scale, CAVE2_displayHeight * CAVE2_Scale );
      popMatrix();
    }
    */
    
    
    // Display as individual computers
    for( int j = 0; j < 2; j++ )
    {
      pushMatrix();
      rotate( radians(18) * i ); 
    
      translate( CAVE2_diameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth + CAVE2_displayDepth) * CAVE2_Scale, 0, ( CAVE2_displayToFloor + CAVE2_displayHeight + 2 * CAVE2_displayHeight * j) * CAVE2_Scale );
      //rectMode(CENTER);
      stroke(0,50,200);
      fill(0,10,100);
      
      if( !(i == 4 || i == 5) )
        box( CAVE2_displayDepth * CAVE2_Scale, CAVE2_displayWidth * CAVE2_Scale, 2 * CAVE2_displayHeight * CAVE2_Scale );
      popMatrix();
      
      noFill();
    }
    
    
    /*
    // Display as a single column
    pushMatrix();
    rotate( radians(18) * i ); 
    
    translate( CAVE2_diameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth + CAVE2_displayDepth) * CAVE2_Scale, 0, (CAVE2_displayToFloor + 2 * CAVE2_displayHeight) * CAVE2_Scale );
    //rectMode(CENTER);
    stroke(0,50,200);
    if( !(i == 4 || i == 5) )
      box( CAVE2_displayDepth * CAVE2_Scale, CAVE2_displayWidth * CAVE2_Scale, 4 * CAVE2_displayHeight * CAVE2_Scale );
    popMatrix();
    */
  }
  
  // CAVE2 top truss bottom
  pushMatrix();
  translate( 0, 0, (CAVE2_legHeight - 0.0762) * CAVE2_Scale );
  stroke(20,200,200);
  ellipse( 0, 0, CAVE2_diameter * CAVE2_Scale, CAVE2_diameter * CAVE2_Scale );
  stroke(0,50,200);
  ellipse( 0, 0, CAVE2_innerDiameter * CAVE2_Scale, CAVE2_innerDiameter * CAVE2_Scale );
  popMatrix();
  
  // CAVE2 top truss top
  pushMatrix();
  translate( 0, 0, (CAVE2_legHeight + 0.0762) * CAVE2_Scale );
  stroke(20,200,200);
  ellipse( 0, 0, CAVE2_diameter * CAVE2_Scale, CAVE2_diameter * CAVE2_Scale );
  stroke(0,50,200);
  ellipse( 0, 0, CAVE2_innerDiameter * CAVE2_Scale, CAVE2_innerDiameter * CAVE2_Scale );
  popMatrix();
  
}

void drawSpeakers()
{
  stroke(0,100,25);

  for( int i = 0; i < 21; i++ )
  {
    
    pushMatrix();
    rotate( radians(18) * 5 + radians(18) * i ); 

    translate( CAVE2_diameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth + CAVE2_displayDepth) * CAVE2_Scale, 0, speakerHeight * CAVE2_Scale );
    
    if( playingStereo && (i == 7 || i == 8 || i == 12 || i == 13) )
      fill(0,200,50);
    else
      noFill();
      
    //rectMode(CENTER);
    box( speakerWidth * CAVE2_Scale, speakerWidth * CAVE2_Scale, speakerWidth * CAVE2_Scale );
    popMatrix();
  }
}
