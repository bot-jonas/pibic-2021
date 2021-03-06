clf;
clc;

global vtChannel;
global dNoisePower;
global dSubcarrierBandwidth;

iNumSubcarriers = 100;
dChannelAmp=10;
dTotalPower = 200; % Watts
dNoisePower = 1; % Watts
dSubcarrierBandwidth = 1; % Hertz

% Optional parameters
Aeq = []; beq = []; lb = []; ub = []; nonlcon = [];
% Options to set MaxFunEvals
iMaxNumIterations = 1e3;
options = optimoptions(@fmincon,'MaxFunEvals',iMaxNumIterations,'Display','off');

iNumExp = 10000;
mtTotalCapacity = zeros(iNumExp, 3);

for iter=1:iNumExp
    vtChannel = dChannelAmp*rand(1, iNumSubcarriers);
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

    % Equal power solution
    vtPowerEPS = (dTotalPower/iNumSubcarriers)*ones(1, iNumSubcarriers);
    dTotalCapacityEPS = totalCapacity(vtPowerEPS);

    % Matlab fmincon solution
    fun = @(x) -totalCapacity(x);
    x0 = vtPowerEPS;
    A = [ones(1, iNumSubcarriers); -eye(iNumSubcarriers)];
    b = [dTotalPower; zeros(iNumSubcarriers, 1)];

    vtPowerMFS = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    dTotalCapacityMFS = totalCapacity(vtPowerMFS);
    
    mtTotalCapacity(iter, :) = [dTotalCapacityWPS dTotalCapacityEPS dTotalCapacityMFS];
    disp(iter+"/"+iNumExp);

    if(max(sum([vtPowerWPS; vtPowerEPS; vtPowerMFS], 2)) - dTotalPower > 1e-10)
        disp("leaked power");
        break;
    end
end

solutions = ["WPS [Water Pouring Solution]", "EPS [Equal Power Solution]", "MFS [Matlab Fmincon Solution]"];

hold on
for i=1:3
    [h, s] = cdfplot(mtTotalCapacity(:, i));
    disp("Status of "+solutions(i));
    disp(s);
end
title("CDF of Solutions' total capacities")
legend('WPS', 'EPS', 'MFS')
hold off
    
function [dTotal, vtCapacities] = totalCapacity(vtPower)
    global dSubcarrierBandwidth;
    global vtChannel;
    global dNoisePower;
    
    vtCapacities = dSubcarrierBandwidth*log2(1 + vtPower.*(vtChannel.^2)/(dNoisePower^2));
    dTotal = sum(vtCapacities);
end