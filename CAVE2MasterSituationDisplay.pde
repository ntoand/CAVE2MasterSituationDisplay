/**
 * ---------------------------------------------
 * CAVE2MasterSituationDisplay.pde
 * Description: CAVE2 Master Situation Display (MSD)
 *
 * Class: 
 * System: Processing 2.0a5, SUSE 12.1, Windows 7 x64
 * Author: Arthur Nishimoto
 * Version: 0.4 (alpha)
 *
 * Version Notes:
 * 11/6/12      - Initial version
 * 12/7/12      - Audio support, 3D view
 * ---------------------------------------------
 */

import oscP5.*;
import netP5.*;
import processing.net.*;
import omicronAPI.*;

OmicronAPI omicronManager;

EventListener eventListener;

PApplet applet;

PFont st_font;
PFont space_font;

float programTimer;
float deltaTime;
float lastFrameTime;
float startTime;

boolean demoMode = true; // No active contollers and trackables enables demo mode (rotates CAVE2 image)
boolean scaleScreen = false;
boolean logErrors = false;

float lastInteractionTime;
float timeSinceLastInteractionEvent;

String systemText = "MASTER SITUATION DISPLAY";

// CAVE2 model -----------------------------------
float CAVE2_Scale =  65;

float CAVE2_verticalScale = 0.33;

// In meters:
float CAVE2_diameter = 3.429 * 2;
float CAVE2_innerDiameter = 3.2 * 2;
float CAVE2_legBaseWidth = 0.254;
float CAVE2_legHeight = 2.159;
float CAVE2_lowerRingHeight = 0.3048;
float CAVE2_displayWidth = 1.02;
float CAVE2_displayHeight = 0.579;
float CAVE2_displayDepth = 0.08;
float CAVE2_displayToFloor = 0.317;

float speakerHeight = CAVE2_legHeight * 1.3;
float speakerWidth = 0.2;

float CAVE2_rotation = 15; //degrees

PVector CAVE2_screenPos;
PVector CAVE2_3Drotation = new PVector();

float CAVE2_worldZPos = -300;

// Tracker ---------------------------------------
boolean connectToTracker = true;
String trackerIP = "cave2tracker.evl.uic.edu";
int msgport = 28000;
int dataport = 7734;

Trackable headTrackable;
Trackable wandTrackable1;
Trackable wandTrackable2;
Trackable wandTrackable3;
Trackable wandTrackable4;

PImage psNavigationOutline;

PImage psNavigation_cross;
PImage psNavigation_circle;
PImage psNavigation_up;
PImage psNavigation_down;
PImage psNavigation_left;
PImage psNavigation_right;

PImage psNavigation_L1;
PImage psNavigation_L2;
PImage psNavigation_L3;

float lastTrackerUpdateTime;

float reconnectTrackerTimer = 10;
float reconnectTrackerDelay = 6.0f;
float connectionTimer = 0;
float connectionTime = 0;

Button headButton;
Button wandButton1;
Button wandButton2;
Button wandButton3;
Button wandButton4;

// Audio -----------------------------------------
OscP5 oscP5;
int recvPort = 8000;

// Cluster ---------------------------------------
NodeDisplay[] nodes = new NodeDisplay[37];
float[] columnPulse = new float[21];

// Override of PApplet init() which is called before setup()
public void init() {
  super.init();

  // Creates the OmicronAPI object. This is placed in init() since we want to use fullscreen
  omicronManager = new OmicronAPI(this);

  // Removes the title bar for full screen mode (present mode will not work on Cyber-commons wall)
  omicronManager.setFullscreen(true);
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
  if( wandTrackable3!= null )
    wandTrackable1.outputErrorsToFile();
  if( wandTrackable4!= null )
    wandTrackable2.outputErrorsToFile();
}// exit

