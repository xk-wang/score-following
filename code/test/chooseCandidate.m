function [candidateChose,fMeasure] = chooseCandidate(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
% chooseCandidate ����note level F-measureѡȡthreshold��lambda
%
% [candidateChose,fMeasure] = chooseCandidate(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
%
% Inputs:
%  h                pitch activation��cell(1,��Ƶ��)��cell��һ�ж�Ӧһ��������һ�ж�Ӧһ֡��
%  pianoRollGt      ground truth��cell(1,��Ƶ��)��cell��һ�ж�Ӧһ��������һ�ж�Ӧһ֡��
%  midiGt           ground truth��cell(��Ƶ��,1)��cell�ڣ�3�У�������� - onset(s) - offset(s)��
%  noteTrackingFlag note tracking������0������ֵ��������HMM [0]
%  candidate        ��ѡֵ��Ϊ[]ʱȡĬ��ֵ
%  onsetTolerance   computeAccuracyNoteLevel����
%  varargin         postProcessing����������Ҫthreshold��lambda��pianoRollGt��
%
% Outputs:
%  candidateChose   ѡȡ��ֵ
%  fMeasure         ����ѡֵ��Ӧ��note level F-measure
%
% computeAccuracy��������������Ӱ�����еļ���

%% ׼����ز���
if noteTrackingFlag == 0
    candidateName = 'threshold';
else
    candidateName = 'lambda';
end

if isempty(candidate)   %����ѡֵ�ķ�Χ������
    if noteTrackingFlag == 0
        candidate = linspace(0,200,100);
    else
        candidate = linspace(0.02,0.4,25);
    end
end
nCandidate = length(candidate); %һ�α����к�ѡֵ�ĸ���
nSearch = 2;    %�����Ĵ���

isScoreKnown = varargin{find(strcmp(varargin, 'isScoreKnown'))+1};
if isScoreKnown
    timeResolution = varargin{find(strcmp(varargin, 'timeResolution'))+1};
    minDur = varargin{find(strcmp(varargin, 'minDur'))+1};
    minDurFalsePos = varargin{find(strcmp(varargin, 'minDurFalsePos'))+1};
end

nWav = size(h,2);
%% ��midiGtΪ�գ�����С��ֵ
if isempty(midiGt)
    for iSearch = 1:nSearch
        for iCandidate = 1:nCandidate
            midi = cell(nWav,1);
            for iWav = 1:nWav
                [~,midi{iWav}] = postProcessing(h{iWav},candidateName,candidate(iCandidate),'pianoRollGt',pianoRollGt{iWav},varargin{:});
            end
            if all(cellfun(@isempty,midi))
                if iSearch<nSearch
                    if iCandidate==1
                        candidate = linspace(0,candidate(iCandidate),nCandidate);
                    else
                        candidate = linspace(candidate(iCandidate-1),candidate(iCandidate),nCandidate);
                    end
                end
                break
            end
        end
    end
    candidateChose = candidate(iCandidate);
    fMeasure = [];
else
    %% ��midiGt��Ϊ�գ��Ը���ѡֵ����note-level F-measure
    fMeasure = zeros(nCandidate,2*nSearch);  %���(candidate,note-level F-measure)ֵ��
    for iSearch = 1:nSearch
        fMeasure(:,iSearch*2-1) = candidate;
        % nWorse = 0;
        for iCandidate = 1:nCandidate
            resultPerWav = table;    %computeAccuracy����ֵ��������Ϊtable
            for iWav = 1:nWav
                [pianoRoll,midi] = postProcessing(h{iWav},candidateName,candidate(iCandidate),'pianoRollGt',pianoRollGt{iWav},varargin{:});
                % if isempty(midi)
                %     continue;
                % end
                if isScoreKnown
                    [isPlayed,falsePos] = evaluateScoreKnown(pianoRoll,timeResolution,midiGt{iWav},(0:size(pianoRoll,2)-1)*timeResolution,minDur,minDurFalsePos);    %��ground truth��Ϊ���׸��ٽ��
                    resultNoteLevel = computeAccScoreKnown(midiGt{iWav},isPlayed,falsePos);
                else
                    resultNoteLevel = computeAccuracyNoteLevel(midi,midiGt{iWav},onsetTolerance,0);    %�Ƿ���Ա�Ƶ��������postProcessing�д����˴������Ա�Ƶ����
                end
                resultPerWav = [resultPerWav;resultNoteLevel];
            end
            
            if ~isempty(resultPerWav)
                metrics = computeAccuracy(sum(resultPerWav.nRref),sum(resultPerWav.nTot),sum(resultPerWav.nCorr));
                fMeasure(iCandidate,iSearch*2) = metrics.fMeasure;
            end
            
            % nWorse = earlyStopping(fMeasure,iCandidate,iSearch,nWorse);
            % if nWorse == 10
            %     break;
            % end
        end
        [maxFNoteLevel,indexF] = max(fMeasure(:,iSearch*2));
        
        %Ѱ���´α����к�ѡ����ֵֹ��һ�α���ȷ�����F-measure��һ����λ
        if iSearch < nSearch
            indexRange = find(fMeasure(:,iSearch*2)>=floor(maxFNoteLevel*(10^iSearch))/(10^iSearch));
            minimum = candidate(max(indexRange(1)-1,1));
            maximum = candidate(min(indexRange(end)+1,nCandidate));
            candidate = linspace(minimum,maximum,nCandidate);
        end
    end
    candidateChose = candidate(indexF);
end
end

function nWorse = earlyStopping(fMeasure,iCandidate,iSearch,nWorse)
if iCandidate > 1
    if fMeasure(iCandidate,iSearch*2)-fMeasure(iCandidate-1,iSearch*2)<=0
        nWorse = nWorse+1;
    else
        nWorse = 0;
    end
end
end