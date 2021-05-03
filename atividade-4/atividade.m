clf;
clc;

global vtChannel;
global dNoisePower;
global dSubcarrierBandwidth;
global iNumMCSs;

iNumSubcarriers = 10;
iNumMCSs = 10;
dChannelAmp = 10;
vtChannel = dChannelAmp*rand(1,iNumSubcarriers);
dTotalPower = 200;
dNoisePower = 1;
dSubcarrierBandwidth = 1;
plotPower = true;

% SNR mínimas
gama_m = 2.^(1:iNumMCSs) - 1;

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
    
    % mover mDeltaPot(:, n) para cima
    mDeltaPot(:, n) = [mDeltaPot(2:iNumMCSs, n); inf];
end

dTotalCapacityHH = sum(MCSsHH);
disp("[Hughes Hartogs] total_power: "+sum(vtPowerHH)+", Total Capacity: "+dTotalCapacityHH);

% Equal Power Allocation
vtPowerEPA = (dTotalPower/iNumSubcarriers)*ones(1, iNumSubcarriers);
[dTotalCapacityEPA, MCSsEPA] = totalCapacity(vtPowerEPA);
disp("[Equal Power Allocation] total_power: "+sum(vtPowerEPA)+", Total Capacity: "+dTotalCapacityEPA);

% Intlinprog
f = -1*ones(iNumSubcarriers, iNumMCSs);
f = f .* (1:iNumMCSs);
f = reshape(f,[],1);

intcon = 1:numel(f);

%A = ones(iNumSubcarriers, iNumMCSs);
A = mPot';
A = reshape(A, [], 1)';

b = dTotalPower;

Aeq = repmat(eye(iNumSubcarriers, iNumSubcarriers), 1, iNumMCSs);
beq = ones(iNumSubcarriers, 1);

% Restrições para igualar com o Hughes Hartogs
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
gama_m = [0, gama_m];
vtPowerILP = gama_m(MCSsILP+1).*((dNoisePower^2)./(vtChannel.^2));
disp("[Intlingprog] total_power: "+sum(vtPowerILP)+", Total Capacity: "+(-y));

if(plotPower)
    sgtitle("Power and Channel");
    s = min(1, dTotalPower/iNumSubcarriers/dChannelAmp);

    subplot(2, 2, 1);
    hold on;
    bar(vtPowerHH);
    bar(s*vtChannel);
    legend('Power', 'Channel', 'Location','southeastoutside');
    title("Hughes Hartogs");
    hold off;

    subplot(2, 2, 2);
    hold on;
    bar(vtPowerEPA);
    bar(s*vtChannel);
    legend('Power', 'Channel', 'Location','southeastoutside');
    title("Equal Power Allocation");
    hold off;

    subplot(2, 2, 3);
    hold on;
    bar(vtPowerILP);
    bar(s*vtChannel);
    legend('Power', 'Channel', 'Location','southeastoutside');
    title("Intlingprog");
    hold off;

    a = subplot(2, 2, 4);
    text(0, 1, "[Hughes Hartogs]", 'FontSize', 14, "Interpreter", "none");
    text(0, 0.9, "total_power: "+sum(vtPowerHH)+", total_capacity: "+dTotalCapacityHH, 'FontSize', 14, "Interpreter", "none");
    text(0, 0.8, "[Equal Power Allocation]", 'FontSize', 14, "Interpreter", "none");
    text(0, 0.7, "total_power: "+sum(vtPowerEPA)+", total_capacity: "+dTotalCapacityEPA, 'FontSize', 14, "Interpreter", "none");
    text(0, 0.6, "[Intlinprog]", 'FontSize', 14, "Interpreter", "none");
    text(0, 0.5, "total_power: "+sum(vtPowerILP)+", total_capacity: "+(-y), 'FontSize', 14, "Interpreter", "none");
    set(a, 'visible', 'off');
else
    sgtitle("MCS and Channel");
    s = min(1, iNumMCSs/dChannelAmp/2);

    subplot(2, 2, 1);
    hold on;
    bar(MCSsHH);
    bar(s*vtChannel);
    legend('MCS', 'Channel', 'Location','southeastoutside');
    title("Hughes Hartogs");
    hold off;

    subplot(2, 2, 2);
    hold on;
    bar(MCSsEPA);
    bar(s*vtChannel);
    legend('MCS', 'Channel', 'Location','southeastoutside');
    title("Equal Power Allocation");
    hold off;

    subplot(2, 2, 3);
    hold on;
    bar(MCSsILP);
    bar(s*vtChannel);
    legend('MCS', 'Channel', 'Location','southeastoutside');
    title("Intlingprog");
    hold off;

    a = subplot(2, 2, 4);
    text(0, 1, "[Hughes Hartogs]", 'FontSize', 14, "Interpreter", "none");
    text(0, 0.9, "total_power: "+sum(vtPowerHH)+", total_capacity: "+dTotalCapacityHH, 'FontSize', 14, "Interpreter", "none");
    text(0, 0.8, "[Equal Power Allocation]", 'FontSize', 14, "Interpreter", "none");
    text(0, 0.7, "total_power: "+sum(vtPowerEPA)+", total_capacity: "+dTotalCapacityEPA, 'FontSize', 14, "Interpreter", "none");
    text(0, 0.6, "[Intlinprog]", 'FontSize', 14, "Interpreter", "none");
    text(0, 0.5, "total_power: "+sum(vtPowerILP)+", total_capacity: "+(-y), 'FontSize', 14, "Interpreter", "none");
    set(a, 'visible', 'off');
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