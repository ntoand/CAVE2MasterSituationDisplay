String[][] allElements = new String[37][25];
int[][]allCPUs = new int[37][16];
int[]allGPUs = new int[37];
int[]netIn = new int[37];
int[]netOut = new int[37];
int[]memUsed = new int[37];

String website = "http://lyra.evl.uic.edu:9000/html/cluster.txt";

void getData()
{
  String lines[] = loadStrings(website);
  
  allElements = new String[37][25];
  allCPUs = new int[37][16];
  allGPUs = new int[37];
  netIn = new int[37];
  netOut = new int[37];
  memUsed = new int[37];

  if (lines != null){
  for (int node = 0 ; node < lines.length; node++) {
    String[] elements = splitTokens(lines[node]);
  
    // grab the node name
  
    allElements[node][0] = elements[0];
    allElements[node][1] = elements[1];
  
    // uptime may be missing the Days field so we need to handle the special case
    
     if (elements.length == 25){
       for (int j = 2 ; j < 25; j++) {
          allElements[node][j] = elements[j];
       }
     }
     
     if (elements.length < 25){
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
}
