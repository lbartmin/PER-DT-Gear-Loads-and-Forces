%Description
data = readmatrix("Data.xlsx");

mass = data(1,3);
wheelbase = data(2,3);
track = data(3,3);
Lm = data(4,3);
Hm = data(5,3);
mu = data(6,3);
downforceMU = data(7,3);
g = data(8,3);
maxAeroForce = data(9,3);
dynamicMultiplicationFactor = data(10,3);

%Basic Calcs
weight = mass * g;
effectiveWeight = weight + maxAeroForce;

%%%%%%%%%%%%%%%%%%%%%%% No Transfer Loads %%%%%%%%%%%%%%%%%%%%%%%%%%
%determines axle loads without any weight transfer at max downforce
rearAxleLoadStatic = effectiveWeight * (Lm / wheelbase); %determines rear axle load in N by taking moments about front axle
frontAxleLoadStatic = effectiveWeight - rearAxleLoadStatic; %determines front axle load in N

frontLeftVerticalLoad = frontAxleLoadStatic/2;
frontRightVerticalLoad = frontAxleLoadStatic/2;
rearLeftVerticalLoad = rearAxleLoadStatic/2;
rearRightVerticalLoad = rearAxleLoadStatic/2;
frontLeftLongitudinalLoad = 0;
frontRightLongitudinalLoad = 0;
rearLeftLongitudinalLoad = 0;
rearRightLongitudinalLoad = 0;
frontLeftAxialLoad = 0;
frontRightAxialLoad = 0;
rearLeftAxialLoad = 0;
rearRightAxialLoad = 0;

C = {frontLeftVerticalLoad, frontRightVerticalLoad; frontLeftLongitudinalLoad, frontRightLongitudinalLoad; frontLeftAxialLoad, frontRightAxialLoad; rearLeftVerticalLoad, rearRightVerticalLoad; rearLeftLongitudinalLoad, rearRightLongitudinalLoad; rearLeftAxialLoad, rearRightAxialLoad};
writecell(C, 'Data.xlsx', 'Range', 'F4:G9');

fprintf("--------------No Transfer Loads (Max Downforce)--------------------\n");
fprintf("Static Front Wheel Load: %.2f N\n", frontAxleLoadStatic / 2);
fprintf("Static Rear Wheel Load: %.2f N\n", rearAxleLoadStatic / 2);

%%%%%%%%%%%%%%%%%%%% Acceleration Loads %%%%%%%%%%%%%%%%%%%%%%
%Since the car is starting from rest there are no aerodynamic forces in
%these calculations
rearAxleLoadStaticAccel = weight * (Lm / wheelbase);
frontAxleLoadStaticAccel = weight - rearAxleLoadStaticAccel;
tractionForce = (rearAxleLoadStaticAccel * mu) / (1 - ((Hm * mu) / wheelbase));
longitudinalLoadTransferAccel = tractionForce * (Hm / wheelbase);
rearAxleLoadAccel = (rearAxleLoadStaticAccel + longitudinalLoadTransferAccel) * dynamicMultiplicationFactor;
frontAxleLoadAccel = (frontAxleLoadStaticAccel - longitudinalLoadTransferAccel) * dynamicMultiplicationFactor;
rearVerticalWheelLoadAccel = rearAxleLoadAccel / 2;
frontVerticalWheelLoadAccel = frontAxleLoadStaticAccel / 2;
frontLongitudinalWheelLoadAccel = frontVerticalWheelLoadAccel * mu;
rearLongitudinalWheelLoadAccel = rearVerticalWheelLoadAccel * mu;
launchAccel = (tractionForce / mass) / g;

frontLeftVerticalLoad = frontVerticalWheelLoadAccel;
frontRightVerticalLoad = frontVerticalWheelLoadAccel;
rearLeftVerticalLoad = rearVerticalWheelLoadAccel;
rearRightVerticalLoad = rearVerticalWheelLoadAccel;
frontLeftLongitudinalLoad = frontLongitudinalWheelLoadAccel;
frontRightLongitudinalLoad = frontLongitudinalWheelLoadAccel;
rearLeftLongitudinalLoad = rearLongitudinalWheelLoadAccel;
rearRightLongitudinalLoad = rearLongitudinalWheelLoadAccel;
frontLeftAxialLoad = 0;
frontRightAxialLoad = 0;
rearLeftAxialLoad = 0;
rearRightAxialLoad = 0;

C = {frontLeftVerticalLoad, frontRightVerticalLoad; frontLeftLongitudinalLoad, frontRightLongitudinalLoad; frontLeftAxialLoad, frontRightAxialLoad; rearLeftVerticalLoad, rearRightVerticalLoad; rearLeftLongitudinalLoad, rearRightLongitudinalLoad; rearLeftAxialLoad, rearRightAxialLoad};
writecell(C, 'Data.xlsx', 'Range', 'F14:G19');

fprintf("--------------Acceleration Loads--------------\n");
fprintf("Traction Force: %.2f\n", tractionForce);
fprintf("Longitudinal Load Transfer: +- %.2f N\n", longitudinalLoadTransferAccel)
fprintf("Accel Rear Vertical Wheel Load: %.2f N\n", rearVerticalWheelLoadAccel);
fprintf("Accel Rear Longitudinal Wheel Load: %.2f N\n", rearLongitudinalWheelLoadAccel);
%fprintf("Launch Acceleration: " + launchAccel + " g\n");

