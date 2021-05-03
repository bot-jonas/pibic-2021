clf;
clc;

global vtChannel;
global dNoisePower;
global dSubcarrierBandwidth;
global iNumMCSs;

iNumSubcarriers = 10;
iNumMCSs = 10;
dChannelAmp = 10;
%vtChannel = dChannelAmp*rand(1,iNumSubcarriers);
dTotalPower = 200;
dNoisePower = 1;
dSubcarrierBandwidth = 1;

gama_m = 2.^(1:iNumMCSs) - 1;

iNumExp = 100;
mtTotalCapacity = zeros(iNumExp, 3);

flag = false;

for iter=1:iNumExp
    vtChannel = dChannelAmp*rand(1,iNumSubcarriers);
    % Hughes Hartogs
    mPot = gama_m' * ((dNoisePower^2)./(vtChannel.^2));

    % Cálculo de deltaPot
    mPotAux = [zeros(1, iNumSubcarriers); mPot(1:iNumMCSs-1,:)];
    mDeltaPot = mPot-mPotAux;

    MCSsHH = zeros(1, iNumSubcarriers);
    vtPowerHH = zeros(1, iNumSubcarriers);

    while((sum(vtPowerHH) < dTotalPower) && (sum(MCSsHH) ~= iNumSubcarriers*iNumMCSs))
        [m, n] = min(mDeltaPot(1,:));

        % Garantir que a potência usada não ultrapasse a potência máxima
        if(sum(vtPowerHH)-vtPowerHH(n)+mPot(MCSsHH(n)+1, n) > dTotalPower)
            break;
        end

        MCSsHH(n) = MCSsHH(n)+1;
        vtPowerHH(n) = mPot(MCSsHH(n), n);

        % move up mDeltaPot(:, n)
        mDeltaPot(:, n) = [mDeltaPot(2:iNumMCSs, n); inf];
    end

    dTotalCapacityHH = sum(MCSsHH);

    % Equal Power Allocation
    vtPowerEPA = (dTotalPower/iNumSubcarriers)*ones(1, iNumSubcarriers);
    [dTotalCapacityEPA, MCSsEPA] = totalCapacity(vtPowerEPA);

    % Intlinprog
    f = -1*ones(iNumSubcarriers, iNumMCSs);
    f = f .* (1:iNumMCSs);
    f = reshape(f,[],1);

    intcon = 1:numel(f);

    A = ones(iNumSubcarriers, iNumMCSs);
    A = A .* mPot';
    A = reshape(A, [], 1)';

    b = dTotalPower;

    Aeq = repmat(eye(iNumSubcarriers, iNumSubcarriers), 1, iNumMCSs);
    beq = ones(iNumSubcarriers, 1);

    % Restrições corretas
    A = [A; Aeq];
    b = [b; beq];

    Aeq = [];
    beq = [];
    % end

    lb = zeros(iNumMCSs*iNumSubcarriers, 1);
    ub = ones(iNumMCSs*iNumSubcarriers, 1);

    x0 = [];
    options = optimoptions(@intlinprog, 'Display', 'Off');

    [x, y] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub,x0,options);
    x = reshape(x, iNumSubcarriers, []);

    MCSsILP = round(sum(x .* (1:iNumMCSs), 2)');
    u = [0, gama_m];
    vtPowerIL = u(MCSsILP+1).*((dNoisePower^2)./(vtChannel.^2));
    
    mtTotalCapacity(iter, :) = [dTotalCapacityHH dTotalCapacityEPA -y];
    disp(iter+"/"+iNumExp);
    
    if(sum(vtPowerHH) > sum(vtPowerIL))
        disp("total_power_HH > total_power_IL");
        flag = true;
    end
end

solutions = ["HH [Hughes Hartogs]", "EPA [Equal Power Allocation]", "IL [Intlingprog]"];

hold on
for iter=1:3
    [h, s] = cdfplot(mtTotalCapacity(:, iter));
    disp("Status of "+solutions(iter));
    disp(s);
end
title("CDF of Solutions' total capacities");
legend('HH', 'EPA', 'IL');
hold off

if(flag)
    disp("total_power_HH > total_power_IL");
end

function t = iDataRateFromSNR(SNR)
    global iNumMCSs;
    %0<=SNR<1             Taxa = 0
    %1<=SNR<3             Taxa = 1
    %3<=SNR<7             Taxa = 2
    %7<=SNR<15            Taxa = 3
    %15<=SNR<31           Taxa = 4
    %31<=SNR<63           Taxa = 5
    %63<=SNR<127          Taxa = 6
    %127<=SNR<255         Taxa = 7
    %255<=SNR<511         Taxa = 8
    %511<=SNR<1023        Taxa = 9
    %SNR>=1023            Taxa = 10
    t = min(floor(log2(1+SNR)), iNumMCSs);
end

function [dTotal, vtCapacities] = totalCapacity(vtPower)
    global dSubcarrierBandwidth;
    global vtChannel;
    global dNoisePower;
    
    SNR = vtPower.*(vtChannel.^2)/(dNoisePower^2);
    
    vtCapacities = dSubcarrierBandwidth*iDataRateFromSNR(SNR);
    dTotal = sum(vtCapacities);
end