/**
 * ---------------------------------------------
 * TrackerStatus.pde
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

PVector demoPos = new PVector(0,1.2,0);
float trackerPulseDelay = 0.1;
float trackerPulseTimer;

void drawTrackerStatus()
{
  pushMatrix();
  systemText = "TRACKING SYSTEM";
  
  CAVE2_Scale = 64;
  CAVE2_displayMode = DISPLAY;
  
  background(0);

  translate( 50, 60 );
  
  fill(0,250,250);
  text("CAVE2(TM) System Master Situation Display (Version 0.5 - alpha)", 16, 16);
  
  float timeSinceLastTrackerUpdate = programTimer - lastTrackerUpdateTime;
  
  if( connectToTracker )
  {
    if( connectedToTracker )
    {
      text("Connected to '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
      text("Receiving data on dataport: " + dataport, 16, 16 * 3);
    }
    else
    {
      fill(250,10,10);
      text("FAILED to connect to '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
      text("Attempting reconnect in: " + (int)trackerReconnectTimer, 16, 16 * 3);
      trackerReconnectTimer -= deltaTime;
      
      if( trackerReconnectTimer <= 0 )
      {
        //connectedToTracker = omicronManager.connectToTracker(dataport, msgport, trackerIP);
        if( !connectedToTracker )
          trackerReconnectTimer = trackerReconnectDelay;
      }
    }
  }
  else
  {
    text("Not connected to tracker", 16, 16 * 2);
    text("Running in demo mode", 16, 16 * 3);
    
    
    headTrackable.updatePosition( -0.34 , 1.76, 0.91, -0.1, 0.15, 0.8, 1 );
    
    trackerPulseTimer += deltaTime;
    if( trackerPulseTimer > trackerPulseDelay )
    {
      trackerPulseTimer = 0;
      
      demoPos = new PVector( demoPos.x + random(-0.01,0.01), demoPos.y + random(-0.01,0.01), demoPos.z + random(-0.01,0.01) );
      
      wandTrackable1.updatePosition( demoPos.x, demoPos.y, demoPos.z, demoPos.x/5, demoPos.y/5, demoPos.z/5, demoPos.y/5 );
      if( random(0,3) >= 0 )
        wandTrackable1.updateButton( (int)random(0,8193), true );
      else
        wandTrackable1.updateButton( (int)random(0,8193), false );
        
      wandTrackable1.updateAnalog( (int)random(1,4), demoPos.x, demoPos.z );
    }
  }
  
  if( timeSinceLastTrackerUpdate >= 5 )
  {
    fill(250,250,50);
    text("No active controllers or trackables in CAVE2", 16, 16 * 4);
    text("timeSinceLastTrackerUpdate " + timeSinceLastTrackerUpdate, 16, 16 * 5);
    
    CAVE2_3Drotation.x = constrain( CAVE2_3Drotation.x + deltaTime * 0.1, 0, radians(45) );
    CAVE2_3Drotation.y += deltaTime * 0.1;
  }
  else
  {
    
    //demoMode = false;
  }
  
  popMatrix();
  
  CAVE2_3Drotation.x = constrain( CAVE2_3Drotation.x + deltaTime * 0.1, 0, radians(45) );
  CAVE2_3Drotation.y += deltaTime * 0.1;
  if( CAVE2_3Drotation.y > 2 * PI )
    CAVE2_3Drotation.y = 0;
  
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
      text("CAVE2(TM) System Locator (Version 0.5 - alpha)", 16, 16);
      text("Connected to '"+ trackerIP + "' on msgport: " + msgport, 16, 16 * 2);
      text("Receiving data on dataport: " + dataport, 16, 16 * 3);
      //reconnectTrackerTimer = programTimer + reconnectTrackerDelay;
      
      fill(250,250,50);
      text("No active controllers or trackables in CAVE2", 16, 16 * 4);
    }
    
    
  }*/
  
  
  // Draw CAVE2 ------------------------------------------------------------------
  pushMatrix();
  //translate( CAVE2_screenPos.x * 1.5 , CAVE2_screenPos.y, CAVE2_worldZPos);
  translate( CAVE2_screenPos.x, CAVE2_screenPos.y, CAVE2_worldZPos);
  rotateX( CAVE2_3Drotation.x ); 
  rotateZ( CAVE2_3Drotation.y );
  scale( 2, 2, 2 );
  translate( 0, 0, CAVE2_screenPos.z );
  
  drawCAVE2();
  
  drawCameras();
  
  // CAVE2 diameter (inner-screen, outer ring) - upper ring
  drawSpeakers();
  drawSounds();
  
  // -----------------------------------------------------------------------------
  wandTrackable4.update();
  wandTrackable3.update();
  wandTrackable2.draw();
  wandTrackable1.draw();
  headTrackable.draw();
  
  drawCoordinateSystem( 0, 0 );
  popMatrix();
  
  headButton.fillColor = headTrackable.currentStatusColor;
  wandButton1.fillColor = wandTrackable1.currentStatusColor;
  wandButton2.fillColor = wandTrackable2.currentStatusColor;
  wandButton3.fillColor = wandTrackable3.colorDisabled;
  wandButton4.fillColor = wandTrackable4.colorDisabled;
  
  /*
  headButton.draw();
  wandButton1.draw();
  wandButton2.draw();
  wandButton3.draw();
  wandButton4.draw();
  */
  
  PVector trackableWindow = new PVector( targetWidth * 0.02, targetHeight - 400 );
  float displayWindowSpacing = 800;
  displayTrackableWindow( headTrackable, trackableWindow.x, trackableWindow.y );
  displayControllerWindow( wandTrackable1, trackableWindow.x + displayWindowSpacing, trackableWindow.y );
  displayControllerWindow( wandTrackable2, trackableWindow.x + displayWindowSpacing * 2, trackableWindow.y );
  
  /*
  if( headButton.selected )
  {
    headTrackable.selected = true;
    wandTrackable1.selected = false;
    wandTrackable2.selected = false;
    wandTrackable3.selected = false;
    wandTrackable4.selected = false;
    
    displayTrackableWindow( headTrackable, trackableWindow.x, trackableWindow.y );
    wandButton1.selected = false;
    wandButton2.selected = false;
    wandButton3.selected = false;
    wandButton4.selected = false;
  }
  else if( wandButton1.selected )
  {
    displayControllerWindow( wandTrackable1, trackableWindow.x, trackableWindow.y );
    headButton.selected = false;
    wandButton2.selected = false;
    wandButton3.selected = false;
    wandButton4.selected = false;
    
    headTrackable.selected = false;
    wandTrackable1.selected = true;
    wandTrackable2.selected = false;
    wandTrackable3.selected = false;
    wandTrackable4.selected = false;
  }
  else if( wandButton2.selected )
  {
    displayControllerWindow( wandTrackable2, trackableWindow.x, trackableWindow.y );
    headButton.selected = false;
    wandButton1.selected = false;
    wandButton3.selected = false;
    wandButton4.selected = false;
    
    headTrackable.selected = false;
    wandTrackable1.selected = false;
    wandTrackable2.selected = true;
    wandTrackable3.selected = false;
    wandTrackable4.selected = false;
  }
  else if( wandButton3.selected )
  {
    displayControllerWindow( wandTrackable3, trackableWindow.x, trackableWindow.y );
    headButton.selected = false;
    wandButton1.selected = false;
    wandButton2.selected = false;
    wandButton3.selected = true;
    wandButton4.selected = false;
    
    headTrackable.selected = false;
    wandTrackable1.selected = false;
    wandTrackable2.selected = false;
    wandTrackable3.selected = true;
    wandTrackable4.selected = false;
  }
  else if( wandButton4.selected )
  {
    displayControllerWindow( wandTrackable4, trackableWindow.x, trackableWindow.y );
    headButton.selected = false;
    wandButton1.selected = false;
    wandButton2.selected = false;
    wandButton3.selected = false;
    wandButton4.selected = true;
    
    headTrackable.selected = false;
    wandTrackable1.selected = false;
    wandTrackable2.selected = false;
    wandTrackable3.selected = false;
    wandTrackable4.selected = true;
  }
  */
}
