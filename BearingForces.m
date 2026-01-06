%read in excel data
    data = readmatrix('Data.xlsx');
%check if user wants to user the calculated forces from TireFroces.m or
%given forces entered in excel
usingCalculatedTireForces = false;
if (data(6, 17) == 1)
    usingCalculatedTireForces = true;
end

%%%%%%%%%%%%%%%%%%%% Max Acceleration %%%%%%%%%%%%%%%%%%%%%%
if(usingCalculatedTireForces)
    frontVerticalWheelLoadAccel = data(12, 6);
    frontLongitudinalWheelLoadAccel = data(13, 6);
    frontLateralWheelLoadAccel = data(14, 6);
    rearVerticalWheelLoadAccel = data(15, 6);
    rearLongitudinalWheelLoadAccel = data(16, 6);
    rearLateralWheelLoadAccel = data(17, 6);
else
    frontVerticalWheelLoadAccel = data(12, 11);
    frontLongitudinalWheelLoadAccel = data(13, 11);
    frontLateralWheelLoadAccel = data(14, 11);
    rearVerticalWheelLoadAccel = data(15, 11);
    rearLongitudinalWheelLoadAccel = data(16, 11);
    rearLateralWheelLoadAccel = data(17, 11);
end

calcBearingForces(frontVerticalWheelLoadAccel, frontLongitudinalWheelLoadAccel, frontLateralWheelLoadAccel, rearVerticalWheelLoadAccel, rearLongitudinalWheelLoadAccel, rearLateralWheelLoadAccel, 'T17:U18', 'X17:Y18', 'T19', 'Y19', 'T20:U21', 'X20:Y21', 'T22', 'Y22');

%%%%%%%%%%%%%%%%%%%% Max Cornering %%%%%%%%%%%%%%%%%%%%%%
if(usingCalculatedTireForces)
    frontVerticalWheelLoadCornering = data(22, 6);
    frontLongitudinalWheelLoadCornering = data(23, 6);
    frontLateralWheelLoadCornering = data(24, 6);
    rearVerticalWheelLoadCornering = data(25, 6);
    rearLongitudinalWheelLoadCornering = data(26, 6);
    rearLateralWheelLoadCornering = data(27, 6);
else
    frontVerticalWheelLoadCornering = data(22, 11);
    frontLongitudinalWheelLoadCornering = data(23, 11);
    frontLateralWheelLoadCornering = data(24, 11);
    rearVerticalWheelLoadCornering = data(25, 11);
    rearLongitudinalWheelLoadCornering = data(26, 11);
    rearLateralWheelLoadCornering = data(27, 11);
end

calcBearingForces(frontVerticalWheelLoadCornering, frontLongitudinalWheelLoadCornering, frontLateralWheelLoadCornering, rearVerticalWheelLoadCornering, rearLongitudinalWheelLoadCornering, rearLateralWheelLoadCornering, 'T29:U30', 'X29:Y30', 'T31', 'Y31', 'T32:U33', 'X32:Y33', 'T34', 'Y34');

%%%%%%%%%%%%%%%%%%%% Max Braking %%%%%%%%%%%%%%%%%%%%%%
if(usingCalculatedTireForces)
    frontVerticalWheelLoadCornering = data(32, 6);
    frontLongitudinalWheelLoadCornering = data(33, 6);
    frontLateralWheelLoadCornering = data(34, 6);
    rearVerticalWheelLoadCornering = data(35, 6);
    rearLongitudinalWheelLoadCornering = data(36, 6);
    rearLateralWheelLoadCornering = data(37, 6);
else
    frontVerticalWheelLoadCornering = data(32, 11);
    frontLongitudinalWheelLoadCornering = data(33, 11);
    frontLateralWheelLoadCornering = data(34, 11);
    rearVerticalWheelLoadCornering = data(35, 11);
    rearLongitudinalWheelLoadCornering = data(36, 11);
    rearLateralWheelLoadCornering = data(37, 11);
end

