clf
clc

iNumBS = 4; % Number of base stations
dBSRadius = 500; % Distance between adjacent BS in m
% Vector of BSs' positions
vtBSPos = [0 dBSRadius * exp(1i*[0 2*pi/3 -2*pi/3])];
% Vector of TMs' positions 
vtTMPos = zeros(iNumBS);
iNumIt = 5000; % Number of iterations
iNumTM = 4; % Number of TMs
% Matrix of SINR results
mtSINRRes = zeros(iNumIt, iNumBS);

dTransPower = dbm2lin(43); % Transmission power
dNoisePower = dbm2lin(-116); % Noise power

for iter=1:iNumIt
	for i=1:iNumBS
        dAngle  = 2*pi*rand();
        dRadius = dBSRadius*sqrt(rand()); % meter

        vtTMPos(i) = vtBSPos(i)+dRadius*exp(1i*dAngle);
    end

    mtGPathLoss = zeros(iNumBS, iNumTM); % Matrix of path loss gains
    mtGShadowing = zeros(iNumBS, iNumTM); % Matrix of shadowing gains
    mtGFastFading = zeros(iNumBS, iNumTM); % Matrix of fast fading gains
    mtRecPower = zeros(iNumBS, iNumTM); % Matrix of received power
    
    for i=1:iNumBS
        for j=1:iNumTM
            % Distance between BS i and TM j in kilometers
            dDis = abs(vtBSPos(i)-vtTMPos(j))/1000;
            % Path loss in dB
            dPathLoss = 128.1 + 36.7*log10(dDis);
            % Fast fading in linear scale
            dFastFading = abs((randn() + 1i*randn())/sqrt(2))^2;

            mtGPathLoss(i, j) = db2lin(-dPathLoss);
            mtGShadowing(i, j) = db2lin(8*randn());
            mtGFastFading(i, j) = dFastFading;

            mtRecPower(i, j) = dTransPower*mtGPathLoss(i, j)*mtGShadowing(i, j)*mtGFastFading(i, j);
        end
    end

    % Vector of SINR values from this iteration
    vtSINR = zeros(1, iNumBS);

    for i=1:iNumBS
       vtSINR(i) = lin2db(mtRecPower(i,i)/(dNoisePower + sum(mtRecPower(:, i))-mtRecPower(i,i)));
    end
    
    mtSINRRes(iter, :) = vtSINR;
end

hold on
for i=1:iNumBS
    [h, s] = cdfplot(mtSINRRes(:, i));
    disp("Status of BS"+i);
    disp(s);
end
hold off

function [y] = db2lin(x)
y = 10.^(x./10);
end

function [y] = dbm2lin(x)
    y = 10.^(x./10 - 3);
end

function [y] = lin2db(x)
    y = 10*log10(x);
end