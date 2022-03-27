function [resultFrameLevel,resultNoteLevel] = computeAccuracyBothLevel(h,pianoRollGt,midiGt,onsetTolerance,timeResolution,varargin)
% computeAccuracyBothLevel 计算resultFrameLevel、resultNoteLevel
%
% [resultFrameLevel,resultNoteLevel] = computeAccuracyBothLevel(h,pianoRollGt,midiGt,onsetTolerance,timeResolution,varargin)
%
% Inputs:
%  h                pitch activation（cell(1,音频数)，cell内一行对应一个音符，一列对应一帧）
%  pianoRollGt      ground truth（cell(1,音频数)，cell内一行对应一个音符，一列对应一帧）
%  midiGt           ground truth（cell(音频数,1)，cell内，3列（音符序号 - onset(s) - offset(s)）
%  onsetTolerance   computeAccuracyNoteLevel参数
%  timeResolution   h中连续两列的时间差（s）
%  varargin         postProcessing参数（不需要pianoRollGt）
%
% computeAccuracy参数的数据类型影响其中的计算

nWav = size(h,2);
resultNoteLevelPerWav = table;
resultFrameLevelPerWav = table;
for iWav = 1:nWav
    [pianoRoll,midi] = postProcessing(h{iWav},'pianoRollGt',pianoRollGt{iWav},varargin{:});
    if timeResolution~=0.01
        pianoRoll = formatPianoRoll001(pianoRoll,timeResolution);
    end
    resultNoteLevel = computeAccuracyNoteLevel(midi,midiGt{iWav},onsetTolerance,0); %是否忽略倍频错误已在postProcessing中处理，此处不忽略倍频错误
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