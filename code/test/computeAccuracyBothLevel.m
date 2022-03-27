function [resultFrameLevel,resultNoteLevel] = computeAccuracyBothLevel(h,pianoRollGt,midiGt,onsetTolerance,timeResolution,varargin)
% computeAccuracyBothLevel ����resultFrameLevel��resultNoteLevel
%
% [resultFrameLevel,resultNoteLevel] = computeAccuracyBothLevel(h,pianoRollGt,midiGt,onsetTolerance,timeResolution,varargin)
%
% Inputs:
%  h                pitch activation��cell(1,��Ƶ��)��cell��һ�ж�Ӧһ��������һ�ж�Ӧһ֡��
%  pianoRollGt      ground truth��cell(1,��Ƶ��)��cell��һ�ж�Ӧһ��������һ�ж�Ӧһ֡��
%  midiGt           ground truth��cell(��Ƶ��,1)��cell�ڣ�3�У�������� - onset(s) - offset(s)��
%  onsetTolerance   computeAccuracyNoteLevel����
%  timeResolution   h���������е�ʱ��s��
%  varargin         postProcessing����������ҪpianoRollGt��
%
% computeAccuracy��������������Ӱ�����еļ���

nWav = size(h,2);
resultNoteLevelPerWav = table;
resultFrameLevelPerWav = table;
for iWav = 1:nWav
    [pianoRoll,midi] = postProcessing(h{iWav},'pianoRollGt',pianoRollGt{iWav},varargin{:});
    if timeResolution~=0.01
        pianoRoll = formatPianoRoll001(pianoRoll,timeResolution);
    end
    resultNoteLevel = computeAccuracyNoteLevel(midi,midiGt{iWav},onsetTolerance,0); %�Ƿ���Ա�Ƶ��������postProcessing�д����˴������Ա�Ƶ����
    resultFrameLevel = computeAccuracyFrameLevel(pianoRoll,pianoRollGt{iWav},0);
    resultNoteLevelPerWav = [resultNoteLevelPerWav;resultNoteLevel];
    resultFrameLevelPerWav = [resultFrameLevelPerWav;resultFrameLevel];
end

if nWav == 1
    resultFrameLevel = resultFrameLevelPerWav;
    resultNoteLevel = resultFrameLevelPerWav;
else
    resultNoteLevel = computeAccuracyAll(resultNoteLevelPerWav);
    resultFrameLevel = computeAccuracyAll(resultFrameLevelPerWav);
end
end

function result = computeAccuracyAll(resultPerWav)
result = table;
result.nRref = sum(resultPerWav.nRref);
result.nTot = sum(resultPerWav.nTot);
result.nCorr = sum(resultPerWav.nCorr);
metrics = computeAccuracy(result.nRref,result.nTot,result.nCorr);
result = [result,metrics];
result = [resultPerWav;result];
end