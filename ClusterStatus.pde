void drawClusterStatus()
{
  systemText = "PROCESSING UNIT STATUS";
  
  CAVE2_Scale = 80;
  CAVE2_3Drotation.x = 0;
  CAVE2_3Drotation.y = 0;
  CAVE2_displayMode = COLUMN;
  
  // Master node
  pushMatrix();
  translate( width/2 - 100, height - 30 - borderDistFromEdge - 80 );
  nodes[0].drawLeft();
  popMatrix();
  
  // Left display nodes
  for( int i = 1; i < 19; i++ )
  {
    pushMatrix();
    translate( 80 + borderDistFromEdge, height - 30 - borderDistFromEdge + 80 * -i );
    nodes[i].drawLeft();
    popMatrix();
  }
  
  // Right display nodes
  for( int i = 19; i < 37; i++ )
  {
    pushMatrix();
    translate( width - 80 - borderDistFromEdge - 500, 130 - borderDistFromEdge + 80 * (i-19) );
    nodes[i].drawRight();
    popMatrix();
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
}
