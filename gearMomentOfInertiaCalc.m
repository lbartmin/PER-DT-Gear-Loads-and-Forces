

% This is a program to show the impact that weight reduction holes have 
% on the mass and moment of inertia of planet gears.

%this doesn't take into account the MOI of the planet shafts, sun gear, sun
%gear plug, needle bearings, or any spacers/washers. In reality, they
%contribute so little (apart from the planet shafts) that it can be
% ignored for the time being

% Assumptions:
% - Material is 8620 HR
% - Single-stage planetary gearbox
% - Fixed ring gear

%-=-=-=-GEAR RADIUSES-=-=-=

%R0Prompt = "What is planet shaft hole radius? (mm) ";
R0 =9/2; %planet shaft hole radius

%R1Prompt = "What is the large planet pitch diameter? (mm) ";
R1 = 46.8/2; %large planet radius

R2Prompt = "What is the radius of the hole(s) you want to make? (mm) ";
R2 = input(R2Prompt);

R3Prompt = "How far is the center of the hole you want to make from the center of the gear? (mm) ";
R3 = input(R3Prompt);

%R4Prompt = "What is the small planet pitch diameter? (mm) ";
R4 = 18/2; %small planet radius

%sunGearPrompt = "What is sun gear pitch diameter? (mm) ";
sunRadius = 18.9/2;
centerDist = R1 + sunRadius;

%-=-=-=-GEAR THICKNESSES-=-=-=

SPthickness = 27.1; %small planet face width
LPthickness = 12; %large planet face width
sunThickness = 14.75; %sun gear face width

numHolesPrompt = "How many holes do you want to have? ";
numHoles = input(numHolesPrompt);

numPlanets = 3;

% === Gear Inertia Without Holes ===

density = 0.00785; %g/mm^3, found online at AZO materials

%VOLUME CALCULATIONS
SPVolume= SPthickness * pi * (R4^2 - R0^2); %calculates one small planet's volume
LPVolume = LPthickness * pi * (R1^2 - R4^2); %calculates one large planet's volume
gearVolume = SPVolume + LPVolume;

%MASS CALCULATIONS
SPmass = density * SPVolume;
LPmass = density * LPVolume;
gearMass = density * gearVolume;

%MOMENT OF INERTIA CALCULATIONS (calc is short for calculation)
Ix = 0.5 * SPmass * (R4^2 + R0^2); % Moment of inertia of small planet about its center
Iz= 0.5 * LPmass * (R4^2 + R1^2); % Moment of inertia of large planet about its center

% === Subtract Inertia of Holes ===
holeVolume = LPthickness * pi * R2^2;
holeMass = density * holeVolume;
Iy = numHoles * (0.5 * holeMass * R2^2 + holeMass * R3^2); %calculates MOI of all holes about the planet shaft center as if they were solid
% 0.5 * m * r^2 (own inertia) + m * d^2 (parallel axis)

% === Net Inertia about Planet Shaft Center ===
I1 = Ix + Iz - Iy;

% === Use Parallel Axis Theorem to Move Inertia to Gearbox Center ===
netGearMass = gearMass - numHoles * holeMass;
I2 = numPlanets * (I1 + netGearMass * centerDist^2); %parallel axis theorem for all planets

% === Baseline Inertia and Mass without Holes ===
I2_baseline = numPlanets * ((Ix + Iz) + gearMass * centerDist^2);
mass_baseline = numPlanets * gearMass;
mass_actual = numPlanets * netGearMass;

% === Output Results ===
fprintf("Total gear inertia about gearbox axis (I2): %.2f g*mm^2\n", I2);
I2_SI = I2 * 1e-9;  % g·mm² to kg·m²
fprintf("Total gear inertia about gearbox axis (I2): %.6e kg·m²\n", I2_SI);

% === Output Mass and Inertia Savings ===
mass_saved = mass_baseline - mass_actual;
inertia_saved = I2_baseline - I2;

fprintf("\nMass saved by adding holes per gearbox: %.2f g\n", mass_saved);
fprintf("\nInertia saved by adding holes per gearbox: %.2f g*mm^2\n", inertia_saved);

totalMassSaved = mass_saved * 4 / 1000; %mass saved over 4 gearboxes in kg
fprintf("\nMass saved over entire car: %.3f kg\n", totalMassSaved);