%%%%%%%%%%%%%%%%%%%% Cornering Loads %%%%%%%%%%%%%%%%%%%%%%
%determines front tire loads during maximum cornering
corneringForce = effectiveWeight * downforceMU;
lateralWeightTransfer = corneringForce * (Hm / track);
frontWheelVerticalCorneringForce = ((frontAxleLoadStatic / 2) + (lateralWeightTransfer * 0.625)) * dynamicMultiplicationFactor;
frontWheelLateralCorneringForce = frontWheelVerticalCorneringForce * downforceMU;
rearWheelVerticalCorneringForce = ((rearAxleLoadStatic / 2) + (lateralWeightTransfer * 0.625)) * dynamicMultiplicationFactor;
rearWheelLateralCorneringForce = rearWheelVerticalCorneringForce * downforceMU;

frontLeftVerticalLoad = frontWheelVerticalCorneringForce;
frontRightVerticalLoad = frontWheelVerticalCorneringForce;
rearLeftVerticalLoad = rearWheelVerticalCorneringForce;
rearRightVerticalLoad = rearWheelVerticalCorneringForce;
frontLeftLongitudinalLoad = 0;
frontRightLongitudinalLoad = 0;
rearLeftLongitudinalLoad = 0;
rearRightLongitudinalLoad = 0;
frontLeftAxialLoad = frontWheelLateralCorneringForce;
frontRightAxialLoad = frontWheelLateralCorneringForce;
rearLeftAxialLoad = rearWheelLateralCorneringForce;
rearRightAxialLoad = rearWheelLateralCorneringForce;

C = {frontLeftVerticalLoad, frontRightVerticalLoad; frontLeftLongitudinalLoad, frontRightLongitudinalLoad; frontLeftAxialLoad, frontRightAxialLoad; rearLeftVerticalLoad, rearRightVerticalLoad; rearLeftLongitudinalLoad, rearRightLongitudinalLoad; rearLeftAxialLoad, rearRightAxialLoad};
writecell(C, 'Data.xlsx', 'Range', 'F24:G29');

fprintf("--------------Cornering Loads-----------------\n");
fprintf("Cornering Force: %.2f\n", corneringForce);
fprintf("Lateral Load Transfer: +- %.2f N\n", lateralWeightTransfer);
fprintf("Cornering Front Wheel Vertical Load: %.2f N\n", frontWheelVerticalCorneringForce);
fprintf("Cornering Front Wheel Lateral Load: %.2f N\n", frontWheelLateralCorneringForce);
fprintf("Cornering Rear Wheel Vertical Load: %.2f N\n", rearWheelVerticalCorneringForce);
fprintf("Cornering Rear Wheel Lateral Load: %.2f N\n", rearWheelLateralCorneringForce);

%%%%%%%%%%%%%%%%%%%% Braking Loads %%%%%%%%%%%%%%%%%%%%%%
%determines front tire loads during maximum braking from top speed
brakingForce = effectiveWeight * downforceMU;
longitudinalLoadTransferBrake = brakingForce * (Hm / wheelbase);
frontAxleLoadBrake = frontAxleLoadStatic + longitudinalLoadTransferBrake;
rearAxleLoadBrake = rearAxleLoadStatic - longitudinalLoadTransferBrake;
rearWheelVerticalBrakingLoad = (rearAxleLoadBrake / 2) * dynamicMultiplicationFactor;
rearWheelLongitudinalBrakingForce = rearWheelVerticalBrakingLoad * downforceMU;
frontWheelVerticalBrakingLoad = (frontAxleLoadBrake / 2) * dynamicMultiplicationFactor;
frontWheelLongitudinalBrakingForce = frontWheelVerticalBrakingLoad * downforceMU;

frontLeftVerticalLoad = frontWheelVerticalBrakingLoad;
frontRightVerticalLoad = frontWheelVerticalBrakingLoad;
rearLeftVerticalLoad = rearWheelVerticalBrakingLoad;
rearRightVerticalLoad = rearWheelVerticalBrakingLoad;
frontLeftLongitudinalLoad = -frontWheelLongitudinalBrakingForce;
frontRightLongitudinalLoad = -frontWheelLongitudinalBrakingForce;
rearLeftLongitudinalLoad = -rearWheelLongitudinalBrakingForce;
rearRightLongitudinalLoad = -rearWheelLongitudinalBrakingForce;
frontLeftAxialLoad = 0;
frontRightAxialLoad = 0;
rearLeftAxialLoad = 0;
rearRightAxialLoad = 0;

C = {frontLeftVerticalLoad, frontRightVerticalLoad; frontLeftLongitudinalLoad, frontRightLongitudinalLoad; frontLeftAxialLoad, frontRightAxialLoad; rearLeftVerticalLoad, rearRightVerticalLoad; rearLeftLongitudinalLoad, rearRightLongitudinalLoad; rearLeftAxialLoad, rearRightAxialLoad};
writecell(C, 'Data.xlsx', 'Range', 'F34:G39');

fprintf("--------------Braking Loads-------------------\n");
fprintf("Braking Force: %.2f\n", brakingForce);
fprintf("Longitudinal Load Transfer: +- %.2f N\n", longitudinalLoadTransferBrake);
fprintf("Brake Front Wheel Vertical Load: %.2f N\n", frontWheelVerticalBrakingLoad);
fprintf("Brake Front Wheel Longitudinal Load: %.2f N\n", frontWheelLongitudinalBrakingForce);
fprintf("Brake Rear Wheel Vertical Load: %.2f N\n", rearWheelVerticalBrakingLoad);
fprintf("Brake Rear Wheel Longitudinal Load: %.2f N\n", rearWheelLongitudinalBrakingForce);