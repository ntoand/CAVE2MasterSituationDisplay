/**
 * ---------------------------------------------
 * CAVE2MasterSituationDisplay.pde
 * Description: CAVE2 Master Situation Display (MSD)
 *
 * Class: 
 * System: Processing 2.2, SUSE 12.1, Windows 7 x64
 * Author: Arthur Nishimoto
 * Copyright (C) 2012-2014
 * Electronic Visualization Laboratory, University of Illinois at Chicago
 * Version: 0.5 (alpha)
 *
 * Version Notes:
 * 11/6/12      - Initial version
 * 12/7/12      - Audio support, 3D view
 * 12/9/13      - Updated for Processing 2.1
 * 5/9/14       - Cluster display draw based on CAVE2 meaasurements instead if being hardcoded
 * ---------------------------------------------
 */

import oscP5.*;
import netP5.*;
import processing.net.*;
import omicronAPI.*;
import omicronAPI.Event;
import java.util.*; // Hashtable

OmicronAPI omicronManager;

EventListener eventListener;

PApplet applet;

PFont st_font;
PFont space_font;

PImage circleImg;

float programTimer;
float deltaTime;
float lastFrameTime;
float startTime;

int startTimer;
int countdown = 420000;
boolean enableCountdown = false;

float targetWidth;
float targetHeight;

boolean demoMode = true; // No active contollers and trackables enables demo mode (rotates CAVE2 image)
boolean scaleScreen = true;

boolean wandDebug = false;

boolean showFullscreen = true;
int windowWidth = 1600;
int windowHeight = 1200;

float lastInteractionTime;
float timeSinceLastInteractionEvent;

String systemText = "MASTER SITUATION DISPLAY";
float borderWidth = 20;
float borderDistFromEdge = 30;

final int TRACKING = 0;
final int CLUSTER = 1;
final int AUDIO = 2;
int state = TRACKING;

// CAVE2 model -----------------------------------
float CAVE2_Scale = 65;

float CAVE2_verticalScale = 0.33;

// In meters:
float CAVE2_diameter = 3.95 * 2;       // EVL CAVE2: 3.628 * 2  CAVE2 AU: 3.95 * 2
float CAVE2_innerDiameter = 3.696 * 2;  // EVL CAVE2: 3.429 * 2  CAVE2 AU: 3.696 * 2
float CAVE2_screenDiameter = 3.596 * 2; // EVL CAVE2: 3.429 * 2  CAVE2 AU: 3.596 * 2
float CAVE2_legBaseWidth = 0.254;
float CAVE2_legHeight = 2.159;
float CAVE2_lowerRingHeight = 0.3048;
float CAVE2_displayWidth = 1.02;
float CAVE2_displayHeight = 0.579;
float CAVE2_displayDepth = 0.08;
float CAVE2_displayToFloor = 0.317;

int nDisplayColumns = 20;   // EVL CAVE2: 18   CAVE2 AU: 20
int nColumns = 22;          // EVL CAVE2: 20   CAVE2 AU: 22
int columnOffset = 10;      // EVL CAVE2: 9    CAVE2 AU: 10
int nodeOffset = 2;        // EVL CAVE2: 4    CAVE2 AU: 2
int nodesPerColumn = 1;    // EVL CAVE2: 2    CAVE2 AU: 1
int nDisplaysPerColumn = 4;

int nNodes = 21; // Including master  // EVL CAVE2: 37    CAVE2 AUS: 21
int nNodesLeft = 11; // Nodes on left half of CAVE2 - EVL CAVE2: 19  CAVE2 AU: 11
int verticalNodeSpacing = 121; // EVL CAVE2: 70  CAVE2 AU: 121
int rightNodeOffset = 0; // EVL CAVE2: 70 (0 for no clock), CAVE2 AU: 90?

float speakerHeight = CAVE2_legHeight * 1.3;
float speakerWidth = 0.2;

float CAVE2_rotation = 15; //degrees

PVector CAVE2_screenPos;
PVector CAVE2_3Drotation = new PVector();

float CAVE2_worldZPos = -300;

// Stores the position and angle of display columns
PVector[] displayColumnTransform = new PVector[nColumns];

// How the display columns are represented in the CAVE2 model
final int COLUMN = 0;
final int NODE = 1;
final int DISPLAY = 2;
int CAVE2_displayMode = COLUMN;

// Tracker ---------------------------------------
boolean connectToTracker = false;
boolean logErrors = false;
String trackerIP = "";
int msgport = 28000;
int dataport = 7738;

boolean connectedToTracker = false;
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

