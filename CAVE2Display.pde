/**
 * ---------------------------------------------
 * CAVE2Display.pde
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

boolean generatedCAVE2Geometry = false;
void generateCAVE2Geometry()
{
  for( int i = 0; i < nColumns; i++ )
  {
    float angle = radians(108) + radians(360 / nColumns) * i; 
      
    float xPos = CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale;
    float yPos = CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale;
    
    xPos *= cos(angle);
    yPos *= sin(angle);
    
    displayColumnTransform[i] = new PVector( xPos, yPos, angle );
    println("Col: " + i + " ("+xPos+","+yPos+")"); 
  }
  generatedCAVE2Geometry = true;
}

void drawCAVE2()
{
  if( !generatedCAVE2Geometry )
    generateCAVE2Geometry();
    
  //println( displayColumnTransform[2] );
  
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
  
  for( int i = 0; i < nColumns; i++ )
  {
    
    // Display individual screens
    if( CAVE2_displayMode == DISPLAY )
      for( int j = 0; j < nDisplaysPerColumn; j++ )
      {
        pushMatrix();
        //rotate( displayColumnTransform[i].z ); 
      
        //translate( CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale, 0, (CAVE2_displayHeight * 0.5 + CAVE2_displayToFloor + CAVE2_displayHeight * 3 - CAVE2_displayHeight * j) * CAVE2_Scale );
        translate( displayColumnTransform[i].x, displayColumnTransform[i].y, (CAVE2_displayHeight * 0.5 + CAVE2_displayToFloor + CAVE2_displayHeight * 3 - CAVE2_displayHeight * j) * CAVE2_Scale );
        rotate( displayColumnTransform[i].z ); 
        
        //rectMode(CENTER);
        stroke(0,50,200);
        if( i < nColumns - (nColumns-nDisplayColumns) )
          box( CAVE2_displayDepth * CAVE2_Scale, CAVE2_displayWidth * CAVE2_Scale, CAVE2_displayHeight * CAVE2_Scale );
        popMatrix();
      }
    
    
    /*
    // Display as individual computers
    if( CAVE2_displayMode == NODE )
      for( int j = 0; j < 2; j++ )
      {
        pushMatrix();
        rotate( angle + radians(360 / nColumns) * i ); 
      
        translate( CAVE2_screenDiameter/2 * CAVE2_Scale, 0, ( CAVE2_displayToFloor + CAVE2_displayHeight * 3 - 2 * CAVE2_displayHeight * j) * CAVE2_Scale );
        //rectMode(CENTER);
        stroke(0,50,200);
        
        if( i < nColumns - (nColumns-nDisplayColumns) )
          box( CAVE2_displayDepth * CAVE2_Scale, CAVE2_displayWidth * CAVE2_Scale, 4 * CAVE2_displayHeight * CAVE2_Scale );
        popMatrix();
      }
    
    */
    // Display as a single column
    if( CAVE2_displayMode == COLUMN )
    {
      pushMatrix();
      //rotate( radians(108) + radians(360 / nColumns) * i ); 
      
      translate( displayColumnTransform[i].x, displayColumnTransform[i].y, (CAVE2_displayToFloor + 2 * CAVE2_displayHeight) * CAVE2_Scale );
      rotate( displayColumnTransform[i].z ); 
      
      //translate( CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale, 0, (CAVE2_displayToFloor + 2 * CAVE2_displayHeight) * CAVE2_Scale );
      //rectMode(CENTER);
      stroke(0,50,200);
      fill( 0, 250 * columnPulse[i], 100 );
      if( i < nColumns - (nColumns-nDisplayColumns) )
        box( CAVE2_displayDepth * CAVE2_Scale, CAVE2_displayWidth * CAVE2_Scale, nDisplaysPerColumn * CAVE2_displayHeight * CAVE2_Scale );
      popMatrix();
    }
    
    noFill();
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

    translate( CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale, 0, speakerHeight * CAVE2_Scale );
    /*
    if( playingStereo && (i == 7 || i == 8 || i == 12 || i == 13) )
      fill(0,200,50);
    else*/
      noFill();
      
    //rectMode(CENTER);
    box( speakerWidth * CAVE2_Scale, speakerWidth * CAVE2_Scale, speakerWidth * CAVE2_Scale );
    popMatrix();
  }
}

void drawCameras()
{
  stroke(0,100,25);

  for( int i = 1; i < 22; i++ )
  {
    
    pushMatrix();
    rotate( radians(18) * 2 + radians(18) * i + radians(45) ); 

    translate( CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale, 0, speakerHeight * CAVE2_Scale );
    
    //noFill();
    fill(0,200,50);
    
    //rectMode(CENTER);
    if( !(i == 4 || i == 6|| i == 10 || i == 14 || i == 16 || i == 20) )
      box( speakerWidth * 1.2 * CAVE2_Scale, speakerWidth * CAVE2_Scale, speakerWidth * CAVE2_Scale );
      
    popMatrix();
  }
}
