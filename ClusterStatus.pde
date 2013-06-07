void drawClusterStatus()
{
  systemText = "PROCESSING UNIT STATUS";
  
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
}