// Program initializations
void setup() {
  //size( 540, 960, P3D ); // Droid Razr
  size( screenWidth, screenHeight, P3D );

  width = 2560;
  height = 1600;
  
  applet = this;
  oscP5 = new OscP5(this,recvPort);
  CAVE2_screenPos = new PVector( width * 0.5, height * CAVE2_verticalScale, -100 );
   
  startTime = millis() / 1000.0;

  // Make the connection to the tracker machine
  if( connectToTracker )
    omicronManager.connectToTracker(dataport, msgport, trackerIP);
  
  // Create a listener to get events
  eventListener = new EventListener();
  
  omicronManager.setEventListener( eventListener );
  
  // Screen scaling
  omicronManager.enableScreenScale(scaleScreen);
  omicronManager.calculateScreenTransformation(2560,1440); // Single display on CAVE2 column display
  
  st_font = loadFont("TMP-Monitors-48.vlw");
  space_font = loadFont("SpaceAge-48.vlw");
  textFont( st_font, 16 );
  
  ortho(0, width, 0, height, -1000, 1000);
  
  for( int i = 0; i < 37; i++)
  {
    nodes[i] = new NodeDisplay(i);
  }
  
  for( int i = 0; i < 21; i++)
  {
    columnPulse[i] = random(0,0) / 100.0;
  }

  psNavigationOutline = loadImage("PS3Navigation.png");
  psNavigation_cross = loadImage("PS3Navigation_cross.png");
  psNavigation_circle = loadImage("PS3Navigation_circle.png");
  psNavigation_up = loadImage("PS3Navigation_up.png");
  psNavigation_down = loadImage("PS3Navigation_down.png");
  psNavigation_left = loadImage("PS3Navigation_left.png");
  psNavigation_right = loadImage("PS3Navigation_right.png");
  psNavigation_L1 = loadImage("PS3Navigation_L1.png");
  psNavigation_L2 = loadImage("PS3Navigation_L2.png");
  psNavigation_L3 = loadImage("PS3Navigation_L3.png");
  
  headTrackable = new Trackable( 0, "Head 1" );
  
  wandTrackable1 = new Trackable( 1, "Wand 1 Type A (Batman/Kirk)" );
  wandTrackable1.secondID = 0; // Controller 0 is mapped to Wand 1
  
  wandTrackable2 = new Trackable( 2, "Wand 2 Type B (Robin/Spock)" );
  wandTrackable2.secondID = 1; // Controller 1 is mapped to Wand 2
  //wandTrackable2.loadErrorsFromFile();
  
  wandTrackable3 = new Trackable( 3, "Wand 3 Type A (Batman/Kirk)" );
  wandTrackable3.secondID = 2; // Controller 1 is mapped to Wand 2
  
  wandTrackable4 = new Trackable( 4, "Wand 4 Type B (Robin/Spock)" );
  wandTrackable4.secondID = 3; // Controller 1 is mapped to Wand 2
  
  /*
  entranceTriangle = createShape();
  entranceTriangle.fill(24);
  entranceTriangle.noStroke();
  entranceTriangle.vertex(0,0);
  entranceTriangle.vertex(-0.8 * CAVE2_Scale , 3.6 * CAVE2_Scale);
  entranceTriangle.vertex(1.72 * CAVE2_Scale , 3.27 * CAVE2_Scale);
  entranceTriangle.end(); // 2.0a5
  //entranceTriangle.close(CLOSE);
  //entranceTriangle.endShape(); // 2.0b9
  */
  
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
  
  wandButton3 = new Button( 16 * 1, 16 * 6 + 35 * 3, 80, 30 );
  wandButton3.setText("Wand 3", font, 16);
  wandButton3.fillColor = color( 10, 200, 125, 128 );
  
  wandButton4 = new Button( 16 * 1, 16 * 6 + 35 * 4, 80, 30 );
  wandButton4.setText("Wand 4", font, 16);
  wandButton4.fillColor = color( 10, 200, 125, 128 );
  
  ortho(0, width, 0, height, -1000, 1000);
}// setup

