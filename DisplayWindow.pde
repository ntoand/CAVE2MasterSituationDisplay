PVector controllerImagePos = new PVector( 480 , 0 );

void displayTrackableWindow( Trackable t, float xPos, float yPos )
{
  
  pushMatrix();
  translate( xPos, yPos );
  
  fill(0);
  noStroke();
  rect(0,-16 * 2, 800, 400);
  
  fill( t.currentMocapColor );
  
  textAlign(RIGHT);
  text( String.format("%.2f", t.position.x) + " meters \n" + String.format("%.2f", t.position.y) + " meters \n" + String.format("%.2f", t.position.z) + " meters ", 16 * 1 + 180, 16 * 2 );
  text( String.format("%.2f", t.rotation.x) + " degrees \n" + String.format("%.2f", t.rotation.y) + " degrees \n" + String.format("%.2f", t.rotation.z) + " degrees ", 16 + 450, 16 * 2 );
  
  textAlign(LEFT);
  text( "x: \ny: \nz: ", 16 * 1, 16 * 2 );
  text( "roll: \npitch: \nyaw: ", 16 + 200, 16 * 2 );
  
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
  
  text( "Mocap ID: "+ t.ID, 16 * 1, 16 * 1 );
  
  fill( t.colorMinor );
  text( "Minor Tracking Drops: " + t.minorDrops, 16 * 1, 16 * 6 );
  fill( t.colorModerate );
  text( "Moderate Tracking Drops: " + t.moderateDrops, 16 * 1, 16 * 7 );
  fill( t.colorMajor );
  text( "Major Tracking Drops: " + t.majorDrops, 16 * 1, 16 * 8 );
  popMatrix();
}// displayTrackable

