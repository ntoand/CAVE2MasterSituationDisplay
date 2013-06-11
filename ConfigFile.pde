/**
 * Parses a config file for touch tracker information.
 * By Arthur Nishimoto
 * 
 * @param config_file Text file containing tracker information.
 */
void readConfigFile(String config_file) {
  String[] rawConfig = loadStrings(config_file);

  trackerIP = "localhost";
  if ( rawConfig == null ) {
    println("No config.cfg file found. Using defaults.");
  } else {
    String tempStr = "";
    String currentBlockName = "";
    boolean inBlock = false;
    
    for ( int i = 0; i < rawConfig.length; i++ ) {
      rawConfig[i].trim(); // Removes leading and trailing white space

      if ( rawConfig[i].contains("//") ) // Removes comments
      {
          rawConfig[i] = rawConfig[i].substring( 0, rawConfig[i].indexOf("//") );
      }
      
      if ( rawConfig[i].length() == 0 ) // Ignore blank lines
        continue;
        
      if ( rawConfig[i].indexOf("}") != -1 ) // check block contents after this this
      {
        currentBlockName = "";
        inBlock = false;
      }
      
      // Check Contents in blocks ---------------------------------------------------
      if ( currentBlockName.contains("applicationLog") && inBlock ) // Get block name
      {
        String[] applicationData = rawConfig[i].split(" ");
        for(int j = 0; j < applicationData.length; j++ )
        {
          //println(j+"] '" + applicationData[j] + "'");
          String appName = applicationData[0];
          float gpu = Float.valueOf(applicationData[1]);
          float cpu = Float.valueOf(applicationData[2]);
          boolean flip = Boolean.valueOf(applicationData[3]);
          int displayFlag = Integer.valueOf(applicationData[4]);
          
          AppLabel app = new AppLabel(appName, gpu, cpu, flip, displayFlag);
          appList.add( app );
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

