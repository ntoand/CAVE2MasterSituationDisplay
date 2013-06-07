/**
 * ---------------------------------------------
 * CAVE2MasterSituationDisplay.pde
 * Description: CAVE2 Master Situation Display (MSD)
 *
 * Class: 
 * System: Processing 2.0a5, SUSE 12.1, Windows 7 x64
 * Author: Arthur Nishimoto
 * Version: 0.3 (alpha)
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

float CAVE2_Scale = 80; // Scaling from meters to pixels

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

boolean connectToClusterData = true;
boolean connectToTracker = false;
String trackerIP = "cave2tracker.evl.uic.edu";
int msgport = 28000;
int dataport = 7734;
float lastTrackerUpdateTime;

float reconnectTrackerTimer = 10;
float reconnectTrackerDelay = 6.0f;
float connectionTimer = 0;
float connectionTime = 0;

PVector CAVE2_screenPos;
PVector CAVE2_3Drotation = new PVector();

// Audio data
OscP5 oscP5;
int recvPort = 8000;

boolean demoMode = false; // No active contollers and trackables enables demo mode (rotates CAVE2 image)

float lastInteractionTime;
float timeSinceLastInteractionEvent;

float CAVE2_worldZPos = 0;

boolean scaleScreen = true;

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
}// exit

// Program initializations
void setup() {
  //size( 540, 960, P3D ); // Droid Razr
  size( screenWidth, screenHeight, P3D );

  width = 2560;
  height = 1600;
  
  applet = this;
  oscP5 = new OscP5(this,recvPort);
  
  // CAVE2 model's origin is at the center, bottom of the CAVE.
  // Here we offset the z position by -80 pixels to move the pivot
  // point to approximatly the vertical center of the CAVE
  CAVE2_screenPos = new PVector( width/2, height/2 - 20, -80 );
   
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
}// setup

void draw() {
  for( int i = 0; i < 21; i++)
  {
    if( columnPulse[i] > 0 )
      columnPulse[i] -= 0.05;
    else
      columnPulse[i] = 0;
  }
  
  if( connectToClusterData )
    getData();
  
  if( scaleScreen )
  {
    omicronManager.pushScreenScale();
    translate( 0, -screenHeight * 0.6 );
  }
  
  programTimer = millis() / 1000.0;
  deltaTime = programTimer - lastFrameTime;
  timeSinceLastInteractionEvent = programTimer - lastInteractionTime;
  
  // Sets the background color
  background(0);
  
  fill(200,0,0);
  ellipse( width/2, height/2, 10, 10 );
  
  /*
  pushMatrix();
  translate( 50, 60 );
  
  fill(0,250,250);
  text("CAVE2(TM) System Master Situation Display (Version 0.3 - alpha)", 16, 16);
  
  float timeSinceLastTrackerUpdate = programTimer - lastTrackerUpdateTime;
  
  if( connectToTracker )
  {
    text("Connected to '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
    text("Receiving data on dataport: " + dataport, 16, 16 * 3);
  }
  else
  {
    text("Not connected to tracker", 16, 16 * 2);
    text("Running in demo mode", 16, 16 * 3);
  }
  
  
  if( timeSinceLastTrackerUpdate >= 5 )
  {
    fill(250,250,50);
    text("No active controllers or trackables in CAVE2", 16, 16 * 4);
    
    if( timeSinceLastInteractionEvent >= 30 )
    {
      //CAVE2_3Drotation.x = constrain( CAVE2_3Drotation.x + deltaTime * 0.1, 0, radians(45) );
      //CAVE2_3Drotation.y += deltaTime * 0.1;
      //demoMode = true;
    }
  }
  else
  {
    
    //demoMode = false;
  }
  
  popMatrix();
  */
  
  if( demoMode )
  {
    CAVE2_3Drotation.x = constrain( CAVE2_3Drotation.x + deltaTime * 0.1, 0, radians(90) );
    CAVE2_3Drotation.y += deltaTime * 0.1;
  }
  
  // Draw CAVE2 ------------------------------------------------------------------
  pushMatrix();
  translate( CAVE2_screenPos.x, CAVE2_screenPos.y, CAVE2_worldZPos);
  //rotateX( CAVE2_3Drotation.x ); 
  //rotateZ( CAVE2_3Drotation.y );
  scale( 2, 2, 2 );
  translate( 0, 0, CAVE2_screenPos.z );
  
  drawCAVE2();
  //drawSpeakers();
  
  //drawCoordinateSystem( 0, 0 );
  popMatrix();
    
  // Border
  noStroke();
  float borderWidth = 20;
  float borderDistFromEdge = 30;
  String systemText = "PROCESSING UNIT STATUS";
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
  
  textFont( st_font, 32 );
  fill(10);
  rect( borderDistFromEdge + textOffset.x, height - borderDistFromEdge - borderWidth/2, textWidth(systemText) + borderWidth * 2, borderWidth ); // Bottom
  fill(255);
  text(systemText, borderDistFromEdge + borderWidth + textOffset.x, height - borderDistFromEdge - borderWidth/2  + textOffset.y);
  textFont( st_font, 16 );

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
  
  // Right dsiplay nodes
  for( int i = 19; i < 37; i++ )
  {
    pushMatrix();
    translate( width - 80 - borderDistFromEdge - 500, 130 - borderDistFromEdge + 80 * (i-19) );
    nodes[i].drawRight();
    popMatrix();
  }
  
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
