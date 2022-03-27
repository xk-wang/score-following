function [intCQT] = computeCQT(filename)
% Settings for computing CQT for music signals (by E. Benetos)

% Load .wav file
[x fs bits] = wavread(filename);
if (size(x,2) == 2) y = mean(x')'; else y=x; end;
if (fs ~= 44100) y = resample(y,44100,fs); end;
fs = 44100;


% Compute CQT
Xcqt = cqt(y,27.5,fs/3,120,fs,'q',0.35,'atomHopFactor',0.3,'thresh',0.0005,'win','hann');
%Xcqt = cqtPerfectRast(x,27.5,fs/3,120,fs,'q',0.35,'atomHopFactor',0.1,'thresh',0.0005,'win','hann');
absCQT = getCQT(Xcqt,'all','all');

% Crop CQT to useful time regions
emptyHops = Xcqt.intParams.firstcenter/Xcqt.intParams.atomHOP;
maxDrop = emptyHops*2^(Xcqt.octaveNr-1)-emptyHops;
droppedSamples = (maxDrop-1)*Xcqt.intParams.atomHOP + Xcqt.intParams.firstcenter;
outputTimeVec = (1:size(absCQT,2))*Xcqt.intParams.atomHOP-Xcqt.intParams.preZeros+droppedSamples;

lowerLim = find(outputTimeVec>0,1);
upperLim = find(outputTimeVec>length(y),1)-1;

intCQT = absCQT(112:1200,lowerLim:upperLim);


%figure; imagesc(imrotate(abs(intCQT),90));
