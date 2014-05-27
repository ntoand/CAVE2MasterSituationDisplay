clc;
close all;
clear all;

CAVE2_diameter = 3.95 * 2;       
CAVE2_innerDiameter = 3.696 * 2;  
CAVE2_screenDiameter = 3.596 * 2;
CAVE2_legBaseWidth = 0.254;
CAVE2_legHeight = 2.159;
CAVE2_lowerRingHeight = 0.3048;
CAVE2_displayWidth = 1.02;
CAVE2_displayHeight = 0.579;
CAVE2_displayDepth = 0.08;
CAVE2_displayToFloor = 0.317;
CAVE2_Scale = 65;

nodesPerColumn = 1;


targetWidth = 2560;
targetHeight = 1600;

borderWidth = 20;
borderDistFromEdge = 30;

verticalOffset = 125;
verticalNodeSpacing = 121;

nNodes = 21;
nNodesLeft = 11;

rightNodeOffset = 0;

nodespos = zeros (21, 2);

nodespos(1, 1) = targetWidth - 70 - borderDistFromEdge - 500;
nodespos(1, 2) = targetHeight - verticalOffset - borderDistFromEdge - verticalNodeSpacing * nNodesLeft + verticalNodeSpacing * (nNodes - nNodesLeft);

%left nodes
for i=2:nNodesLeft + 1
    nodespos(i, 1) = 70 + borderDistFromEdge;
    nodespos(i, 2) = targetHeight - verticalOffset - borderDistFromEdge + verticalNodeSpacing * -(i-1);
end

%right nodes
for i=nNodesLeft + 2:nNodes
    nodespos(i, 1) = targetWidth - 70 - borderDistFromEdge - 500;
    nodespos(i, 2) = targetHeight - verticalOffset + rightNodeOffset - borderDistFromEdge - verticalNodeSpacing * nNodesLeft + verticalNodeSpacing * (i - 1 - (nNodesLeft));
end


% display columns transform
nColumns = 22; 
displayColumnTransform = cell(nColumns, 1);
for i = 0:nColumns-1
    displayColumnTransform{i+1}.angle = degtorad(108) + degtorad(360 / nColumns) * i; 
    
    displayColumnTransform{i+1}.xPos = CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale;
    displayColumnTransform{i+1}.xPos = displayColumnTransform{i+1}.xPos * cos(displayColumnTransform{i+1}.angle);
    
    displayColumnTransform{i+1}.yPos = CAVE2_screenDiameter/2 * CAVE2_Scale - (CAVE2_legBaseWidth - CAVE2_displayDepth) * CAVE2_Scale;
    displayColumnTransform{i+1}.yPos = displayColumnTransform{i+1}.yPos * sin(displayColumnTransform{i+1}.angle);
    
    fprintf ('x = %d, y = %d, z = %0.2f\n', round(displayColumnTransform{i+1}.xPos), round(displayColumnTransform{i+1}.yPos), displayColumnTransform{i+1}.angle);

end   

map_pos = zeros(targetHeight, targetWidth, 3);

% node details
nodeWidth = 250;

%left
for ii = 1:11
    nodeID = ii;
    fprintf ('\n ===== NODE %d =====\n', nodeID);
    displayPosX = round(displayColumnTransform{nodeID}.xPos * 2 + (targetWidth/2));
    displayPosY = round(displayColumnTransform{nodeID}.yPos * 2 + (targetHeight/2 - 20));
    angle = displayColumnTransform{nodeID}.angle;
    offset = CAVE2_displayWidth/nodesPerColumn * CAVE2_Scale;

    xPos = nodespos(nodeID+1, 1);
    yPos = nodespos(nodeID+1, 2);
    
    map_pos(yPos-1:yPos+1, xPos-1:xPos+1, 1) = 255;
    map_pos(displayPosY-1:displayPosY+1, displayPosX-1:displayPosX+1, 1) = 255;
    
    fprintf('nodexpos = %d, nodeypos = %d\n',nodespos(nodeID+1, 1), nodespos(nodeID+1, 2)); 
    fprintf('displayPosX = %d, displayPosY = %d, angle = %0.2f, offset = %d\n', round(displayPosX), round(displayPosY), angle, round(offset));

    angledDistance = ((yPos - displayPosY) / sin(angle));
    intersectionDistX = (xPos - displayPosX) / cos(angle);

    if( angledDistance < 0 )
        angledDistance = 0;
    end    
    
    if( angledDistance > displayPosX - xPos )
        angledDistance = displayPosX - xPos - nodeWidth;
    end

    if( abs((180 - radtodeg(angle))) < 2 )
        angledDistance = 0;
    end

    intersectionX = round(displayPosX + angledDistance * cos(angle));
    intersectionY = round(displayPosY + angledDistance * sin(angle));
    fprintf('intersectionX = %d, intersectionY = %d\n', round(intersectionX), round(intersectionY));
    
    map_pos(intersectionY-1:intersectionY+1, intersectionX-1:intersectionX+1, 2) = 255;
end

%right
for ii = 12:20
    nodeID = ii;
    fprintf ('\n ===== NODE %d =====\n', nodeID);
    displayPosX = round(displayColumnTransform{nodeID}.xPos * 2 + (targetWidth/2));
    displayPosY = round(displayColumnTransform{nodeID}.yPos * 2 + (targetHeight/2 - 20));
    angle = displayColumnTransform{nodeID}.angle + pi;
    offset = CAVE2_displayWidth/nodesPerColumn * CAVE2_Scale;

    xPos = nodespos(nodeID+1, 1);
    yPos = nodespos(nodeID+1, 2);
    
    map_pos(yPos-1:yPos+1, xPos-1:xPos+1, 1) = 255;
    map_pos(displayPosY-1:displayPosY+1, displayPosX-1:displayPosX+1, 1) = 255;
    
    fprintf('nodexpos = %d, nodeypos = %d\n',nodespos(nodeID+1, 1), nodespos(nodeID+1, 2)); 
    fprintf('displayPosX = %d, displayPosY = %d, angle = %0.2f, offset = %d\n', round(displayPosX), round(displayPosY), angle, round(offset));

    angledDistance = ((yPos - displayPosY) / sin(angle));
    intersectionDistX = (xPos - displayPosX) / cos(angle);

    if( angledDistance < 0 )
        angledDistance = -angledDistance;
    end    
    
    if( angle > 2 * pi )
        angle = angle - 2 * pi;
    end
    
    minAngle = 2;
    if( abs((180 - radtodeg(angle))) < minAngle || abs((180 - radtodeg(angle))) > 360 - minAngle )
        angledDistance = 0;
    end
    fprintf('angledDistance = %d, angle = %0.2f\n', round(angledDistance), angle);
    
    intersectionX = round(displayPosX - angledDistance * cos(angle));
    intersectionY = round(displayPosY - angledDistance * sin(angle));
    fprintf('intersectionX = %d, intersectionY = %d\n', round(intersectionX), round(intersectionY));
    
    map_pos(intersectionY-1:intersectionY+1, intersectionX-1:intersectionX+1, 2) = 255;
end

figure, imshow(map_pos);