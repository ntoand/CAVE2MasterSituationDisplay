class EventListener implements OmicronListener{
 
  // This is called on every Omicron event
  public void onEvent( Event e ){
    lastTrackerUpdateTime = programTimer;
    
    if( e.getServiceType() == OmicronAPI.ServiceType.Mocap )
      onMocapEvent(e);
    else if( e.getServiceType() == OmicronAPI.ServiceType.Speech )
      onSpeechEvent(e);
    else if( e.getServiceType() == OmicronAPI.ServiceType.Wand )
      onWandEvent(e);
    else
      println("Unknown service type: " + e.getServiceType() );
    
  }// OnEvent
  
  void onMocapEvent(Event e)
  {
    pushMatrix();
    translate( width/2, height/2 );
   
    int objectID = e.getSourceID();

    // Raw position in meters
    float xPos = e.getXPos();
    float yPos = e.getYPos();
    float zPos = e.getZPos();
    
    float xRot = e.orientation[0];
    float yRot = e.orientation[1];
    float zRot = e.orientation[2];
    float wRot = e.orientation[3];
          
    popMatrix();
    
  }// onMocapEvent
  
  void onSpeechEvent(Event e)
  {
      String speechText = e.getStringData(0);
      float speechConfidence = e.getFloatData(2);
      float speechAngle = e.getFloatData(3);
      float angleConfidence = e.getFloatData(4);
      
      println("Kinect speech event: " +speechText + " at angle " + speechAngle + " with speech confidence " + speechConfidence);
  }// onSpeechEvent
  
  void onWandEvent(Event e)
  {
    int objectID = e.getSourceID();
    int flag = e.getFlags();
    
    if( e.getEventType() == OmicronAPI.Type.Down )
    {
      //println("Wand ID " + objectID + " event: DOWN - Flag: " + flag);
    }
    else if( e.getEventType() == OmicronAPI.Type.Up )
    {
      //println("Wand ID " + objectID + " event: UP - Flag: " + flag);
    }
    else if( e.getEventType() == OmicronAPI.Type.Update )
    {
      //println("Wand ID " + objectID + " event: UPDATE");
      //println("  Analog 0 " + e.getFloatData(0));
      //println("  Analog 1 " + e.getFloatData(1));
      //println("  Analog 2 " + e.getFloatData(2));
      //println("  Analog 3 " + e.getFloatData(3));
      //println("  Analog 4 " + e.getFloatData(4));
      
    }
  }
}// EventListener
