function [candidateChose,resultNoteLevel] = chooseCandidatePerPitch(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
% chooseCandidatePerPitch 对各音调分别选取threshold或lambda
%
% [candidateChose,resultNoteLevel] = chooseCandidatePerPitch(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
%
% Inputs:
%  h                pitch activation（cell(1,音频数)，cell内，一行，一列对应一帧）
%  pianoRollGt      ground truth（cell(1,音频数)，cell内，一行，一列对应一帧）
%  midiGt           ground truth（cell(音频数,1)，cell内，3列（1 - onset(s) - offset(s)）
%  noteTrackingFlag note tracking方法，0：加阈值，其它：HMM [0]
%  candidate        NPITCH行，各行为各音调的候选值
%  onsetTolerance   computeAccuracyNoteLevel参数
%  varargin         postProcessing参数（不需要threshold、lambda、pianoRollGt）
%
% Outputs:
%  candidateChose   各音调选取的值
%  resultNoteLevel  一行对应一个音调。若测试集中该音调被演奏过，选取的参数值对应的note level F-measure

global NPITCH
candidateChose = NaN(NPITCH,1);
resultNoteLevel = NaN(NPITCH,1);
nWav = size(midiGt,1);
thisMidiGt = cell(nWav,1);  %只包含该音调的
for iPitch = 1:NPITCH
    % display(['第',num2str(iPitch),'个音调']);
    thisH = cellfun(@(x) x(iPitch,:),h,'UniformOutput',false);
    thisPianoRollGt = cellfun(@(x) x(iPitch,:),pianoRollGt,'UniformOutput',false);
    for iWav = 1:nWav
        iRow = midiGt{iWav}(:,1)==iPitch;
        thisMidiGt{iWav,1} = [ones(sum(iRow),1),midiGt{iWav}(iRow,[2,3])];
    end
    if all(cellfun(@isempty,thisMidiGt))
        thisMidiGt = [];
    end
    
    thisCandidate = candidate(iPitch,:);
    [candidateChose(iPitch),fMeasure] = chooseCandidate(thisH,thisPianoRollGt,thisMidiGt,noteTrackingFlag,thisCandidate,onsetTolerance,varargin{:});
    if ~isempty(fMeasure)
        resultNoteLevel(iPitch) = fMeasure(fMeasure(:,end-1)==candidateChose(iPitch),end);
    end
end
end