void displayControllerWindow( Trackable t, float xPos, float yPos )
{
  pushMatrix();
  translate( xPos, yPos );
  
  fill(0);
  noStroke();
  rect(0,-16 * 2, 800, 400);

  fill( t.currentMocapColor );
  textAlign(RIGHT);
  text( String.format("%.2f", t.position.x) + " meters \n" + String.format("%.2f", t.position.y) + " meters \n" + String.format("%.2f", t.position.z) + " meters ", 16 * 1 + 180, 16 + 16 * 1 );
  text( String.format("%.2f", t.rotation.x) + " degrees \n" + String.format("%.2f", t.rotation.y) + " degrees \n" + String.format("%.2f", t.rotation.z) + " degrees ", 16 + 450, 16 + 16 * 1 );
  
  textAlign(LEFT);
  text( "x: \ny: \nz: ", 16 * 1, 16 + 16 * 1 );
  text( "roll: \npitch: \nyaw: ", 16 + 200, 16 + 16 * 1 );
  
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
  
  text( "Button 1", 16, 16 * 6 );
  text( "Button 2", 16, 16 * 7 );
  text( "Button 3", 16, 16 * 8 );
  text( "Button 4", 16, 16 * 9 );
  text( "Button 5", 16, 16 * 10 );
  text( "Button 6", 16, 16 * 11 );
  text( "Button 7", 16, 16 * 12 );
  
  text( "Button 8", 16, 16 * 13 );
  text( "Button 9", 16, 16 * 14 );
  
  text( "Special Button 1", 16, 16 * 15 );
  text( "Special Button 2", 16, 16 * 16 );
  text( "Special Button 3", 16, 16 * 17 );
  text( "Button Up", 216, 16 * 6 );
  text( "Button Right", 216, 16 * 7 );
  text( "Button Down", 216, 16 * 8 );
  text( "Button Left", 216, 16 * 9 );
  
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
  //ellipse( targetWidth - 282 + 67, 51, 68, 68 );
  PVector analogStick = t.analogStick1;
  PVector analogCenter = new PVector( controllerImagePos.x + 67, controllerImagePos.y + 51 );
  
  if( t.timeSinceLastUpdate < 1 )
  {
    fill(currentColor);
  }
  
  textAlign(RIGHT);
  text( String.format("%.3f",t.analogStick1.x), 416, 16 * 12 );
  text( String.format("%.3f",t.analogStick1.y), 416, 16 * 13 );
  text( String.format("%.3f",t.analogStick2.x), 416, 16 * 14 );
  text( String.format("%.3f",t.analogStick2.y), 416, 16 * 15 );
  text( String.format("%.3f",t.analogStick3.x), 416, 16 * 16 );
  text( String.format("%.3f",t.analogStick3.y), 416, 16 * 17 );
  
  textAlign(LEFT);
  text( "Analog 0: ", 216, 16 * 12 );
  text( "Analog 1: ", 216, 16 * 13 );
  text( "Analog 2: ", 216, 16 * 14 );
  text( "Analog 3: ", 216, 16 * 15 );
  text( "Analog 4: ", 216, 16 * 16 );
  text( "Analog 5: ", 216, 16 * 17 );
  
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
    text( "IS CONTROLLER ON? TRACKED? - TIME SINCE LAST UPDATE: " + String.format("%.2f", t.timeSinceLastUpdate), 16, 16 * 0 );
  }
  else
  {
    text( t.name+" Controller Status", 16, 16 * -1 );
  }
  text( "Mocap/Wand ID: "+ t.ID + "   Controller ID: " + t.secondID, 16 * 1, 16 + 16 * 0 );
  
  noFill();
  stroke(currentColor);
  strokeWeight(1);

  line( analogCenter.x, analogCenter.y, analogCenter.x + analogStick.x * 25, analogCenter.y + analogStick.y * 25 );
  ellipse( analogCenter.x + analogStick.x * 25, analogCenter.y + analogStick.y * 25, 15, 15 );

  
  if( t.analogStick3.x > 0 )
  {
    tint( red(currentColor) * t.analogStick3.x, green(currentColor) * t.analogStick3.x, blue(currentColor) * t.analogStick3.x, alpha(currentColor) );
    image( psNavigation_L2, controllerImagePos.x, controllerImagePos.y );
  }
  
  noStroke();
  tint(currentColor);
  fill(currentColor);
  
  
  if( t.button1 )
  {
    text( "Button 1", 16, 16 * 6 );
  }
  if( t.button3 )
  {
    text( "Button 3", 16, 16 * 8 );
    image( psNavigation_cross, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.button2 )
  {
    text( "Button 2", 16, 16 * 7 );
    image( psNavigation_circle, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.button4 )
  {
    text( "Button 4", 16, 16 * 9 );
  }
  if( t.button5 )
  {
    text( "Button 5", 16, 16 * 10 );
    image( psNavigation_L1, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.button6 )
  {
    text( "Button 6", 16, 16 * 11 ); // L3
    ellipse( analogCenter.x + analogStick.x * 25, analogCenter.y + analogStick.y * 25, 15, 15 );
    image( psNavigation_L3, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.button7 )
  {
    text( "Button 7", 16, 16 * 12 ); // L2
    image( psNavigation_L2, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.button8 )
  {
    text( "Button 8", 16, 16 * 13 ); // R1
  }
  if( t.button9 )
  {
    text( "Button 9", 16, 16 * 14 ); // R3
  }
  
  if( t.specialButton1 )
  {
    text( "Special Button 1", 16, 16 * 15 );
  }
  if( t.specialButton2 )
  {
    text( "Special Button 2", 16, 16 * 16 );
  }
  if( t.specialButton3 )
  {
    text( "Special Button 3", 16, 16 * 17 );
  }
  if( t.buttonUp )
  {
    text( "Button Up", 216, 16 * 6 );
    image( psNavigation_up, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.buttonDown )
  {
    text( "Button Down", 216, 16 * 8 );
    image( psNavigation_down, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.buttonLeft )
  {
    text( "Button Left", 216, 16 * 9 );
    image( psNavigation_left, controllerImagePos.x, controllerImagePos.y );
  }
  if( t.buttonRight )
  {
    text( "Button Right", 216, 16 * 7 );
    image( psNavigation_right, controllerImagePos.x, controllerImagePos.y );
  }

  image( psNavigationOutline, controllerImagePos.x, controllerImagePos.y );
  
  popMatrix();
}// displayController