float trackerReconnectTimer = 10;
float trackerReconnectDelay = 10;
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
String clusterData = "";
String clusterPing1 = "";
String clusterPing2 = "";
//String website = "S:/EVL/CAVE2/cluster2.txt";
boolean connectToClusterData = false;
float clusterUpdateInterval = 0.5; // seconds

NodeDisplay[] nodes = new NodeDisplay[21];
float[] columnPulse = new float[nColumns+1];
float pulseDecay = 0.1;
boolean connectedToClusterData = false;
float clusterUpdateTimer;

boolean[] nodePing = new boolean[21];
boolean[] nodeCavewavePing = new boolean[21];

Hashtable appList = new Hashtable();

// Override of PApplet init() which is called before setup()
public void init() {
  super.init();

  // Creates the OmicronAPI object. This is placed in init() since we want to use fullscreen
  omicronManager = new OmicronAPI(this);
  
  readConfigFile("config.cfg");
  
  // Removes the title bar for full screen mode (present mode will not work on Cyber-commons wall)
  omicronManager.setFullscreen(showFullscreen);
}// init

void exit()
{
  super.exit();

  // Output tracker drop data to text files
  if ( headTrackable!= null )
    headTrackable.outputErrorsToFile();
  if ( wandTrackable1!= null )
    wandTrackable1.outputErrorsToFile();
  if ( wandTrackable2!= null )
    wandTrackable2.outputErrorsToFile();
  if ( wandTrackable3!= null )
    wandTrackable1.outputErrorsToFile();
  if ( wandTrackable4!= null )
    wandTrackable2.outputErrorsToFile();
}// exit

