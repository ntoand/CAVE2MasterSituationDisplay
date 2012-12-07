/**
 * ---------------------------------------------
 * OmicronKinectExample.pde
 * Description: Omicron Processing Kinect example.
 *
 * Class: 
 * System: Processing 2.0a5, SUSE 12.1, Windows 7 x64
 * Author: Arthur Nishimoto
 * Version: 0.1 (alpha)
 *
 * Version Notes:
 * 8/3/12      - Initial version
 * ---------------------------------------------
 */

import processing.net.*;
//import omicronAPI.*;

OmicronAPI omicronManager;

EventListener eventListener;
Hashtable userSkeletons;

PApplet applet;
PFont font;
float programTimer;
float startTime;

float displayScale =  65;

float CAVE2_verticalScale = 0.33;

// In meters:
float CAVE2_diameter = 3.429 * 2;
float CAVE2_innerDiameter = 3.2 * 2;
float CAVE2_legBaseWidth = 0.254;
float CAVE2_legHeight = 2.159;
float CAVE2_lowerRingHeight = 0.3048;
float CAVE2_displayWidth = 1.02;
float CAVE2_displayDepth = 0.08;

float CAVE2_rotation = 15; //degrees
PShape entranceTriangle;

Trackable headTrackable;
Trackable wandTrackable1;
Trackable wandTrackable2;

PImage psNavigationOutline;

PImage psNavigation_cross;
PImage psNavigation_circle;
PImage psNavigation_up;
PImage psNavigation_down;
PImage psNavigation_left;
PImage psNavigation_right;

PImage psNavigation_L1;
PImage psNavigation_L2;

String trackerIP = "cave2tracker.evl.uic.edu";
int msgport = 28000;
int dataport = 7734;
float lastTrackerUpdateTime;

float reconnectTrackerTimer = 10;
float reconnectTrackerDelay = 6.0f;
float connectionTimer = 0;
float connectionTime = 0;

Button headButton;
Button wandButton1;
Button wandButton2;

PVector CAVE2_screenPos;
PVector CAVE2_3Drotation = new PVector();

// Override of PApplet init() which is called before setup()
public void init() {
  super.init();

  // Creates the OmicronAPI object. This is placed in init() since we want to use fullscreen
  omicronManager = new OmicronAPI(this);

  // Removes the title bar for full screen mode (present mode will not work on Cyber-commons wall)
  omicronManager.setFullscreen(false);
}// init

void exit()
{
  super.exit();
  
  // Output tracker drop data to text files
  if( headTrackable!= null )
    headTrackable.outputErrorsToFile();
  if( wandTrackable1!= null )
    wandTrackable1.outputErrorsToFile();
  if( wandTrackable2!= null )
    wandTrackable2.outputErrorsToFile();
}// exit

// Program initializations
void setup() {
  size( 540, 960, P3D ); // Droid Razr
   
  applet = this;
  CAVE2_screenPos = new PVector( width/2, height * CAVE2_verticalScale );
   
  startTime = millis() / 1000.0;

  // Make the connection to the tracker machine
  omicronManager.connectToTracker(dataport, msgport, trackerIP);
  //omicronManager.ConnectToTracker(7739, 28000, "131.193.77.211");
  
  // Create a listener to get events
  eventListener = new EventListener();
  
  omicronManager.setEventListener( eventListener );
  
  font = loadFont("ArialMT-48.vlw");
  textFont( font, 16 );
  
  psNavigationOutline = loadImage("PS3Navigation.png");
  psNavigation_cross = loadImage("PS3Navigation_cross.png");
  psNavigation_circle = loadImage("PS3Navigation_circle.png");
  psNavigation_up = loadImage("PS3Navigation_up.png");
  psNavigation_down = loadImage("PS3Navigation_down.png");
  psNavigation_left = loadImage("PS3Navigation_left.png");
  psNavigation_right = loadImage("PS3Navigation_right.png");
  psNavigation_L1 = loadImage("PS3Navigation_L1.png");
  psNavigation_L2 = loadImage("PS3Navigation_L2.png");
  
  userSkeletons = new Hashtable();
  
  headTrackable = new Trackable( 0, "Head 1" );
  wandTrackable1 = new Trackable( 1, "Wand 1 (Batman/Kirk)" );
  wandTrackable1.secondID = 0; // Controller 0 is mapped to Wand 1
  
  wandTrackable2 = new Trackable( 2, "Wand 2 (Robin/Spock)" );
  wandTrackable2.secondID = 1; // Controller 1 is mapped to Wand 2
  
  entranceTriangle = createShape();
  entranceTriangle.fill(24);
  entranceTriangle.noStroke();
  entranceTriangle.vertex(0,0);
   entranceTriangle.vertex(-0.8 * displayScale , 3.6 * displayScale);
  entranceTriangle.vertex(1.72 * displayScale , 3.27 * displayScale);
  entranceTriangle.end(CLOSE);
  
  headButton = new Button( 16 * 1, 16 * 6, 80, 30 );
  headButton.setText("Head 1", font, 16);
  headButton.fillColor = color( 10, 200, 125, 128 );
  
  wandButton1 = new Button( 16 * 1, 16 * 6 + 35, 80, 30 );
  wandButton1.setText("Wand 1", font, 16);
  wandButton1.fillColor = color( 10, 200, 125, 128 );
  wandButton1.selected = true;
  
  wandButton2 = new Button( 16 * 1, 16 * 6 + 35 * 2, 80, 30 );
  wandButton2.setText("Wand 2", font, 16);
  wandButton2.fillColor = color( 10, 200, 125, 128 );
  
  ortho();
}// setup

