 %function [stress_matrix,] = PlanetShaft(torque_nm, time)

%   Parameters

torque_nm = combined_torque; %[nm]

PressureAngle = 20;
LoadDistF = 2.8; %AGMA 420.04 for 3 planets
GR = 12.5;
Sun_pd = 18.9; %pitch diameter
R = 32.85; % [mm] center distance
T_wheel = (torque_nm .* GR);

% save the index of all braking instances, since the stress calculations
% will only return a magnitude
brakingindex = zeros(length(torque_nm),1);
for j = 1:length(torque_nm)
    if torque_nm(j) < 0
        brakingindex(j)= -1;
    else
        brakingindex(j) = 1;
    end
end
% Force Calcs

W_TS = torque_nm./(Sun_pd./2000)./LoadDistF; % Tangential Sun Gear Force [N]
W_RS = W_TS .* tan(PressureAngle * (pi/180)); %Radial Sun Gear Force [N]
disp(max(W_RS));
W_S = sqrt(W_TS.^2 + W_RS.^2); % Sun Gear Load [N]

F_TS = T_wheel/(R/1000)/LoadDistF; % Tangential Shaft Force [N]

W_TR = F_TS - W_TS; % Tangtial Ring Gear Force [N]
W_RR = W_TR* tan(PressureAngle * (pi/180)); % Radial Ring Gear Force [N]
disp(max(W_TR));
F_RS = W_RR - W_RS; % Radial Shaft Force [N]

W_R = sqrt(W_TR.^2 + W_RR.^2); % Ring Gear Load [N]
F_S = sqrt(F_TS.^2 + F_RS.^2); % Shaft Force [N]

%shaft material properties
Sut = 1570; %[MPa] ultimate strength, 52100
Sy = 1280; % MPa, yield strength
youngs_modulus = 200; % gpa
S_e = 700; % MPa, lab endurance strength
surface_constant_a = 1.58; %Mpa, table 6-2 shigleys
surface_constant_b = -0.085; %table 6-2 shigleys
ka = surface_constant_a*Sut^surface_constant_b; %surface factor
kb = 1.08037; %size factor, eqn 6-20
kc = 1; %load factor
kd = 1.008; %temp factor
ke = 0.897; %reliability factor
se = S_e*ka*kb*kc*kd; %mpa, fully corrected endurance limit


sig_f_prime = Sut + 345; %[sae approximation, eqn 6-11 shigleys, mpa]
%f = sig_f_prime/Sut * (2 * 10^3)^b;
f = 0.77; % fatigue strength fraction
%a = ((f*Sut)^2)/S_e;
%b = (-1/3)*(log(f*Sut)/log(S_e));
N1 = 1e3; 
N2 = 1e6;
sigma1 = f * Sut;
sigma2 = se;

% slope and intercept
b = log(sigma2/sigma1) / log(N2/N1); % eqn 6-15 shigley
a = sigma1 / (N1^b); % eqn 6-14 shigley

%shaft dimensions
Shaftlength = 33; %mm 
Do = 7; %mm, shaft od
Di = 4; %mm, shaft id
I = pi*((Do/2000)^4-(Di/2000)^4)/4; %2nd moment of area

%shaft failure analysis
BendingMoment = F_S * (Shaftlength/4000);
BendingStress = (BendingMoment * (Do/2000))/I/1000000;
BendingStress_signed = BendingStress .* brakingindex; % represent throttle & brake fluctuations

figure(17)
h17 = plot(time, BendingStress_signed);
title("Bending Stress Magnitudes on Planet Shafts (Mpa)");

% stiffness analysis
ymax_um = (F_S.* (Shaftlength./1000).^3)./(48*youngs_modulus.*1000000000.*I) .*1000000; %um
ymax = ymax_um ./1000 ; % [mm]
%inclination = (F_S .* (Shaftlength./1000).^2) ./ (16.*youngs_modulus.*1000000000.*I.*1000000);

figure(20)
plot(ymax);
title("deflection [mm]");

