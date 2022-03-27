function [candidateChose,fMeasure] = chooseCandidate(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
% chooseCandidate 根据note level F-measure选取threshold或lambda
%
% [candidateChose,fMeasure] = chooseCandidate(h,pianoRollGt,midiGt,noteTrackingFlag,candidate,onsetTolerance,varargin)
%
% Inputs:
%  h                pitch activation（cell(1,音频数)，cell内一行对应一个音符，一列对应一帧）
%  pianoRollGt      ground truth（cell(1,音频数)，cell内一行对应一个音符，一列对应一帧）
%  midiGt           ground truth（cell(音频数,1)，cell内，3列（音符序号 - onset(s) - offset(s)）
%  noteTrackingFlag note tracking方法，0：加阈值，其它：HMM [0]
%  candidate        候选值，为[]时取默认值
%  onsetTolerance   computeAccuracyNoteLevel参数
%  varargin         postProcessing参数（不需要threshold、lambda、pianoRollGt）
%
% Outputs:
%  candidateChose   选取的值
%  fMeasure         各候选值对应的note level F-measure
%
% computeAccuracy参数的数据类型影响其中的计算

%% 准备相关参数
if noteTrackingFlag == 0
    candidateName = 'threshold';
else
    candidateName = 'lambda';
end

if isempty(candidate)   %？候选值的范围、个数
    if noteTrackingFlag == 0
        candidate = linspace(0,200,100);
    else
        candidate = linspace(0.02,0.4,25);
    end
end
nCandidate = length(candidate); %一次遍历中候选值的个数
nSearch = 2;    %遍历的次数

isScoreKnown = varargin{find(strcmp(varargin, 'isScoreKnown'))+1};
if isScoreKnown
    timeResolution = varargin{find(strcmp(varargin, 'timeResolution'))+1};
    minDur = varargin{find(strcmp(varargin, 'minDur'))+1};
    minDurFalsePos = varargin{find(strcmp(varargin, 'minDurFalsePos'))+1};
end

nWav = size(h,2);
%% 若midiGt为空，找最小阈值
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
    %% 若midiGt不为空，对各候选值计算note-level F-measure
    fMeasure = zeros(nCandidate,2*nSearch);  %存放(candidate,note-level F-measure)值对
    for iSearch = 1:nSearch
        fMeasure(:,iSearch*2-1) = candidate;
        % nWorse = 0;
        for iCandidate = 1:nCandidate
            resultPerWav = table;    %computeAccuracy返回值数据类型为table
            for iWav = 1:nWav
                [pianoRoll,midi] = postProcessing(h{iWav},candidateName,candidate(iCandidate),'pianoRollGt',pianoRollGt{iWav},varargin{:});
                % if isempty(midi)
                %     continue;
                % end
                if isScoreKnown
                    [isPlayed,falsePos] = evaluateScoreKnown(pianoRoll,timeResolution,midiGt{iWav},(0:size(pianoRoll,2)-1)*timeResolution,minDur,minDurFalsePos);    %将ground truth作为乐谱跟踪结果
                    resultNoteLevel = computeAccScoreKnown(midiGt{iWav},isPlayed,falsePos);
                else
                    resultNoteLevel = computeAccuracyNoteLevel(midi,midiGt{iWav},onsetTolerance,0);    %是否忽略倍频错误已在postProcessing中处理，此处不忽略倍频错误
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
        
        %寻找下次遍历中候选的起止值，一次遍历确定最大F-measure的一个数位
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