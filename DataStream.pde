/**
 * ---------------------------------------------
 * DataStream.pde
 * Description: CAVE2 Master Situation Display (MSD)
 *
 * Class: 
 * System: Processing 2.2, SUSE 12.1, Windows 7 x64
 * Author(s): Andrew Johnson, Arthur Nishimoto
 * Copyright (C) 2012-2014
 * Electronic Visualization Laboratory, University of Illinois at Chicago
 *
 * Version Notes:
 * ---------------------------------------------
 */

int NUM_ELEMENTS = 42; 
String[][] allElements = new String[21][NUM_ELEMENTS];
int[][]allCPUs = new int[21][32];
int[]allGPUs_usage = new int[21];
int[]allGPUs_mem = new int[21];
int[]netIn = new int[21];
int[]netOut = new int[21];
int[]memUsed = new int[21];

String badNode = "";
String pings[];

float clusterReconnectDelay = 10;
float clusterReconnectTimer;

float clusterPingDelay = 1;
float clusterPingTimer;

boolean usingPing1 = false;
boolean usingPing2 = false;

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
  if ( lines == null )
  {
    clusterReconnectTimer = clusterReconnectDelay;
    connectedToClusterData = false;
    allElements = new String[21][NUM_ELEMENTS];
    allCPUs = new int[21][32];
    allGPUs_usage = new int[21];
    allGPUs_mem = new int[21];
    netIn = new int[21];
    netOut = new int[21];
    memUsed = new int[21];
  }
  else
  {
    connectedToClusterData = true;
  }

  //try
  //{
    if (lines != null) {
      for (int node = 0 ; node < lines.length; node++) {
        String[] elements = splitTokens(lines[node]);

        // grab the node name
        allElements[node][0] = elements[0];
        allElements[node][1] = elements[1];

        // uptime may be missing the Days field so we need to handle the special case

        if (elements.length == NUM_ELEMENTS) {
          for (int j = 2 ; j < NUM_ELEMENTS; j++) {
            allElements[node][j] = elements[j];
          }
        }

        if (elements.length == NUM_ELEMENTS-2) {
          for (int j = 4 ; j < NUM_ELEMENTS; j++) {
            allElements[node][j] = elements[j-2];
          }
          allElements[node][2] = "0";
          allElements[node][3] = "days";
        }   

        // grab the GPU and Network data
        allGPUs_usage[node] = int(allElements[node][NUM_ELEMENTS-5]);
        allGPUs_mem[node] = int(allElements[node][NUM_ELEMENTS-4]);
        netIn[node]   = int(allElements[node][NUM_ELEMENTS-3]);
        netOut[node]  = int(allElements[node][NUM_ELEMENTS-2]);
        if (node == 0)
          memUsed[node]  = int(allElements[node][NUM_ELEMENTS-1]) * 100 / 256;
        else
          memUsed[node]  = int(allElements[node][NUM_ELEMENTS-1]) * 100 / 192;

        // grab the CPU core data
        for (int core = 0 ; core < 32; core++) {
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
    if( usingPing1 )
    {
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
    }
    
    if( usingPing2 )
    {
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
    }
  //}
  //catch( Exception e )
  //{
  //  e.printStackTrace();
  //}
}

