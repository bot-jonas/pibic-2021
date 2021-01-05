clf
clc

iNumBS = 4; % Number of base stations
dBSRadius = 500; % Distance between adjacent BS in m
% Vector of BSs' positions
vtBSPos = [0 dBSRadius * exp(1i*[0 2*pi/3 -2*pi/3])];
% Vector of TMs' positions 
vtTMPos = zeros(iNumBS);
iNumIt = 5000; % Number of iterations
% Matrix of SINR results
mtSINRRes = zeros(iNumIt, iNumBS);

colors = ["k", "r", "g", "b"];

for i=1:iNumBS
    circle(vtBSPos(i), dBSRadius, colors(i));
end

%rng('default')  % For reproducibility
dPTr = dbm2lin(43); % potencia de transmissao constante [watts]
  dPNoise = dbm2lin(-116); % potencia de ruido [linear]
for iter=1:iNumIt
	for i=1:iNumBS
        dAngle  = 2*pi*rand();
        dRadius = dBSRadius*sqrt(rand()); % meter
        %dRadius = dBSRadius*rand(); % meter

        vtTMPos(i) = vtBSPos(i)+dRadius*exp(1i*dAngle); % meter

        %hold on
        %scatter(real(vtTMPos(i)), imag(vtTMPos(i)), colors(i)+"+");
        %hold off
	end
    
    %teste(iter) = dRadius;

    iNumTM = size(vtTMPos, 2);

    mtGPerMed = zeros(iNumBS, iNumTM); % ganhos de percurso medio
    mtGSom = zeros(iNumBS, iNumTM); % ganhos de sombreamento
    mtGDesRap = zeros(iNumBS, iNumTM); % ganhos de desvanecimento

    mtPRec = zeros(iNumBS, iNumTM); % potencias recebidas
    

    for i=1:iNumBS
        for j=1:iNumTM
            dDis = abs(vtBSPos(i)-vtTMPos(j))/1000; % kilometer
            dPl = 128.1 + 36.7*log10(dDis);
            dH = abs((randn() + 1i*randn())/sqrt(2));

            mtGPerMed(i, j) = db2lin(-dPl);
            mtGSom(i, j) = db2lin(8*randn());
            mtGDesRap(i, j) = dH*dH;

            mtPRec(i, j) = dPTr*mtGPerMed(i, j)*mtGSom(i, j)*mtGDesRap(i, j);
        end
    end

    vtSINR = zeros(1, iNumBS); % vetor para armazenar as SINR
  

    for i=1:iNumBS
       vtSINR(i) = lin2db(mtPRec(i,i)/(dPNoise + sum(mtPRec(:, i))-mtPRec(i,i)));
    end
    
    mtSINRRes(iter, :) = vtSINR;
end

axis equal

%histogram(mtAux(:, 1)', 20);
hold on
cdfplot(mtSINRRes(:, 1)');
cdfplot(mtSINRRes(:, 2)');
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

function h = circle(pos, r, color)
    hold on

    t = 0:pi/50:2*pi;
    x_ = real(pos)+r*cos(t);
    y_ = imag(pos)+r*sin(t);
    
    scatter(real(pos), imag(pos), color);

    h = plot(x_, y_, color);
    
    hold off
end