% N_bend = zeros(110,1);
% window_length = 0.5;                   % seconds per bucket
% dt = mean(diff(time));                    % average timestep
% bucket_size = round(window_length/dt); % points per bucket
% nBuckets = floor(length(BendingStress) / bucket_size);% Preallocate result matrix
% stress_matrix = zeros(nBuckets,2); % col1 = mean, col2 = alternating
% for i = 1:nBuckets
%     idx_start = (i-1)*bucket_size + 1;
%     idx_end   = i*bucket_size;    % Segment of stress
%     seg = BendingStress(idx_start:idx_end);    % Store values
%     stress_matrix(i,1) = mean(seg);                     % mean stress
%     stress_matrix(i,2) = (max(seg) - min(seg)) / 2;     % alternating stress
%     FOS_check = 1/ ((stress_matrix(i,2)./se)+(stress_matrix(i,1)./Sut));
%     if FOS_check < 1
%         sigma_ar = stress_matrix(i,2)/ (1-(stress_matrix(i,1)/Sut));
%         N_bend(i,1) = (sigma_ar ./ a).^(1./b); % calculate cycles till failure, but is a 'cycle' here then just 0.5 seconds? 0.045 of a autox lap?
% 
%     else
%         N_bend(i,1) = Inf;
%     end
% 
% end
% 
% 
% %n = (bucket_size/ length(time));
% n = 1;
% Miners = n  ./ N_bend(:,1);
% Miners_damage = sum(Miners); 
% Miners_FOS = 1/ Miners_damage; 
% fprintf("'cycles' to failure:")
% disp(Miners_FOS);
% FOS = 1 ./ ((stress_matrix(:,2)./se)+(stress_matrix(:,1)./Sut));


% figure(11)
% h = plot(FOS);
% title("Check for infinite life, _mm OD, _mm ID, _mm length planet shaft")
% ylabel("FOS")





%disp(Damage_bend);
%disp(Bending_LifeFOS);
%end

%math check (assume fully reversed here?)
% FOS_check = 1/ ((76.3811./se)+(802.6308./Sut));
% if FOS_check < 1
%     sigma_ar = BendingStress;
%     N_bend = (sigma_ar ./ a).^(1./b);
% else
%     N_bend = 0;
% end

%% MINERS LAW with binned histogram method (incomplete, disregard)
% ----- LOAD SPECTRUM AND LIFE REQUIREMENTS -------------------------------

% wheel_revs_life = 290000;
% sun_cycles_life = wheel_revs_life * GR * (3 / ( 1 + 1/GR));
% 
% % Torque in [Nm]
% motor_torque =  [3.5, 3.5, 3.5, 3.5, 3.5,  7,7,7,7,7, 10.5,10.5,10.5,10.5,10.5,   14,14,14,14,14,   17.5, 17.5, 17.5, 17.5, 17.5,   21,21,21,21,21];
% motor_rpm =     [3000, 6000, 9000, 12000, 15000, 3000, 6000, 9000, 12000, 15000 ,3000, 6000, 9000, 12000, 15000, 3000, 6000, 9000, 12000, 15000, 3000, 6000, 9000, 12000, 15000, 3000, 6000, 9000, 12000, 15000];
% duty =          [0.0066, 0.0703, 0.0086, 0.0012, 0.000, 0.0037, 0.0793, 0.0292, 0.0394, 0.000, 0.0037, 0.1052, 0.0201, 0.007, 0.0012, 0.0004, 0.0575, 0.0296, 0.0033, 0.0025, 0.0156, 0.0164, 0.03, 0.0173, 0.0037, 0.0008, 0.0008, 0.0016, 0.0008, 0.000];
% 

% S–N life per bin (vectorized)
%N_bend = (BendingStress ./ a).^(1./b);

% Apply endurance limit: stresses below se → infinite life
%N_bend(BendingStress <= se) = Inf;

% Number of cycles applied per bin
%n = sun_cycles_life .* duty;

% Miner’s damage
%Damage_bend = sum(n ./ N_bend, 'omitnan');
%Bending_LifeFOS = 1 ./ Damage_bend;

            % time vector
%N_bend = zeros(nBuckets, 1);