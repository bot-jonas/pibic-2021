clf;
clc;

global vtChannel;
global dNoisePower;
global dSubcarrierBandwidth;

iNumSubcarriers = 100;
t=10;
vtChannel = t*rand(1, iNumSubcarriers);
%vtChannel = [1e-9 ones(1, 5) 1e-9 ones(1, 13)];
dTotalPower = 200; % Watts
dNoisePower = 1; % Watts
dSubcarrierBandwidth = 1; % Hertz

disp("[Non Negative Constraint]");

% Water pouring solution (TKN_Report_06_001.pdf - Ch. 3.1)
vtNotZeroPower = ones(1, iNumSubcarriers);
flag = true;
while flag
    dAux = (sum(vtNotZeroPower.*(dNoisePower^2)./(vtChannel.^2)) + dTotalPower)/sum(vtNotZeroPower);
    vtPowerWPS = vtNotZeroPower.*(dAux - (dNoisePower^2)./(vtChannel.^2));
    
    if min(vtPowerWPS) >= 0
        flag = false;
    else
        vtIndicesNegativeValues = find(vtPowerWPS<0);
        vtNotZeroPower(vtIndicesNegativeValues) = 0;
    end
end

dTotalCapacityWPS = totalCapacity(vtPowerWPS);
disp("[Water Pouring Solution] total_power: "+sum(vtPowerWPS)+", min_power: "+min(vtPowerWPS));
disp(" - Zero Power Indices");
disp(find(vtPowerWPS==0));

% Equal power solution
vtPowerEPS = (dTotalPower/iNumSubcarriers)*ones(1, iNumSubcarriers);
dTotalCapacityEPS = totalCapacity(vtPowerEPS);
disp("[Equal Power Solution] total_power: "+sum(vtPowerEPS));

% Matlab fmincon solution
fun = @(x) -totalCapacity(x);
x0 = vtPowerEPS;
A = [ones(1, iNumSubcarriers); -eye(iNumSubcarriers)];
b = [dTotalPower; zeros(iNumSubcarriers, 1)];
% Optional parameters
Aeq = []; beq = []; lb = []; ub = []; nonlcon = [];
% Options to set MaxFunEvals
iMaxNumIterations = 1e5;
options = optimoptions(@fmincon,'MaxFunEvals',iMaxNumIterations,'Display','off');

vtPowerMFS = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
dTotalCapacityMFS = totalCapacity(vtPowerMFS);
disp("[Matlab Fmincon Solution] total_power: "+sum(vtPowerMFS)+", min_power: "+min(vtPowerMFS));

figure(1);
sgtitle("Non Negative Constraint");

s = min(1, dTotalPower/iNumSubcarriers/t);

subplot(2, 2, 1);
hold on;
bar(vtPowerWPS);
bar(s*vtChannel);
legend('Power', 'Channel', 'Location','southeastoutside');
title("Water Pouring Solution");
hold off;

subplot(2, 2, 2);
hold on;
bar(vtPowerEPS);
bar(s*vtChannel);
legend('Power', 'Channel', 'Location','southeastoutside');
title("Equal Power Solution");
hold off;

subplot(2, 2, 3);
hold on;
bar(vtPowerMFS);
bar(s*vtChannel);
legend('Power', 'Channel', 'Location','southeastoutside');
title("Matlab Fmincon Solution (max_iter="+iMaxNumIterations+")", "Interpreter", "none");
hold off;

a = subplot(2, 2, 4);
text(0, 1, "[Water Pouring Solution]", 'FontSize', 14, "Interpreter", "none");
text(0, 0.9, "total_power: "+sum(vtPowerWPS)+", min_power: "+min(vtPowerWPS)+", total_capacity: "+dTotalCapacityWPS, 'FontSize', 14, "Interpreter", "none");
text(0, 0.8, "[Equal Power Solution]", 'FontSize', 14, "Interpreter", "none");
text(0, 0.7, "total_power: "+sum(vtPowerEPS)+", total_capacity: "+dTotalCapacityEPS, 'FontSize', 14, "Interpreter", "none");
text(0, 0.6, "[Matlab Fmincon Solution]", 'FontSize', 14, "Interpreter", "none");
text(0, 0.5, "total_power: "+sum(vtPowerMFS)+", min_power: "+min(vtPowerMFS)+", total_capacity: "+dTotalCapacityMFS, 'FontSize', 14, "Interpreter", "none");
set(a, 'visible', 'off');

function [dTotal, vtCapacities] = totalCapacity(vtPower)
    global dSubcarrierBandwidth;
    global vtChannel;
    global dNoisePower;
    
    vtCapacities = dSubcarrierBandwidth*log2(1 + vtPower.*(vtChannel.^2)/(dNoisePower^2));
    dTotal = sum(vtCapacities);
end