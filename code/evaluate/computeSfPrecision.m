function [result,sfResult] = computeSfPrecision(sfResult,sfResultGt,functionHandle,varargin)
% [result,sfResult] = computeSfPrecision(sfResult,sfResultGt,'@computePrecisionNoteLevel');
% result = computeSfPrecision(sfResult,sfResultGt,'computePrecisionFrameLevel',nFrame,0.01,0.1);

nFile = size(sfResult,1);
resultPerFile = table;
for iFile = 1:nFile
    if strcmp(functionHandle,'@computePrecisionNoteLevel')
        [thisResult,sfResult{iFile,3}] = computePrecisionNoteLevel(sfResult{iFile,3},sfResultGt{iFile,2});
    else
        [nFrame,timeResolution,onsetTolerance] = deal(varargin{:});
        thisResult = computePrecisionFrameLevel(sfResult{iFile,2},sfResultGt{iFile,2},nFrame(iFile),timeResolution,onsetTolerance);
    end
    resultPerFile = [resultPerFile;thisResult];
end
resultAll = table;
resultAll.nRef = sum(resultPerFile.nRef);
resultAll.nCorr = sum(resultPerFile.nCorr);
resultAll.precision = resultAll.nCorr/resultAll.nRef;
result = [resultPerFile;resultAll];
end

function sfResultGt = computeGt()
%% ����sfResultGt
nFile = 12; %�����ļ���
sfResultGt = cell(nFile,2); %�ļ��� - sfResultGt

for iFile = 1:nFile
    nEvent = input('������nEvent');
    sfResultGt{iFile,2}(nEvent,2) = cell(1);
    disp('��excel����sfResultGt');
    keyboard;
    for iEvent = 1:nEvent
        sfResultGt{iFile,2}{iEvent,1} = min(sfResultGt{iFile,2}{iEvent,1});
    end
end

%% ����nFrame
wavs = dir('performanceWav/*.wav');
nWav = length(wavs);
nFrame = zeros(nWav,1);
for iWav = 1:nWav
    thisAudioinfo = audioinfo(['performanceWav\',wavs(iWav).name]);
    nFrame(iWav) = floor(thisAudioinfo.Duration/timeResolution)+1;
end
end