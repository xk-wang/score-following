function sfResultMat = offlineCheck(sfResultCell,scoreEvent)
% offlineCheck 非实时地检查乐谱跟踪结果，纠错，并将cell格式的sfResult转换为矩阵
% sfResultMat = offlineCheck(sfResultCell,scoreEvent)
% sfResultCell  乐谱跟踪结果，cell(nEvent,3)，event包含的[onset 音符序号]矩阵 - 是否在当帧确定定位 - 定位
% sfResultMat   乐谱跟踪结果，矩阵(nNote,3)，onset(s) - 音符序号 - 定位

%% 将sfResult表示为3列矩阵，onset(s) - 音符序号 - 定位
sfResultMat = cell2mat(sfResultCell(:,1));
iNotePlay = 0;
for iEventPlay = 1:size(sfResultCell,1)
    sfResultMat(iNotePlay+1:iNotePlay+size(sfResultCell{iEventPlay,1},1),3) = sfResultCell{iEventPlay,3};
    iNotePlay = iNotePlay+size(sfResultCell{iEventPlay,1},1);
end

%% 乐谱跟踪结果纠错（保存evaluateResult可判断演奏正确性）
% evaluateResult cell(2,4)
% [evaluateResult,iNotePlay] = evaluate(cell(0),sfResultMat,1,scoreEvent);
% while iNotePlay <= size(sfResultMat,1)
%     [evaluateResult,iNotePlay] = evaluate(evaluateResult,sfResultMat,iNotePlay,scoreEvent);
%     
%     if evaluateResult{2,1} - evaluateResult{1,1} == 1
%         [lia,locb] = ismember(evaluateResult{1,3},evaluateResult{2,2});  %前一个多弹的是后一个少弹的
%         if any(lia)
%             sfResultMat(evaluateResult{1,4}{lia}(end),3) = evaluateResult{2,1};
%             evaluateResult{2,2}(locb(lia)) = [];
%         end
%         lia = ismember(evaluateResult{2,3},evaluateResult{1,2});  %后一个多弹的是前一个少弹的
%         if any(lia)
%             isInScore = find(length(sfResultMat(evaluateResult{2,4}{lia}))>1);  %是否是乐谱中的音符
%             sfResultMat(evaluateResult{2,4}{lia}(1),3) = evaluateResult{1,1};
%             evaluateResult{2,3}(lia(~isInScore)) = [];
%             evaluateResult{2,4}(lia(~isInScore)) = [];
%             if ~isempty(isInScore)
%                 isCorr = length(sfResultMat(evaluateResult{2,4}{lia(isInScore)}))==1;
%                 evaluateResult{2,3}(lia(isInScore(isCorr))) = [];
%                 evaluateResult{2,4}(lia(isInScore(isCorr))) = [];
%                 evaluateResult{2,4}{lia(isInScore(~isCorr))}(1) = [];
%             end            
%         end
%     else
%         % 若漏弹中间的位置，判断前后多弹的是否是中间少弹的
%         % 回弹
%     end
%     evaluateResult(1,:) = [];
% end
end

function [evaluateResult,iNotePlay] = evaluate(evaluateResult,sfResultMat,iNotePlay,scoreEvent)
% 评价乐谱中第iEventScore个位置的演奏正确性
% evaluateResult    乐谱中的位置 - 漏弹的音符 - 多弹的音符 - 多弹的音符对应于sfResultMat中的序号

%% 乐谱音符
global JPITCHES
iEventScore = sfResultMat(iNotePlay,3);
evaluateResult{end+1,1} = iEventScore;
pitchesScore = scoreEvent{iEventScore,JPITCHES};

%% 演奏的音符
pitchesPlay = sfResultMat(iNotePlay,2);
iNotePlay = iNotePlay+1;
nEventPlay = size(sfResultMat,1);
while(iNotePlay<=nEventPlay && sfResultMat(iNotePlay,3)==iEventScore)
    pitchesPlay(end+1) =  sfResultMat(iNotePlay,2);
    iNotePlay = iNotePlay+1;
end

%% 漏弹的音符
evaluateResult{end,2} = pitchesScore(~ismember(pitchesScore,pitchesPlay));

%% 多弹的不在当前位置乐谱中的音符
iNoteFirst = iNotePlay-length(pitchesPlay);
notInScore = find(~ismember(pitchesPlay,pitchesScore));
evaluateResult{end,3} = pitchesPlay(notInScore);
evaluateResult{end,4} = num2cell(iNoteFirst+notInScore-1)';

%% 多次演奏的乐谱中的音符
index = arrayfun(@(x) find(pitchesPlay==x),pitchesScore,'UniformOutput',false);
for iIndex = 1:length(index)
    if length(index{iIndex})>1
        evaluateResult{end,3}(end+1) = pitchesScore(iIndex);
        evaluateResult{end,4}{end+1} = num2cell(iNoteFirst+index{iIndex}-1);
    end
end
end