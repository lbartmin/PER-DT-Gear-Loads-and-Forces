

planetshaftloadspectra = BendingStress_signed;
plot(planetshaftloadspectra);
rainflothreshold = 600; % adjust based on stress magnitude fluctuations
[turningptsg,indg] = findTurningPts(planetshaftloadspectra,rainflothreshold); % define cycle as a segment of brake + throttle

plotStressAndTurningPts(time,planetshaftloadspectra,indg,turningptsg,0,56);

figure(18)
rfCountg = rainflow(turningptsg,time(indg),"ext");
rainflow(turningptsg,time(indg),"ext");
%rainflow(planetshaftloadspectra);
% [c,rm,rmr,rmm,idx]  = rainflow(planetshaftloadspectra,time);
% rainflow(planetshaftloadspectra,time);
% TT = array2table(c,VariableNames=["Count" "Range" "Mean" "Start" "End"]);
% disp(TT);

shaftstress_matrix = zeros(length(rfCountg(:,2)),2);
shaftstress_matrix(:,1) = abs(rfCountg(:,3));                     % mean stress
    shaftstress_matrix(:,2) = rfCountg(:,2) ./ 2;     % alternating stress
    infLifeFOS = 1./((shaftstress_matrix(:,2)./se)+(shaftstress_matrix(:,1)./Sut));

figure(15)
h9 = plot( infLifeFOS);
title("FOS for infinite life")
CyclesN = zeros(length(infLifeFOS),1);
for i = 1:length(infLifeFOS)
    if infLifeFOS(i) < 1 % Calculate damage if infinite life FOS under 1
        modGoodman_stress = shaftstress_matrix(i,2)/ (1-(shaftstress_matrix(i,1)/Sut)); 
        CyclesN(i,1) = (modGoodman_stress ./ a).^(1./b); % calculate cycles to failure

    else
        CyclesN(i,1) = 0;
    
    end
end
n = 1;
N_Laps = 455; % based on defined vehicle lifetime
MinersLawpercycle = n  ./ CyclesN(:,1);
MinersLawpercycle = MinersLawpercycle(isfinite(MinersLawpercycle));
Miners_damage_sum = sum(MinersLawpercycle)*N_Laps; 
Miners_FOS = 1./ Miners_damage_sum; 

disp(Miners_FOS);

%fprintf("'cycles' to failure:")

disp(Miners_damage_sum);


function [tp,ind] = findTurningPts(x,threshold)
% FINDTURNINGPTS finds turning points in signal x
%
% Reference:
% I. Rychlik, "Simulation of load sequences from rainflow matrices: Markov
% method", Int. J. Fatigue, vol. 18, no. 7m, pp. 429-438, 1996.
%
%   Copyright 2022 The MathWorks, Inc.

xLen = length(x);

% Find minimum/maximum
[~,~,zcm] = zerocrossrate(diff(x),Method="comparison",Threshold=0);
index = (1:xLen)';
zci = index(zcm);

% Make sure that there are at least two crossing points
if (length(zci) < 2)
    tp = [];
    return;
end

% Add end points
if (x(zci(1)) > x(zci(2)))
    ind = [1;zci;xLen];
else
    ind = [zci;xLen];
end

% Apply hysteresis and peak-valley filtering (a.k.a. rainflow filtering)
pvInd = hpvfilter(x(ind),threshold);
ind = ind(pvInd);

% Extract turning points
tp = x(ind);
end

function index = hpvfilter(x,h)
% HPVFILTER performs hysteresis and peak-valley filtering

% Initialization
index = [];
tStart = 1;

% Ignore the first maximum
if (x(1) > x(2))
  x(1) = [];
  tStart = 2;
end

Ntp = length(x);
Nc = floor(Ntp/2);
% Make sure that there is at least one cycle
if (Nc < 1)
    return
end

% Make sure the input sequence is a sequence of turning points
dtp = diff(x);
if any(dtp(1:end-1).*dtp(2:end) >= 0)
    error('Not a sequence of turning points.')
end

% Loop over elements of sequence
count = 0;
index = zeros(size(x));
for i = 0:Nc-2
    tiMinus = tStart+2*i;
    tiPlus = tStart+2*i+2;
    miMinus = x(2*i+1);
    miPlus = x(2*i+2+1);

    if (i ~= 0)
        j = i-1;
        while ((j >= 0) && (x(2*j+2) <= x(2*i+2)))
            if (x(2*j+1) < miMinus)
                miMinus = x(2*j+1);
                tiMinus = tStart+2*j;
            end
            j = j-1;
        end
    end
  
    if (miMinus >= miPlus)
        if (x(2*i+2) >= h+miMinus)
            count = count+1;
            index(count) = tiMinus;
            count = count+1;
            index(count) = tStart+2*i+1;
        end
    else
        j = i+1;
        tfFlag = false;
        while (j < Nc-1)
            tfFlag = (x(2*j+2) >= x(2*i+2));
            if tfFlag
                break
            end
            if (x(2*j+2+1) <= miPlus)
                miPlus = x(2*j+2+1);
                tiPlus = tStart+2*j+2;
            end
            j = j+1;
        end
        if tfFlag
            if (miPlus <= miMinus)
                if (x(2*i+2) >= h+miMinus)
                    count = count+1;
                    index(count) = tiMinus;
                    count = count+1;
                    index(count) = tStart+2*i+1;
                end
            elseif (x(2*i+2) >= h+miPlus)
                count = count+1;
                index(count) = tStart+2*i+1;
                count = count+1;
                index(count) = tiPlus;
            end
        elseif (x(2*i+2) >= h+miMinus)
            count = count+1;
            index(count) = tiMinus;
            count = count+1;
            index(count) = tStart+2*i+1;
        end
    end
end
index = sort(index(1:count));
end

function plotStressAndTurningPts(t,s,ind,turningpts,ts,te)
ind1 = (t >= ts) & (t <= te);
ttpts = t(ind); % time stamps of turning points
ind2 = (ttpts >= ts) & (ttpts <= te);

figure(12)
plot(t(ind1),s(ind1))
hold on
plot(ttpts(ind2),turningpts(ind2),"-*","MarkerSize",8)
hold off
xlabel("Time (sec)")
ylabel("Stress [mpa]")
xlim([ts,te])
legend(["Stress history","Hysteresis & P-V filtering output"])
grid("minor")
end