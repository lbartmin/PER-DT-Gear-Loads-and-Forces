clc 
clear

PER25endurance = readmatrix("Comp_AutoX.csv");
startID = 1215;
endID = 3648;

right_rpm = PER25endurance(startID:endID,333); 
right_torque = PER25endurance(startID:endID,334); % Percentage of Nominal Torque
torque_nm = right_torque ./100 .*9.8; % convert to N-m


  

%plot forwards motor torque
figure(1)
h = histogram2(right_rpm, torque_nm, 0:3000:21000, 0:5:25,  Normalization="probability");
xlabel("RPM")
ylabel("Torque [N-m]")
colorbar
title("PER25 Comp AutoX Load Spectra")


%plot to compare to Andrew's plett scaled histogram
figure(2)
% Define bin edges
rpm_edges = 3000:3000:15000;       % left edges for 5 bins
rpm_edges = [rpm_edges, 18000];    % add an upper edge to include 15000

torque_edges = 3.5:3.5:21;         % left edges for 6 bins
torque_edges = [torque_edges, 24.5]; % add an upper edge to include 21

% Create histogram
h2 = histogram2(right_rpm, torque_nm, ...
               rpm_edges, torque_edges, ...
               'DisplayStyle', 'tile', 'Normalization', 'probability');

xlabel('RPM');
ylabel('Torque [Nm]');
title('Exact Comparison to 2025 Estimated Load Spectra')
colorbar;
xticks(3000:3000:15000);       % horizontal ticks exactly at bin edges
yticks(3.5:3.5:21); 
ax = gca;
ax.XAxis.Exponent = 0;  % Disable automatic exponent scaling
xtickformat('%,.0f'); 


counts = h2.Values;

%regen estimation
vehicle_speed = PER25endurance(startID:endID,202); % [m/s]
time = 0:(1/43):(length(vehicle_speed) - 1)*(1/43); % [s]
time = time.';

%plot forwards motor torque
figure(3)
h3 = plot(time, torque_nm);
xlabel("time [s]")
ylabel("Torque [N-m]")
colorbar
title("PER25 Comp AutoX Load Spectra")



mass = 290; %vehicle mass [kg]
radius = 0.2032; % 16in wheel radius [m]
gearRatio = 11.33;
drag_coeff = 1.5; 
front_area = 1; % [m^2]
air_density = 1.225; %[kg/m^3]
motor_torque_limit = 21; % [Nm]

KE = 0.5 * mass * vehicle_speed.^2; % kinetic energy equation
Power_total = gradient(KE,time); % (get the overall deccel/accel power)
P_drag = 0.5 * air_density * drag_coeff * front_area.*vehicle_speed.^3; %power from drag estimate 

P_brake = max(-(Power_total - P_drag),0); % set all braking power to be positive and replace accel power with 0

%P_regen = min(P_brake, P_limit); %(cap by tractive system limit?)
WheelTorque = P_brake ./ vehicle_speed  .* radius .* 0.25; % calculate individual wheel torque
MotorTorque = WheelTorque / gearRatio; % calculate motor torque

reverse_torque = MotorTorque .* (-1); % vector of original length containing only braking, 0's everywhere else

combined_torque = torque_nm +reverse_torque; %full lap, signed torque. take absolute value for magnitudes
combined_rpm = right_rpm;


% % Corresponding motor RPM 
% % Wheel angular speed [rad/s] = vehicle_speed / radius
% wheel_rad_s = vehicle_speed ./ radius; 
% % Motor angular speed [rad/s] = wheel speed * gear ratio
% motor_rad_s = wheel_rad_s .* gearRatio; 
% % Convert to RPM: rad/s * (60 / 2π)
% motor_rpm = motor_rad_s * (60 / (2*pi));

%nonzero_idx = MotorTorque > 0;
%brake_torque_nonzero = MotorTorque(nonzero_idx);
%rpm_nonzero = right_rpm(nonzero_idx);

%reverse_torque = MotorTorque .* (-1);

%combined_torque = torque_nm +reverse_torque;
%combined_torque = [torque_nm; reverse_torque];
%combined_rpm = [right_rpm; rpm_nonzero];
%combined_rpm = right_rpm;


figure(4)
h4 = plot(time, combined_torque);
xlabel("time [s]")
ylabel("Torque [N-m]")
colorbar
title("PER25 Comp AutoX Load Spectra with regen estimation")

% figure(2)
% h2 = histogram2(rpm_nonzero, reverse_torque, 0:3000:21000, -25:5:0,  Normalization="probability");
% xlabel("RPM from actual")
% ylabel("regen reverse Torque [N-m]")
% title("PER25 Comp AutoX Estimated Regen")
% colorbar


figure(5)
h5 = histogram2(combined_rpm, combined_torque, 0:3000:21000, -25:5:25,DisplayStyle = "tile",  Normalization="probability");
xlabel("RPM")
ylabel("Torque [N-m]")
title("PER25 Comp AutoX Estimated Load with Regen")
colorbar

figure(6)
h6 = histogram2(combined_rpm, combined_torque, 0:3000:21000, -25:5:25,  Normalization="probability");
xlabel("RPM")
ylabel("Torque [N-m]")
title("PER25 Comp AutoX Estimated Load with Regen")
colorbar

figure(7)
h7 = histogram2(combined_torque, combined_rpm, -25:5:25, 0:3000:21000,  Normalization="probability");
ylabel("RPM")
xlabel("Torque [N-m]")
title("PER25 Comp AutoX Estimated Load with Regen")


% DisplayStyle = "tile"
% disp(getTorque(100, 19000))
% disp(100*.26);
% 
% rpm = 0:500:20000;
% current = zeros(length(rpm), 1) + 100;
% torque = getTorque(current, rpm);
% figure(2)
% plot(0,0);
% hold on;
% plot(rpm, torque, "bo");