class Trackable
{
  int ID;
  int secondID = -1;
  String name;
  float clickableRadius = 0.1; // meters
  PVector position;
  PVector rotation;
  
  float timeSinceLastUpdate;
  float timeSinceLastMocapUpdate;
  float updateTimer = 3;
  float mocapUpdateTimer = 3;
  int drawPriority = 0;
  
  boolean button1; // Triangle
  boolean button2; // Circle
  boolean button3; // Cross
  boolean button4; // Square
  boolean button5; // L1
  boolean button6; // L3
  boolean button7; // L2
  
  boolean specialButton1; // Select
  boolean specialButton2; // Start
  boolean specialButton3; // PS
  
  boolean buttonUp;
  boolean buttonRight;
  boolean buttonDown;
  boolean buttonLeft;
  
  PVector analogStick1;
  PVector analogStick2;
  PVector analogStick3;
  
  color currentStatusColor;
  color currentMocapColor;
  color currentUpdateColor;
  
  // Status
  final int Normal = 0;
  final int Partial = 1; // No tracking or no controller data
  final int Offline = 2; // No tracking and no controller data
  int trackableStatus = -1;
  color colorNormal = color(10, 250, 50);
  color colorPartial = color( 250, 150, 50 );
  color colorOffline = color( 250, 50, 50 );
  color colorDisabled = color( 105, 105, 105 );
  
  // Tracking error state
  final int None = 0;
  final int Minor = 1;
  final int Moderate = 2;
  final int Major = 3;
  int trackingError = -1;
  
  int minorDrops = 0;
  int moderateDrops = 0;
  int majorDrops = 0;
  
  ArrayList errorLog;
  
  // Tracking error colors
  color colorNone = color(10, 250, 50); // Green
  color colorMinor = color(10, 250, 50, 128); // Faded Green
  color colorModerate = color(250, 250, 50, 128); // Yellow
  color colorMajor = color(250, 50, 50, 128); // Red
  
  boolean selected = false;
  
  class Error{
    float timestamp;
    PVector position, orientation;
    int severity;
    boolean selected = false;
    
    Error( float time, PVector pos, PVector ori, int severity )
    {
      timestamp = time;
      position = new PVector( pos.x, pos.y, pos.z );
      orientation = ori;
      this.severity = severity;
    }
    
    void draw()
    {
      switch( severity )
      {
        case(Minor): tint( colorMinor ); fill( colorMinor ); break;
        case(Moderate): tint( colorModerate ); fill( colorModerate ); break;
        case(Major): tint( colorMajor ); fill( colorMajor ); break;
      }
      
      float displayX = position.x * CAVE2_Scale;
      float displayY = position.z * CAVE2_Scale;
      float displayZ = position.y * CAVE2_Scale;
      
      /*
      pushMatrix();
      imageMode(CENTER);
      translate( displayX, displayY );
    
      noStroke();
      image( heatmapPoint, 0, 0 );
        
      popMatrix();
      */
      
      pushMatrix();
      imageMode(CENTER);
      translate( displayX, displayY, displayZ );
      rotateX( -CAVE2_3Drotation.x );
      rotateY( -CAVE2_3Drotation.y );
    
      noStroke();
      sphere( 5 );
      //if( selected )
      //  ellipse( 0, 0, 15, 15 );
        
      popMatrix();
      
      imageMode(CORNER);
      
      /*
      fill( 0,250,250 );
      switch( severity )
      {
        case(Minor):
          text( "Minor Error Time: " + timestamp, displayX + 10, displayZ - 50 );
          break;
        case(Moderate):
          text( "Moderate Error Time: " + timestamp, displayX + 10, displayZ - 50 );
          break;
        case(Major):
          text( "Major Error Time: " + timestamp, displayX + 10, displayZ - 50 );
          break;
      }
 
      text( "Pos: " + position, displayX + 10, displayZ - 40 );
      */
    }
    
    void onInput( float xPos, float yPos )
    {
      float distance = abs(dist( position.x, position.y, xPos, yPos ));
      //println(name + " dist " + distance );
      if( distance <= 15 )
        selected = true;
      else
        selected = false;
    }
    
  }
  
  Trackable(int ID, String name)
  {
    this.ID = ID;
    this.name = name;
    position = new PVector( random( -3, -1.8 ), 0, 3.8);
    rotation = new PVector();
    
    analogStick1 = new PVector();
    analogStick2 = new PVector();
    analogStick3 = new PVector();
    
    errorLog = new ArrayList();
  }// ctor
  
  void updatePosition( float x, float y, float z, float rx, float ry, float rz, float rw )
  {
    position.x = x;
    position.y = y;
    position.z = z;
    
    rotation.x = degrees(atan2( 2*(rx*ry + rz*rw) , (1-2*(ry*ry + rz*rz) ) ));
    rotation.y = degrees(asin( 2*(rx*rz - rw*ry) ));
    rotation.z = degrees(atan2( 2*(rx*rw + ry*rz) , (1-2*(rz*rz + rw*rw) ) ));
    
    mocapUpdateTimer = programTimer;
  }// setPosition
  