calcBearingForces(frontVerticalWheelLoadCornering, frontLongitudinalWheelLoadCornering, frontLateralWheelLoadCornering, rearVerticalWheelLoadCornering, rearLongitudinalWheelLoadCornering, rearLateralWheelLoadCornering, 'T41:U42', 'X41:Y42', 'T43', 'Y43', 'T44:U45', 'X44:Y45', 'T46', 'Y46');


%function that caluclates bearing forces
function calcBearingForces(frontVerticalWheelLoad, frontLongitudinalWheelLoad, frontLateralWheelLoad, rearVerticalWheelLoad, rearLongitudinalWheelLoad, rearLateralWheelLoad, frontLeftRange, frontRightRange, frontLeftAxialCell, frontRightAxialCell, rearLeftRange, rearRightRange, rearLeftAxialCell, rearRightAxialCell)
    
    %read in excel data
    data = readmatrix('Data.xlsx');
    
    %assign variables from excel data
    rollingRadius = data(1, 17);
    frontBearingSpacing = data(2, 17);
    rearBearingSpacing = data(3, 17);
    frontDistanceToTireCenter = data(4, 17);
    rearDistanceToTireCenter = data(5, 17);

    frontOuterBearingVerticalForce = ((-(frontBearingSpacing + frontDistanceToTireCenter) * frontVerticalWheelLoad) - (rollingRadius * frontLateralWheelLoad)) / frontBearingSpacing;
    frontInnerBearingVerticalForce = -frontOuterBearingVerticalForce - frontVerticalWheelLoad;
    frontOuterBearingHorizontalForce = (-(frontBearingSpacing + frontDistanceToTireCenter) * frontLongitudinalWheelLoad) / frontBearingSpacing;
    frontInnerBearingHorizontalForce = -frontOuterBearingHorizontalForce - frontLongitudinalWheelLoad;
    frontAxialBearingForce = -frontLateralWheelLoad;
    
    rearOuterBearingVerticalForce = ((-(rearBearingSpacing + rearDistanceToTireCenter) * rearVerticalWheelLoad) - (rollingRadius * rearLateralWheelLoad)) / rearBearingSpacing;
    rearInnerBearingVerticalForce = -rearOuterBearingVerticalForce - rearVerticalWheelLoad;
    rearOuterBearingHorizontalForce = (-(rearBearingSpacing + rearDistanceToTireCenter) * rearLongitudinalWheelLoad) / rearBearingSpacing;
    rearInnerBearingHorizontalForce = -rearOuterBearingHorizontalForce - rearLongitudinalWheelLoad;
    rearAxialBearingForce = -rearLateralWheelLoad;
    
    frontLeft = {frontOuterBearingVerticalForce, frontInnerBearingVerticalForce; frontOuterBearingHorizontalForce, frontInnerBearingHorizontalForce};
    frontRight = {frontInnerBearingVerticalForce, frontOuterBearingVerticalForce; frontInnerBearingHorizontalForce, frontOuterBearingHorizontalForce};
    rearLeft = {rearOuterBearingVerticalForce, rearInnerBearingVerticalForce; rearOuterBearingHorizontalForce, rearInnerBearingHorizontalForce};
    rearRight = {rearInnerBearingVerticalForce, rearOuterBearingVerticalForce; rearInnerBearingHorizontalForce, rearOuterBearingHorizontalForce};
    writecell(frontLeft, 'Data.xlsx', 'Range', frontLeftRange);
    writecell(frontRight, 'Data.xlsx', 'Range', frontRightRange);
    writecell(rearLeft, 'Data.xlsx', 'Range', rearLeftRange);
    writecell(rearRight, 'Data.xlsx', 'Range', rearRightRange);
    
    writecell({frontAxialBearingForce}, 'Data.xlsx', 'Range', frontLeftAxialCell);
    writecell({frontAxialBearingForce}, 'Data.xlsx', 'Range', frontRightAxialCell);
    writecell({rearAxialBearingForce}, 'Data.xlsx', 'Range', rearLeftAxialCell);
    writecell({rearAxialBearingForce}, 'Data.xlsx', 'Range', rearRightAxialCell);
end