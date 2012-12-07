void displayTrackableWindow( Trackable t, int xPos, int yPos )
{
  pushMatrix();
  translate( xPos, yPos );
  
  fill( t.currentMocapColor );
  
  if( t.timeSinceLastMocapUpdate >= 5 )
  {
    fill( 250, 50, 50 );
    text( t.name+" Trackable Status", 16, 16 * -1 );
    text( "NOT TRACKED - TIME SINCE LAST UPDATE: " + String.format("%.2f", t.timeSinceLastMocapUpdate), 16, 16 * 0 );
  }
  else
  {

  }
  text( t.name+" Trackable Status", 16, 16 * -1 );
  text( "x: " + t.position.x + "\ny: " + t.position.y + "\nz: " + t.position.z, 16 * 1, 16 );
  text( "roll: " + t.rotation.x + "\npitch: " + t.rotation.y + "\nyaw: " + t.rotation.z, 16 + 200, 16 );
  
  fill( t.colorMinor );
  text( "Minor Tracking Drops: " + t.minorDrops, 16 * 1, 16 * 6 );
  fill( t.colorModerate );
  text( "Moderate Tracking Drops: " + t.moderateDrops, 16 * 1, 16 * 7 );
  fill( t.colorMajor );
  text( "Major Tracking Drops: " + t.majorDrops, 16 * 1, 16 * 8 );
  popMatrix();
}// displayTrackable

void displayControllerWindow( Trackable t, int xPos, int yPos )
{
  pushMatrix();
  translate( xPos, yPos );
  
  if( t.timeSinceLastUpdate < 2 )
  {
    fill(10, 250, 50, 128);
  }
  else if( t.timeSinceLastUpdate < 5 )
  {
    fill(250, 250, 50, 128);
  }
  else
  {
    fill(250, 50, 50, 128);
  }

  text( "Button 1", 16, 16 * 1 );
  text( "Button 2", 16, 16 * 2 );
  text( "Button 3", 16, 16 * 3 );
  text( "Button 4", 16, 16 * 4 );
  text( "Button 5", 16, 16 * 5 );
  text( "Button 6", 16, 16 * 6 );
  text( "Special Button 1", 16, 16 * 7 );
  text( "Special Button 2", 16, 16 * 8 );
  text( "Special Button 3", 16, 16 * 9 );
  text( "Button Up", 16, 16 * 10 );
  text( "Button Right", 16, 16 * 11 );
  text( "Button Down", 16, 16 * 12 );
  text( "Button Left", 16, 16 * 13 );
  
  color currentColor;
  if( t.timeSinceLastUpdate < 1 )
  {
    currentColor = color(10, 250, 50);
  }
  else if( t.timeSinceLastUpdate < 2 )
  {
    currentColor = color(10, 250, 50, 128);
  }
  else if( t.timeSinceLastUpdate < 5 )
  {
    currentColor = color(250, 250, 50, 128);
  }
  else
  {
    currentColor = color(250, 50, 50, 128);
  }
  
  // Center and diameter of analog region
  //ellipse( width - 282 + 67, 51, 68, 68 );
  PVector analogStick = t.analogStick1;
  PVector analogCenter = new PVector( width - 282 + 67, 51 );
  
  if( t.timeSinceLastUpdate < 1 )
  {
    fill(currentColor);
  }
  
  text( "Analog 1: " + t.analogStick1.x, 16, 16 * 15 );
  text( "Analog 2: " + t.analogStick1.y, 16, 16 * 16 );
  text( "Analog 3: " + t.analogStick2.x, 16, 16 * 17 );
  text( "Analog 4: " + t.analogStick2.y, 16, 16 * 18 );
  text( "Analog 5: " + t.analogStick3.x, 16, 16 * 19 );
  
  if( t.timeSinceLastMocapUpdate >= 5 && t.timeSinceLastUpdate < 5 )
  {
    fill( 250, 150, 50 );
    text( t.name+" Controller Status", 16, 16 * -1 );
    text( "CONTROLLER NOT TRACKED - TIME SINCE LAST UPDATE: " + String.format("%.2f", t.timeSinceLastMocapUpdate), 16, 16 * 0 );
  }
  else if( t.timeSinceLastMocapUpdate < 5 && t.timeSinceLastUpdate >= 5 )
  {
    fill( 250, 150, 50 );
    text( t.name+" Controller Status - NO CONTROLLER DATA", 16, 16 * -1 );
    text( "IS CONTROLLER ON? - TIME SINCE LAST UPDATE: " + String.format("%.2f", t.timeSinceLastUpdate), 16, 16 * 0 );
  }
  else if( t.timeSinceLastMocapUpdate >= 5 && t.timeSinceLastUpdate >= 5 )
  {
    fill( 250, 50, 50 );
    text( t.name+" Controller Status - CONNECTION LOST", 16, 16 * -1 );
    text( "IS CONTROLLER ON? - TIME SINCE LAST UPDATE: " + String.format("%.2f", t.timeSinceLastUpdate), 16, 16 * 0 );
  }
  else
  {
    text( t.name+" Controller Status", 16, 16 * -1 );
  }
  
  
  noFill();
  stroke(currentColor);
  strokeWeight(1);
  line( analogCenter.x, analogCenter.y, analogCenter.x + analogStick.x * 25, analogCenter.y + analogStick.y * 25 );
  ellipse( analogCenter.x + analogStick.x * 25, analogCenter.y + analogStick.y * 25, 15, 15 );
  
  noStroke();
  tint(currentColor);
  fill(currentColor);
  if( t.button1 )
  {
    text( "Button 1", 16, 16 * 1 );
  }
  if( t.button3 )
  {
    text( "Button 3", 16, 16 * 3 );
    image( psNavigation_cross, width - 282, 0 );
  }
  if( t.button2 )
  {
    text( "Button 2", 16, 16 * 2 );
    image( psNavigation_circle, width - 282, 0 );
  }
  if( t.button4 )
  {
    text( "Button 4", 16, 16 * 4 );
  }
  if( t.button5 )
  {
    text( "Button 5", 16, 16 * 5 );
    image( psNavigation_L1, width - 282, 0 );
  }
  if( t.button6 )
  {
    text( "Button 6", 16, 16 * 6 ); // L3
    ellipse( analogCenter.x + analogStick.x * 25, analogCenter.y + analogStick.y * 25, 15, 15 );
  }
  if( t.specialButton1 )
  {
    text( "Special Button 1", 16, 16 * 7 );
  }
  if( t.specialButton2 )
  {
    text( "Special Button 2", 16, 16 * 8 );
  }
  if( t.specialButton3 )
  {
    text( "Special Button 3", 16, 16 * 9 );
  }
  if( t.buttonUp )
  {
    text( "Button Up", 16, 16 * 10 );
    image( psNavigation_up, width - 282, 0 );
  }
  if( t.buttonDown )
  {
    text( "Button Down", 16, 16 * 12 );
    image( psNavigation_down, width - 282, 0 );
  }
  if( t.buttonLeft )
  {
    text( "Button Left", 16, 16 * 13 );
    image( psNavigation_left, width - 282, 0 );
  }
  if( t.buttonRight )
  {
    text( "Button Right", 16, 16 * 11 );
    image( psNavigation_right, width - 282, 0 );
  }

  image( psNavigationOutline, width - 282, 0 );
  
  popMatrix();
}// displayController