  void loadErrorsFromFile()
  {
    String logPath = "logs/trackingDropLog-2013-5-9-17-39-0-trackable2.txt";
    String[] lines = loadStrings(logPath);
    for(int index = 0; index < lines.length; index++) {
      String[] pieces = split(lines[index], '\t');
      errorLog.add( new Error( int(pieces[0]), new PVector(float(pieces[1]),float(pieces[2]),float(pieces[3])), new PVector(float(pieces[4]),float(pieces[5]),float(pieces[6])), int(pieces[7]) ) );
    }
  }
  
  void outputErrorsToFile()
  {
    String[] lines = new String[errorLog.size()];
    for( int i = 0; i < errorLog.size(); i++ )
    {
      Error e = (Error)errorLog.get(i);
      lines[i] = e.timestamp + "\t" + e.position.x + "\t" + e.position.y + "\t" + e.position.z + "\t" + e.orientation.x + "\t" + e.orientation.y + "\t" + e.orientation.z + "\t" + e.severity;
    }
    
    // Only create file if there is data (ignores initial drop data)
    if( logErrors && errorLog.size() > 3 )
      saveStrings("logs/trackingDropLog-"+year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+"-trackable"+ID+".tsv", lines);
  }
  
  // PS3 Sixaxis mapping:
  // 1 = Triangle
  // 2 = Circle
  // 4 = Cross
  // 8 = Select
  // 16 = Start
  // 32 = PS3
  // 64 = Square
  // 128 = L1
  // 256 = L3
  // 1024 = DPad Up
  // 2048 = DPad Down
  // 4096 = DPad Left
  // 8192 = DPad Right
  void updateButton( int buttonFlag, boolean state )
  {
    if( (buttonFlag & 0) == 0 )
       clearAllButtons();
    if( (buttonFlag & 1) == 1 )
       button1 = state;
    if( (buttonFlag & 2) == 2 )
       button2 = state;
    if( (buttonFlag & 4) == 4 )
       button3 = state;
    if( (buttonFlag & 8) == 8 )
       specialButton1 = state;
    if( (buttonFlag & 16) == 16 )
       specialButton2 = state;
    if( (buttonFlag & 32) ==32 )
       specialButton3 = state;
    if( (buttonFlag & 64) == 64 )
       button4 = state;
    if( (buttonFlag & 128) == 128 )
       button5 = state;
    if( (buttonFlag & 256) == 256 )
       button6 = state;
    if( (buttonFlag & 512) == 512 )
       button7 = state;
  
    if( (buttonFlag & 1024) == 1024 )
       buttonUp = state;
    if( (buttonFlag & 2048) == 2048 )
       buttonDown = state;
    if( (buttonFlag & 4096) == 4096 )
       buttonLeft = state;
    if( (buttonFlag & 8192) == 8192 )
       buttonRight = state;
       
    updateTimer = programTimer;
  }// updateButton
  
  void clearAllButtons()
  {
      button1 = false;
      button2 = false;
      button3 = false;
      specialButton1 = false;
      specialButton2 = false;
      specialButton3 = false;
      button4 = false;
      button5 = false;
      button6 = false;
      button7 = false;
      
      buttonUp = false;
      buttonDown = false;
      buttonLeft = false;
      buttonRight = false;
  }// clearAllButtons
  
  void updateAnalog( int analogID, float value1, float value2 )
  {
    updateTimer = programTimer;
    if( analogID == 1 )
    {
      analogStick1 = new PVector( value1, value2 );
    }
    else if( analogID == 2 )
    {
      analogStick2 = new PVector( value1, value2 );
    }
    else if( analogID == 3 )
    {
      analogStick3 = new PVector( value1, value2 );
    }
  }// updateAnalog
  
