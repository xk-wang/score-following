function [candidateChose,resultNoteLevel] = chooseCandidatePerPitch(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
% chooseCandidatePerPitch �Ը������ֱ�ѡȡthreshold��lambda
%
% [candidateChose,resultNoteLevel] = chooseCandidatePerPitch(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
%
% Inputs:
%  h                pitch activation��cell(1,��Ƶ��)��cell�ڣ�һ�У�һ�ж�Ӧһ֡��
%  pianoRollGt      ground truth��cell(1,��Ƶ��)��cell�ڣ�һ�У�һ�ж�Ӧһ֡��
%  midiGt           ground truth��cell(��Ƶ��,1)��cell�ڣ�3�У�1 - onset(s) - offset(s)��
%  noteTrackingFlag note tracking������0������ֵ��������HMM [0]
%  candidate        NPITCH�У�����Ϊ�������ĺ�ѡֵ
%  onsetTolerance   computeAccuracyNoteLevel����
%  varargin         postProcessing����������Ҫthreshold��lambda��pianoRollGt��
%
% Outputs:
%  candidateChose   ������ѡȡ��ֵ
%  resultNoteLevel  һ�ж�Ӧһ�������������Լ��и��������������ѡȡ�Ĳ���ֵ��Ӧ��note level F-measure

global NPITCH
candidateChose = NaN(NPITCH,1);
resultNoteLevel = NaN(NPITCH,1);
nWav = size(midiGt,1);
thisMidiGt = cell(nWav,1);  %ֻ������������
for iPitch = 1:NPITCH
    % display(['��',num2str(iPitch),'������']);
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