// Program initializations
void setup() {
  readConfigFile("config.cfg");
  //size( 540, 960, P3D ); // Droid Razr
  if( showFullscreen )
    size( displayWidth, displayHeight, P3D );
  else
    size( windowWidth, windowHeight, P3D );
  println(width + " " + height);
  //size( 1920, 1080, P3D );
  //size( 1600, 1200, P3D );
  
  //readConfigFile("config.cfg");
  
  targetWidth = 2560;
  targetHeight = 1600;
  
  applet = this;
  oscP5 = new OscP5(this, recvPort);
  CAVE2_screenPos = new PVector( targetWidth * 0.5, targetHeight * CAVE2_verticalScale, -100 );

  startTime = millis() / 1000.0;

  // Make the connection to the tracker machine
  if ( connectToTracker )
  {
    println("Connecting to tracker '"+trackerIP+"' on port " + msgport );
    connectedToTracker = omicronManager.connectToTracker(dataport, msgport, trackerIP);
    
    if( connectedToTracker )
      println("Connected to tracker");
  }
  // Create a listener to get events
  eventListener = new EventListener();

  omicronManager.setEventListener( eventListener );

  // Screen scaling
  omicronManager.calculateScreenTransformation(targetWidth, targetHeight);
  omicronManager.enableScreenScale(scaleScreen);
  
  st_font = loadFont("TMP-Monitors-48.vlw");
  space_font = loadFont("SpaceAge-48.vlw");
  
  circleImg = loadImage("circle.png");
   
  textFont( st_font, 16 );

  for ( int i = 0; i < 21; i++)
  {
    columnPulse[i] = random(0, 0) / 100.0;
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
  wandTrackable1.secondID = 1; // Controller 0 is mapped to Wand 1

  wandTrackable2 = new Trackable( 2, "Wand 2 Type B (Robin/Spock)" );
  wandTrackable2.secondID = 2; // Controller 1 is mapped to Wand 2
  //wandTrackable2.loadErrorsFromFile();

  wandTrackable3 = new Trackable( 3, "Wand 3 Type A (Batman/Kirk)" );
  wandTrackable3.secondID = 3; // Controller 1 is mapped to Wand 2

  wandTrackable4 = new Trackable( 4, "Wand 4 Type B (Robin/Spock)" );
  wandTrackable4.secondID = 4; // Controller 1 is mapped to Wand 2

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
  headButton.setText("Head 1", st_font, 16);
  headButton.fillColor = color( 10, 200, 125, 128 );

  wandButton1 = new Button( 16 * 1, 16 * 6 + 35, 80, 30 );
  wandButton1.setText("Wand 1", st_font, 16);
  wandButton1.fillColor = color( 10, 200, 125, 128 );
  wandButton1.selected = true;

  wandButton2 = new Button( 16 * 1, 16 * 6 + 35 * 2, 80, 30 );
  wandButton2.setText("Wand 2", st_font, 16);
  wandButton2.fillColor = color( 10, 200, 125, 128 );

  wandButton3 = new Button( 16 * 1, 16 * 6 + 35 * 3, 80, 30 );
  wandButton3.setText("Wand 3", st_font, 16);
  wandButton3.fillColor = color( 10, 200, 125, 128 );

  wandButton4 = new Button( 16 * 1, 16 * 6 + 35 * 4, 80, 30 );
  wandButton4.setText("Wand 4", st_font, 16);
  wandButton4.fillColor = color( 10, 200, 125, 128 );

  //ortho(0, width, 0, height, -1000, 1000);
  ortho();
  
  for ( int i = 0; i < 21; i++)
  {
    nodes[i] = new NodeDisplay(i);
  }
  
  background(0);
}// setup

float scaleScreenX, scaleScreenY;

void draw() {
  if ( scaleScreen )
  {
    omicronManager.pushScreenScale();
  }

  programTimer = millis() / 1000.0;
  deltaTime = programTimer - lastFrameTime;
  timeSinceLastInteractionEvent = programTimer - lastInteractionTime;

  // Sets the background color
  //background(0);
  if (state == TRACKING && timeSinceLastInteractionEvent > 30)
  {
    state = CLUSTER;
    lastInteractionTime = programTimer;
  }  
  else if (state == CLUSTER && timeSinceLastInteractionEvent > 60)
  {
    state = TRACKING;
    lastInteractionTime = programTimer;
  }  

  switch( state )
  {
    case(TRACKING):
      drawTrackerStatus();
      if( !connectToTracker )
      {
        fill(250,250,0);
        text("DEMO MODE - NOT CONNECTED TO TRACKER", 216, 16);
      }
      else if( connectToTracker && !connectedToTracker )
      {
        fill(0);
        rect(0,0,width,borderWidth);
        
        fill(250,250,0);
        text("FAILED TO CONNECT TO TRACKER - ATTEMPTING RECONNECT IN " + (int)trackerReconnectTimer, 216, 16);
      }
      break;
    case(CLUSTER):
      if( connectToClusterData )
      {
        getData();
        if( clusterUpdateTimer >= clusterUpdateInterval )
        {
          clusterUpdateTimer = 0;
        }
        else
        {
          clusterUpdateTimer += deltaTime;
        }
      }
      else
      {
        fill(250,250,0);
        text("DEMO MODE - NOT CONNECTED TO CLUSTER", 216, 16);
      }
      
      if( connectToClusterData && !connectedToClusterData )
      {
        fill(0);
        rect(0,0,width,borderWidth);
        
        fill(250,250,0);
        text("NO DATA RECEIVED - NOT CONNECTED TO CLUSTER - ATTEMPTING RECONNECT IN " + (int)clusterReconnectTimer, 216, 16);
      }
      drawClusterStatus();
      break;
    case(AUDIO):
      drawAudioStatus();
      break;
  }
  
  textFont( st_font, 64 );
  textAlign(RIGHT);
  String minuteStr = minute()+"";
  String secondStr = second()+"";
  if( minute() < 10 )
    minuteStr = "0"+minuteStr;
  if( second() < 10 )
    secondStr = "0"+secondStr;
  fill(255);
  if( state != CLUSTER )
    text(hour()+":"+minuteStr+":"+secondStr, targetWidth - 50, 105);
  //textAlign(LEFT);
  //textFont( st_font, 16 );
  
  if( enableCountdown )
  {
    int curTimeSec = millis() / 1000;
    int minRemain = (countdown/1000 - millis()/1000 + startTimer/1000) / 60;
    int secRemain = (countdown/1000 - millis()/1000 + startTimer/1000) % 60;
    
    if( minRemain <= 0 && secRemain > 0 )
      fill(20,200,20);
    else if( minRemain <= 0 && secRemain <= 0 )
      fill(200,20,20);

    
    if( minRemain < 0 )
    {
      minRemain *= -1;
    } 
    minuteStr = minRemain+"";
    if( minRemain < 10 )
      minuteStr = "0"+minuteStr;
    
    if( secRemain < 0 )
    {
      secRemain *= -1;
      minuteStr = "-"+minuteStr;
    } 
    
    secondStr = secRemain+"";
    
    if( secRemain < 10 )
      secondStr = "0"+secondStr;
    
    
    text( minuteStr +":"+secondStr, targetWidth - 50, 2 * 105);
    textFont( st_font, 16 );
    textAlign(LEFT);
  }
  
  // Border
  noStroke();
  PVector textOffset = new PVector( targetWidth * 0.9, borderWidth );

  fill(50);
  rect( borderDistFromEdge + borderWidth/2, borderDistFromEdge, targetWidth - borderDistFromEdge * 2 - borderWidth/2, borderWidth ); //Top
  ellipse( borderDistFromEdge + borderWidth/2, borderDistFromEdge + borderWidth/2, borderWidth, borderWidth ); // Top-Left
  ellipse( targetWidth - borderDistFromEdge, borderDistFromEdge + borderWidth/2, borderWidth, borderWidth ); // Top-Right
  rect( borderDistFromEdge, borderDistFromEdge + borderWidth/2, borderWidth, targetHeight - borderDistFromEdge * 2 - borderWidth/2 ); //Left
  rect( targetWidth - borderDistFromEdge - borderWidth/2, borderDistFromEdge + borderWidth/2, borderWidth, targetHeight - borderDistFromEdge * 2 - borderWidth/2 ); //Right
  ellipse( borderDistFromEdge + borderWidth/2, targetHeight - borderDistFromEdge, borderWidth, borderWidth ); // Bottom-Left
  ellipse( targetWidth - borderDistFromEdge, targetHeight - borderDistFromEdge, borderWidth, borderWidth ); // Bottom-Right
  rect( borderDistFromEdge + borderWidth/2, targetHeight - borderDistFromEdge - borderWidth/2, targetWidth - borderDistFromEdge * 2 - borderWidth/2, borderWidth ); // Bottom
  
  textAlign(RIGHT);
  textFont( st_font, 32 );
  fill(10);
  rect( borderDistFromEdge + textOffset.x, targetHeight - borderDistFromEdge - borderWidth/2, -(textWidth(systemText) + borderWidth * 2), borderWidth ); // Bottom
  fill(255);
  text(systemText, textOffset.x + borderWidth/2, targetHeight - borderDistFromEdge - borderWidth/2  + textOffset.y);
  textAlign(LEFT);
  textFont( st_font, 16 );
  
  // For event and fullscreen processing, this must be called in draw()
  omicronManager.process();
  lastFrameTime = programTimer;

  if ( scaleScreen )
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

  if ( headButton.isPressed( mouseX, mouseY ) )
  {
    wandButton1.selected = false;
    wandButton2.selected = false;
  }

  if ( wandButton1.isPressed( mouseX, mouseY ) )
  {
    headButton.selected = false;
    wandButton2.selected = false;
  }

  if ( wandButton2.isPressed( mouseX, mouseY ) )
  {
    headButton.selected = false;
    wandButton1.selected = false;
  }

  if ( wandButton3.isPressed( mouseX, mouseY ) )
  {
    headButton.selected = false;
    wandButton1.selected = false;
    wandButton2.selected = false;
    wandButton4.selected = false;
  }

  if ( wandButton4.isPressed( mouseX, mouseY ) )
  {
    headButton.selected = false;
    wandButton1.selected = false;
    wandButton2.selected = false;
    wandButton3.selected = false;
  }

  if ( headTrackable.isPressed( meters.x, meters.y ) )
  {
    headButton.selected = true;
    wandButton1.selected = false;
    wandButton2.selected = false;
  }

  if ( wandTrackable1.isPressed( meters.x, meters.y ) )
  {
    headButton.selected = false;
    wandButton1.selected = true;
    wandButton2.selected = false;
  }

  if ( wandTrackable2.isPressed( meters.x, meters.y ) )
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

  fill(0, 0, 200, 128); // Z
  stroke(0, 0, 200, 128);
  line( 0, 0, 0, 30 ); 
  text("z", 5, 32 );

  fill(200, 0, 0, 128); // X
  stroke(200, 0, 0, 128);
  line( 30, 0, 0, 0 );
  text("x", 35, 0 );

  fill(0, 100, 0, 128); // y
  noStroke();
  ellipse( 0, 0, 5, 5);
  text("y", 5, -5 );
  noFill();
  stroke(0, 100, 0, 128);
  strokeWeight(1);
  ellipse( 0, 0, 10, 10);

  rotateY( radians(270) );
  line( 30, 0, 0, 0 );

  popMatrix();
}

void keyPressed()
{
  //println(key);
  if ( key == '1' )
  {
    state = TRACKING;
  }
  if ( key == '2' )
  {
    state = CLUSTER;
  }
  if ( key == '3' )
  {
    state = AUDIO;
  }
  
  if ( key == ' ' )
  {
    peakCPU = 0;
    peakGPU = 0;
  }
  
}