  // Update status without displaying
  void update()
  {
    timeSinceLastUpdate = programTimer - updateTimer;
    timeSinceLastMocapUpdate = programTimer - mocapUpdateTimer;
    
    if( timeSinceLastMocapUpdate >= 5 && timeSinceLastUpdate < 5 )
    {
      trackableStatus = Partial;
      currentStatusColor = colorPartial;
    }
    else if( timeSinceLastMocapUpdate < 5 && timeSinceLastUpdate >= 5 )
    {
      trackableStatus = Partial;
      currentStatusColor = colorPartial;
    }
    else if( timeSinceLastMocapUpdate >= 5 && timeSinceLastUpdate >= 5 )
    {
      trackableStatus = Offline;
      currentStatusColor = colorOffline;
    }
    else
    {
      trackableStatus = Normal;
      currentStatusColor = colorNormal;
    }
  }
  void draw()
  {    
    timeSinceLastUpdate = programTimer - updateTimer;
    timeSinceLastMocapUpdate = programTimer - mocapUpdateTimer;
    
    if( timeSinceLastMocapUpdate >= 5 && timeSinceLastUpdate < 5 )
    {
      trackableStatus = Partial;
      currentStatusColor = colorPartial;
    }
    else if( timeSinceLastMocapUpdate < 5 && timeSinceLastUpdate >= 5 )
    {
      trackableStatus = Partial;
      currentStatusColor = colorPartial;
      
      // Second ID not set, trackable has no controller component
      // Set normal if mocap data is received
      if( secondID == -1 )
      {
        trackableStatus = Normal;
        currentStatusColor = colorNormal;
      }
    }
    else if( timeSinceLastMocapUpdate >= 5 && timeSinceLastUpdate >= 5 )
    {
      trackableStatus = Offline;
      currentStatusColor = colorOffline;
    }
    else
    {
      trackableStatus = Normal;
      currentStatusColor = colorNormal;
    }
  
    float displayX = position.x * CAVE2_Scale;
    float displayY = position.z * CAVE2_Scale;
    float displayZ = position.y * CAVE2_Scale;
    
    drawPriority = 0;
    if( timeSinceLastMocapUpdate < 1 )
    {
      currentMocapColor = color(10, 250, 50);
      trackingError = None;
    }
    else if( timeSinceLastMocapUpdate < 2 )
    {
      currentMocapColor = color(10, 250, 50, 128);
      
      if( trackingError != Minor )
      {
        if( logErrors )
          errorLog.add( new Error( programTimer, position, rotation, Minor ) );
        minorDrops++;
      }
      
      trackingError = Minor;
    }
    else if( timeSinceLastMocapUpdate < 5 )
    {
      currentMocapColor = color(250, 250, 50, 128);
      
      if( trackingError != Moderate )
      {
        if( logErrors )
          errorLog.add( new Error( programTimer, position, rotation, Moderate ) );
        minorDrops--;
        moderateDrops++;
      }
      
      trackingError = Moderate;
      
    }
    else
    {
      currentMocapColor = color(250, 50, 50, 128);
      
      if( trackingError != Major )
      {
        if( logErrors )
          errorLog.add( new Error( programTimer, position, rotation, Major ) );
        moderateDrops--;
        majorDrops++;
      }
      trackingError = Major;
      
    }
    
    if( timeSinceLastUpdate < 1 )
      currentUpdateColor = color(10, 250, 50);
    else if( timeSinceLastUpdate < 2 )
      currentUpdateColor = color(10, 250, 50, 128);
    else if( timeSinceLastUpdate < 5 )
      currentUpdateColor = color(250, 250, 50, 128);
    else
    {
      currentUpdateColor = color(250, 50, 50, 128);
    }
    
    pushMatrix();
    translate( displayX, displayY, displayZ );
    //rotateX( -CAVE2_3Drotation.x );
    //rotateY( CAVE2_3Drotation.y );
    
    fill(currentMocapColor);
    
    noStroke();
    //ellipse( 0, 0, 10, 10 );
    sphere( 5 );
    
    // Trackables with a second ID only (i.e. has controller data)
    if( secondID != -1 && programTimer % 2 < 1 )
    {
      stroke(currentUpdateColor);
      noFill();
      ellipse( 0, 0, 18, 18 );
    }
    
    float distanceFromCenter = PVector.dist( new PVector(0,0,0), new PVector(position.x,0,position.z) );
    float angleFromCenter = atan2( 0 - position.y, 0 - position.x );
    //text( name, 0 + 10, 0 - 5 );
    //text( name, displayX + 10, displayZ - 24 );
    //text( "x: " + position.x + "\ny: " + position.y + "\nz: " + position.z, displayX + 10, displayZ - 10 );
    //text( "roll: " + rotation.x + "\npitch: " + rotation.y + "\nyaw: " + rotation.z, displayX + 100, displayZ - 10 );
    //text( "update delay: " + timeSincelastUpdate, displayX + 10, displayZ - 10 );
    //text( "origin 2D dist: " + distanceFromCenter, displayX + 10, displayZ - 10 );
    //text( "origin 2D angle: " + degrees(angleFromCenter), displayX + 10, displayZ + 4 );
    popMatrix();
    
    pushMatrix();
    translate( displayX, displayY, displayZ );
    rotateZ( -CAVE2_3Drotation.y );
    rotateX( -CAVE2_3Drotation.x ); 
    
    translate( 0, 0, CAVE2_screenPos.z + 500 );
    
    text( name, 0 + 10, 0 - 5 );
    popMatrix();
    
    // Show error log
    if( selected )
      for( int i = 0; i < errorLog.size(); i++ )
      {
        Error e = (Error)errorLog.get(i);
        
        e.draw();
      }
      
    
  }// draw
  
  boolean isPressed( float xPos, float yPos )
  {
    if( selected )
    {
      for( int i = 0; i < errorLog.size(); i++ )
      {
        Error e = (Error)errorLog.get(i);
        
        e.onInput(xPos,yPos);
      }
    }
    
    float distance = abs(dist( position.x, position.y, xPos, yPos ));
    //println(name + " dist " + distance );
    //println("Pos: "+position + " InputPos " + xPos + " " + yPos );
    if( distance <= clickableRadius )
      return true;
    else
      return false;
  }// isPressed
  
}// class