void draw() {
  programTimer = millis() / 1000.0;
  
  // Sets the background color
  background(24);
  
  fill(0,250,250);
  text("CAVE2(TM) System Locator (Version 0.2 - alpha)", 16, 16);
  
  float timeSinceLastTrackerUpdate = programTimer - lastTrackerUpdateTime;
  
  
  text("Connected to '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
  text("Receiving data on dataport: " + dataport, 16, 16 * 3);

  if( timeSinceLastTrackerUpdate >= 5 )
  {
    fill(250,250,50);
    text("No active controllers or trackables in CAVE2", 16, 16 * 4);
  }
  
  /*
  if( timeSinceLastTrackerUpdate < 2 )
  {
    text("Connected to '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
    text("Receiving data on dataport: " + dataport, 16, 16 * 3);
    reconnectTrackerTimer = programTimer + reconnectTrackerDelay;
  }
  else
  {
    fill(250,50,50);
    text("LOST CONNECTION TO '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
    text("TIME SINCE LAST UPDATE: " + timeSinceLastTrackerUpdate, 16, 16 * 3);
    
    float reconnectTimer = reconnectTrackerTimer - programTimer;
    
    
    if( reconnectTimer > 1 )
    {
      text("CHECK OMEGALIB - OINPUTSERVER STATUS", 16, 16 * 4);
      text("ATTEMPTING RECONNECT IN " + (int)reconnectTimer , 16, 16 * 5);
      connectionTime = programTimer;
    }
    else
    {
      text("CHECK OMEGALIB - OINPUTSERVER STATUS", 16, 16 * 4);
      //text("ATTEMPTING RECONNECT - MAY HANG FOR 70 SECONDS", 16, 16 * 4);
      //text("OR UNTIL OINPUTSERVER CONNECTION IS ESTABLISHED", 16, 16 * 5);
      connectionTimer = programTimer - connectionTime;
      
      if( reconnectTimer < 0 )
      {
        //this.unregisterDispose(omicronManager);
        //omicronManager.ConnectToTracker(dataport, msgport, trackerIP);
        //reconnectTrackerTimer = millis() / 1000.0 + reconnectTrackerDelay;
      }
    }
    
    if( connectionTimer < 5 )
    {
      background(24);
      fill(0,250,250);
      text("CAVE2(TM) System Locator (Version 0.2 - alpha)", 16, 16);
      text("Connected to '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
      text("Receiving data on dataport: " + dataport, 16, 16 * 3);
      //reconnectTrackerTimer = programTimer + reconnectTrackerDelay;
      
      fill(250,250,50);
      text("No active controllers or trackables in CAVE2", 16, 16 * 4);
    }
    
    
  }*/
  
  
  
  // Draw CAVE2 ------------------------------------------------------------------
  pushMatrix();
  translate( CAVE2_screenPos.x, CAVE2_screenPos.y );
  rotateX( CAVE2_3Drotation.x ); 
  rotateZ( CAVE2_3Drotation.y );
  
  translate( 0, 0, -100 );
  
  // CAVE2 vertical supports
  noFill();
  stroke(0,250,250);
  strokeWeight(2);
  for( int i = 0; i < 9; i++ )
  {
    pushMatrix();
    rotate( radians(CAVE2_rotation) );
    rotate( radians(45) * i );
    translate( CAVE2_diameter/2 * displayScale - CAVE2_legBaseWidth / 2 * displayScale, -CAVE2_legBaseWidth/2 * displayScale, CAVE2_legHeight/2 * displayScale );
    
    //rectMode(CENTER);
    box( CAVE2_legBaseWidth * displayScale, CAVE2_legBaseWidth * displayScale, CAVE2_legHeight * displayScale );
    popMatrix();
  }
  
  // CAVE2 displays
  for( int i = 0; i < 21; i++ )
  {
    pushMatrix();
    rotate( radians(18) * i ); 
    
    translate( CAVE2_diameter/2 * displayScale - (CAVE2_legBaseWidth + CAVE2_displayDepth) * displayScale, 0, (CAVE2_legHeight/2 + CAVE2_lowerRingHeight)* displayScale );
    //rectMode(CENTER);
    stroke(0,50,200);
    if( !(i == 4 || i == 5) )
      box( CAVE2_displayDepth * displayScale, CAVE2_displayWidth * displayScale, (CAVE2_legHeight - CAVE2_lowerRingHeight) * displayScale );
    popMatrix();
  }
  
  // CAVE2 diameter (inner-screen, outer ring) - upper ring
  pushMatrix();
  translate( 0, 0, CAVE2_legHeight * displayScale );
  stroke(0,250,250);
  ellipse( 0, 0, CAVE2_diameter * displayScale, CAVE2_diameter * displayScale );
  stroke(0,50,200);
  ellipse( 0, 0, CAVE2_innerDiameter * displayScale, CAVE2_innerDiameter * displayScale );
  popMatrix();
  
  // Cover entrance
  //shape(entranceTriangle);
  // -----------------------------------------------------------------------------

  drawCoordinateSystem( 0, 0 );
  wandTrackable2.draw();
  wandTrackable1.draw();
  headTrackable.draw();

  popMatrix();
  
  wandTrackable2.drawText();
  wandTrackable1.drawText();
  headTrackable.drawText();
  
  headButton.draw();
  wandButton1.draw();
  wandButton2.draw();
  
  if( headButton.selected )
  {
    headTrackable.selected = true;
    wandTrackable1.selected = false;
    wandTrackable2.selected = false;
    
    displayTrackableWindow( headTrackable, 0, height - 328 );
    wandButton1.selected = false;
    wandButton2.selected = false;
  }
  else if( wandButton1.selected )
  {
    displayControllerWindow( wandTrackable1, 0, height - 328 );
    headButton.selected = false;
    wandButton2.selected = false;
    
    headTrackable.selected = false;
    wandTrackable1.selected = true;
    wandTrackable2.selected = false;
    
  }
  else if( wandButton2.selected )
  {
    displayControllerWindow( wandTrackable2, 0, height - 328 );
    headButton.selected = false;
    wandButton1.selected = false;
    
    headTrackable.selected = false;
    wandTrackable1.selected = false;
    wandTrackable2.selected = true;
  }
  
  // For event and fullscreen processing, this must be called in draw()
  omicronManager.process();
}// draw

void mouseDragged()
{
  float dy = pmouseY - mouseY;
  float dx = pmouseX - mouseX;
  
  CAVE2_3Drotation.x += dy / 500.0;
  CAVE2_3Drotation.y += dx / 500.0;
  
  println("Dragged: "+CAVE2_3Drotation);
}// mouseDragged

void mousePressed()
{
  PVector meters = screenToMeters( mouseX, mouseY );
  println( "ScreenPos "+ mouseX  + " " + mouseY );
  println( "MetersPos "+meters.x  + " " + meters.y );
  println( "-----" );
  
  //meters.x *= 1;
  //meters.y = meters.y * CAVE2_verticalScale + (screenToMeters(width,height).y *CAVE2_verticalScale);
  
  if( headButton.isPressed( mouseX, mouseY ) )
  {
      wandButton1.selected = false;
      wandButton2.selected = false;
  }
  
  if( wandButton1.isPressed( mouseX, mouseY ) )
  {
      headButton.selected = false;
      wandButton2.selected = false;
  }
  
  if( wandButton2.isPressed( mouseX, mouseY ) )
  {
      headButton.selected = false;
      wandButton1.selected = false;
  }
  
  if( headTrackable.isPressed( meters.x, meters.y ) )
  {
      headButton.selected = true;
      wandButton1.selected = false;
      wandButton2.selected = false;
  }
  
  if( wandTrackable1.isPressed( meters.x, meters.y ) )
  {
      headButton.selected = false;
      wandButton1.selected = true;
      wandButton2.selected = false;
  }
  
  if( wandTrackable2.isPressed( meters.x, meters.y ) )
  {
      headButton.selected = false;
      wandButton1.selected = false;
      wandButton2.selected = true;
  }
  
}

PVector screenToMeters( int xPos, int yPos )
{
  return new PVector( (xPos - CAVE2_screenPos.x)/displayScale, (yPos - CAVE2_screenPos.y)/displayScale );
}

PVector metersToScreen( PVector position )
{
  float displayX = (position.x * displayScale) + CAVE2_screenPos.x;
  float displayZ = (position.z * displayScale) + CAVE2_screenPos.y;
  
  return new PVector( displayX, displayZ );
}

void drawCoordinateSystem( int x, float y )
{
  // Coordinate System
  pushMatrix();
  translate( x, y );
  
  fill(0,0,200,128); // Z
  stroke(0,0,200,128);
  line( 0, 0, 0, 30 ); 
  text("z", 5, 32 );
  
  fill(200,0,0,128); // X
  stroke(200,0,0,128);
  line( 30, 0, 0, 0 );
  text("x", 35, 0 );

  fill(0,200,0,128); // y
  noStroke();
  ellipse( 0, 0, 5, 5);
  text("y", 5, -5 );
  noFill();
  stroke(0,200,0,128);
  strokeWeight(1);
  ellipse( 0, 0, 10, 10);
  popMatrix();
}