void draw() {
  if( scaleScreen )
  {
    omicronManager.pushScreenScale();
    translate( 0, -screenHeight * 0.87 );
  }
  
  programTimer = millis() / 1000.0;
  deltaTime = programTimer - lastFrameTime;
  timeSinceLastInteractionEvent = programTimer - lastInteractionTime;
  
  // Sets the background color
  background(0);
  
  pushMatrix();
  translate( 50, 60 );

  drawTrackerStatus();
  drawClusterStatus();
  
  // Border
  float borderWidth = 20;
  float borderDistFromEdge = 30;
  PVector textOffset = new PVector( width * 0.7, borderWidth );
  
  fill(50);
  rect( borderDistFromEdge + borderWidth/2, borderDistFromEdge, width - borderDistFromEdge * 2 - borderWidth/2, borderWidth ); //Top
  ellipse( borderDistFromEdge + borderWidth/2, borderDistFromEdge + borderWidth/2, borderWidth, borderWidth ); // Top-Left
  ellipse( width - borderDistFromEdge, borderDistFromEdge + borderWidth/2, borderWidth, borderWidth ); // Top-Right
  rect( borderDistFromEdge, borderDistFromEdge + borderWidth/2, borderWidth, height - borderDistFromEdge * 2 - borderWidth/2 ); //Left
  rect( width - borderDistFromEdge - borderWidth/2, borderDistFromEdge + borderWidth/2, borderWidth, height - borderDistFromEdge * 2 - borderWidth/2 ); //Right
  ellipse( borderDistFromEdge + borderWidth/2, height - borderDistFromEdge, borderWidth, borderWidth ); // Bottom-Left
  ellipse( width - borderDistFromEdge, height - borderDistFromEdge, borderWidth, borderWidth ); // Bottom-Right
  rect( borderDistFromEdge + borderWidth/2, height - borderDistFromEdge - borderWidth/2, width - borderDistFromEdge * 2 - borderWidth/2, borderWidth ); // Bottom
  
  textFont( font, 32 );
  fill(10);
  rect( borderDistFromEdge + textOffset.x, height - borderDistFromEdge - borderWidth/2, textWidth(systemText) + borderWidth * 2, borderWidth ); // Bottom
  fill(255);
  text(systemText, borderDistFromEdge + borderWidth + textOffset.x, height - borderDistFromEdge - borderWidth/2  + textOffset.y);
  textFont( font, 16 );
  
  // For event and fullscreen processing, this must be called in draw()
  omicronManager.process();
  lastFrameTime = programTimer;
  
  if( scaleScreen )
  {
    omicronManager.popScreenScale();
  }
}// draw

void mouseDragged()
{
  lastInteractionTime = programTimer;
  float dy = pmouseY - mouseY;
  float dx = pmouseX - mouseX;
  
  
  CAVE2_3Drotation.x = constrain( CAVE2_3Drotation.x + dy / 500.0, 0, radians(90) );
  CAVE2_3Drotation.y += dx / 500.0;
  
  //println("Dragged: "+CAVE2_3Drotation);
}// mouseDragged

void mousePressed()
{
  lastInteractionTime = programTimer;
  
  PVector meters = screenToMeters( mouseX, mouseY );
  PVector displayPos = metersToScreen( meters );
  //println( "ScreenPos "+ displayPos.x  + " " + displayPos.y );
  //println( "MetersPos "+meters.x  + " " + meters.z );
  //println( "-----" );
  
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
  
  if( wandButton3.isPressed( mouseX, mouseY ) )
  {
      headButton.selected = false;
      wandButton1.selected = false;
      wandButton2.selected = false;
      wandButton4.selected = false;
  }
  
  if( wandButton4.isPressed( mouseX, mouseY ) )
  {
      headButton.selected = false;
      wandButton1.selected = false;
      wandButton2.selected = false;
      wandButton3.selected = false;
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
  float screenOffsetX = CAVE2_screenPos.x;
  float screenOffsetY = CAVE2_screenPos.y;
  return new PVector( (xPos - screenOffsetX)/CAVE2_Scale, 0, (yPos - screenOffsetY)/CAVE2_Scale );
}

PVector metersToScreen( PVector position )
{
  float displayX = (position.x * CAVE2_Scale) + CAVE2_screenPos.x;
  float displayY = (position.z * CAVE2_Scale) + CAVE2_screenPos.y;
  float displayZ = 0;
  
  return new PVector( displayX, displayY, displayZ );
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

  fill(0,100,0,128); // y
  noStroke();
  ellipse( 0, 0, 5, 5);
  text("y", 5, -5 );
  noFill();
  stroke(0,100,0,128);
  strokeWeight(1);
  ellipse( 0, 0, 10, 10);
  
  rotateY( radians(270) );
  line( 30, 0, 0, 0 );
  
  popMatrix();
}
