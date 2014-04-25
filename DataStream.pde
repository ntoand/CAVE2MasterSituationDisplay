/**
 * ---------------------------------------------
 * DataStream.pde
 * Description: CAVE2 Master Situation Display (MSD)
 *
 * Class: 
 * System: Processing 2.1, SUSE 12.1, Windows 7 x64
 * Author(s): Andrew Johnson, Arthur Nishimoto
 * Copyright (C) 2012-2014
 * Electronic Visualization Laboratory, University of Illinois at Chicago
 *
 * Version Notes:
 * ---------------------------------------------
 */

String[][] allElements = new String[37][25];
int[][]allCPUs = new int[37][16];
int[]allGPUs = new int[37];
int[]netIn = new int[37];
int[]netOut = new int[37];
int[]memUsed = new int[37];

String badNode = "";
String pings[];

float clusterReconnectDelay = 10;
float clusterReconnectTimer;

float clusterPingDelay = 1;
float clusterPingTimer;

void getData()
{
  if ( clusterReconnectTimer > 0 )
  {
    clusterReconnectTimer -= deltaTime;
    return;
  }

  if ( clusterPingTimer > 0 )
  {
    clusterPingTimer -= deltaTime;
    return;
  }
  else
  {
    ping();
    clusterPingTimer = clusterUpdateInterval;
  }

  String lines[] = loadStrings(clusterData);
  if ( lines == null)
  {
    clusterReconnectTimer = clusterReconnectDelay;
    connectedToClusterData = false;
    allElements = new String[37][25];
    allCPUs = new int[37][16];
    allGPUs = new int[37];
    netIn = new int[37];
    netOut = new int[37];
    memUsed = new int[37];
  }
  else
  {
    connectedToClusterData = true;
  }

  /*
  allElements = new String[37][25];
   allCPUs = new int[37][16];
   allGPUs = new int[37];
   netIn = new int[37];
   netOut = new int[37];
   memUsed = new int[37];
   */
  //try
  //{
    if (lines != null) {
      for (int node = 0 ; node < lines.length; node++) {
        String[] elements = splitTokens(lines[node]);

        // grab the node name

        allElements[node][0] = elements[0];
        allElements[node][1] = elements[1];

        // uptime may be missing the Days field so we need to handle the special case

        if (elements.length == 25) {
          for (int j = 2 ; j < 25; j++) {
            allElements[node][j] = elements[j];
          }
        }

        if (elements.length < 25) {
          for (int j = 4 ; j < 25; j++) {
            allElements[node][j] = elements[j-2];
          }
          allElements[node][2] = "0";
          allElements[node][3] = "days";
        }   

        // grab the GPU and Network data

        allGPUs[node] = int(allElements[node][21]);
        netIn[node]   = int(allElements[node][22]);
        netOut[node]  = int(allElements[node][23]);
        memUsed[node]  = int(allElements[node][24]) * 100 / 64;

        // grab the CPU core data

        for (int core = 0 ; core < 16; core++) {
          allCPUs[node][core] = int(allElements[node][core+5]);
        }
      }
    }
  //}
  //catch( Exception e )
  //{
  //  e.printStackTrace();
  //}
}

public void ping()
{
  //try
  //{
    badNode = "";

    // check all the nodes from the first network interface

    pings = loadStrings(clusterPing1);

    for (int node = 0 ; node < pings.length; node++)
    {
      String[] elements = splitTokens(pings[node]);

      if (elements[1].equals("DOWN") == true )
      {
        badNode = elements[0];
        nodePing[node-1] = false;
      }
      else if ( elements[1].equals("UP") == true )
      {
        if ( node > 0 )
          nodePing[node-1] = true;
      }
    }

    pings = loadStrings(clusterPing2);

    for (int node = 0 ; node < pings.length; node++)
    {
      String[] elements = splitTokens(pings[node]);

      if (elements[1].equals("DOWN") == true )
      {
        badNode = elements[0];
        nodeCavewavePing[node-1] = false;
      }
      else if ( elements[1].equals("UP") == true )
      {
        if ( node > 0 )
          nodeCavewavePing[node-1] = true;
      }
    }
  //}
  //catch( Exception e )
  //{
  //  e.printStackTrace();
  //}
}

