/**
 * ---------------------------------------------
 * ConfigFile.pde
 * Description: Configuration file parser
 *
 * Class: 
 * System: Processing 2.2, SUSE 12.1, Windows 7 x64
 * Author: Arthur Nishimoto
 * Copyright (C) 2012-2014
 * Electronic Visualization Laboratory, University of Illinois at Chicago
 *
 * Version Notes:
 * ---------------------------------------------
 */

void readConfigFile(String config_file) {
  String[] rawConfig = loadStrings(config_file);

  if ( rawConfig == null ) {
    println("No config.cfg file found. Using defaults.");
  } else {
    String tempStr = "";
    String currentBlockName = "";
    boolean inBlock = false;
    
    for ( int i = 0; i < rawConfig.length; i++ ) {
      rawConfig[i].trim(); // Removes leading and trailing white space

      if ( rawConfig[i].contains("//") && !rawConfig[i].contains("://") ) // Removes comments
      {
          rawConfig[i] = rawConfig[i].substring( 0, rawConfig[i].indexOf("//") );
      }
      
      if ( rawConfig[i].length() == 0 ) // Ignore blank lines
        continue;
      
            
      if ( rawConfig[i].contains("fullscreen") && rawConfig[i].contains("true") ) {
        showFullscreen = true;
        continue;
      }
      else if ( rawConfig[i].contains("fullscreen") && rawConfig[i].contains("false") ) {
        showFullscreen = false;
        continue;
      }
      
      if ( rawConfig[i].contains("windowWidth") ) {
        tempStr = rawConfig[i].substring( rawConfig[i].indexOf("=")+1, rawConfig[i].lastIndexOf(";") );
        windowWidth = Integer.valueOf( tempStr.trim() );
        continue;
      }
      if ( rawConfig[i].contains("windowHeight") ) {
        tempStr = rawConfig[i].substring( rawConfig[i].indexOf("=")+1, rawConfig[i].lastIndexOf(";") );
        windowHeight = Integer.valueOf( tempStr.trim() );
        continue;
      }
      
      if ( rawConfig[i].contains("trackerServerIP") ) {
        trackerIP = rawConfig[i].substring( rawConfig[i].indexOf("\"")+1, rawConfig[i].lastIndexOf("\"") );
        connectToTracker = true;
        continue;
      }
      if ( rawConfig[i].contains("trackerDataPort") ) {
        tempStr = rawConfig[i].substring( rawConfig[i].indexOf("=")+1, rawConfig[i].lastIndexOf(";") );
        dataport = Integer.valueOf( tempStr.trim() );
        continue;
      }
      if ( rawConfig[i].contains("trackerMsgPort") ) {
        tempStr = rawConfig[i].substring( rawConfig[i].indexOf("=")+1, rawConfig[i].lastIndexOf(";") );
        msgport = Integer.valueOf( tempStr.trim() );
        continue;
      }

      if ( rawConfig[i].contains("clusterData_URL") ) {
        println("Reading cluster data from: " + rawConfig[i]);
        clusterData = rawConfig[i].substring( rawConfig[i].indexOf("\"")+1, rawConfig[i].lastIndexOf("\"") );
        connectToClusterData = true;
        continue;
      }
      
      if ( rawConfig[i].contains("clusterPing1_URL") ) {
        println("Reading cluster network data 1 from: " + rawConfig[i]);
        clusterPing1 = rawConfig[i].substring( rawConfig[i].indexOf("\"")+1, rawConfig[i].lastIndexOf("\"") );
        usingPing1 = true;
        continue;
      }
      
      if ( rawConfig[i].contains("clusterPing2_URL") ) {
        println("Reading cluster network data 2 from: " + rawConfig[i]);
        clusterPing2 = rawConfig[i].substring( rawConfig[i].indexOf("\"")+1, rawConfig[i].lastIndexOf("\"") );
        usingPing2 = true;
        continue;
      }
      
      if ( rawConfig[i].contains("clusterUpdateInterval") ) {
        tempStr = rawConfig[i].substring( rawConfig[i].indexOf("=")+1, rawConfig[i].lastIndexOf(";") );
        clusterUpdateInterval = Float.valueOf( tempStr.trim() );
        continue;
      }
      
      if( rawConfig[i].contains("defaultScreen") && rawConfig[i].contains("TRACKER") ){
        state = TRACKING;
        println("Default screen set to TRACKER");
        continue;
      }
      if( rawConfig[i].contains("defaultScreen") && rawConfig[i].contains("CLUSTER") ){
        state = CLUSTER;
        println("Default screen set to CLUSTER");
        continue;
      }
      if( rawConfig[i].contains("defaultScreen") && rawConfig[i].contains("OLD_INTERFACE") ){
        state = CLUSTER_OLD;
        println("Default screen set to CLUSTER_OLD");
        continue;
      }
      
      if ( rawConfig[i].indexOf("}") != -1 ) // check block contents after this this
      {
        currentBlockName = "";
        inBlock = false;
      }
      
      // Check Contents in blocks ---------------------------------------------------
      if ( currentBlockName.contains("applicationLog") && inBlock ) // Get block name
      {
        String[] applicationData = rawConfig[i].split(" ");
        
        if( applicationData.length == 5 )
        {
          for(int j = 0; j < applicationData.length; j++ )
          {
            //println(j+"] '" + applicationData[j] + "'");
            String appName = applicationData[0];
            float gpu = Float.valueOf(applicationData[1]);
            float cpu = Float.valueOf(applicationData[2]);
            boolean flip = Boolean.valueOf(applicationData[3]);
            int displayFlag = Integer.valueOf(applicationData[4]);
            
            AppLabel app = new AppLabel(appName, gpu, cpu, flip, displayFlag);
            appList.put( appName, app );
          }
        }
      }
      

      // ----------------------------------------------------------------------------
      // Start/end block detection - check block contents before this
      if ( rawConfig[i].indexOf(":") != -1 ) // Get block name
      {
        currentBlockName = rawConfig[i].substring( 0, rawConfig[i].indexOf(":") ).trim();
      }
      else if ( rawConfig[i].indexOf("{") != -1 )
      {
        inBlock = true;
      }
    }// for
  }
}// readConfigFile

