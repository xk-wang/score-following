function sfResultMat = offlineCheck(sfResultCell,scoreEvent)
% offlineCheck ��ʵʱ�ؼ�����׸��ٽ������������cell��ʽ��sfResultת��Ϊ����
% sfResultMat = offlineCheck(sfResultCell,scoreEvent)
% sfResultCell  ���׸��ٽ����cell(nEvent,3)��event������[onset �������]���� - �Ƿ��ڵ�֡ȷ����λ - ��λ
% sfResultMat   ���׸��ٽ��������(nNote,3)��onset(s) - ������� - ��λ

%% ��sfResult��ʾΪ3�о���onset(s) - ������� - ��λ
sfResultMat = cell2mat(sfResultCell(:,1));
iNotePlay = 0;
for iEventPlay = 1:size(sfResultCell,1)
    sfResultMat(iNotePlay+1:iNotePlay+size(sfResultCell{iEventPlay,1},1),3) = sfResultCell{iEventPlay,3};
    iNotePlay = iNotePlay+size(sfResultCell{iEventPlay,1},1);
end

%% ���׸��ٽ����������evaluateResult���ж�������ȷ�ԣ�
% evaluateResult cell(2,4)
% [evaluateResult,iNotePlay] = evaluate(cell(0),sfResultMat,1,scoreEvent);
% while iNotePlay <= size(sfResultMat,1)
%     [evaluateResult,iNotePlay] = evaluate(evaluateResult,sfResultMat,iNotePlay,scoreEvent);
%     
%     if evaluateResult{2,1} - evaluateResult{1,1} == 1
%         [lia,locb] = ismember(evaluateResult{1,3},evaluateResult{2,2});  %ǰһ���൯���Ǻ�һ���ٵ���
%         if any(lia)
%             sfResultMat(evaluateResult{1,4}{lia}(end),3) = evaluateResult{2,1};
%             evaluateResult{2,2}(locb(lia)) = [];
%         end
%         lia = ismember(evaluateResult{2,3},evaluateResult{1,2});  %��һ���൯����ǰһ���ٵ���
%         if any(lia)
%             isInScore = find(length(sfResultMat(evaluateResult{2,4}{lia}))>1);  %�Ƿ��������е�����
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
%         % ��©���м��λ�ã��ж�ǰ��൯���Ƿ����м��ٵ���
%         % �ص�
%     end
%     evaluateResult(1,:) = [];
% end
end

function [evaluateResult,iNotePlay] = evaluate(evaluateResult,sfResultMat,iNotePlay,scoreEvent)
% ���������е�iEventScore��λ�õ�������ȷ��
% evaluateResult    �����е�λ�� - ©�������� - �൯������ - �൯��������Ӧ��sfResultMat�е����

%% ��������
global JPITCHES
iEventScore = sfResultMat(iNotePlay,3);
evaluateResult{end+1,1} = iEventScore;
pitchesScore = scoreEvent{iEventScore,JPITCHES};

%% ���������
pitchesPlay = sfResultMat(iNotePlay,2);
iNotePlay = iNotePlay+1;
nEventPlay = size(sfResultMat,1);
while(iNotePlay<=nEventPlay && sfResultMat(iNotePlay,3)==iEventScore)
    pitchesPlay(end+1) =  sfResultMat(iNotePlay,2);
    iNotePlay = iNotePlay+1;
end

%% ©��������
evaluateResult{end,2} = pitchesScore(~ismember(pitchesScore,pitchesPlay));

%% �൯�Ĳ��ڵ�ǰλ�������е�����
iNoteFirst = iNotePlay-length(pitchesPlay);
notInScore = find(~ismember(pitchesPlay,pitchesScore));
evaluateResult{end,3} = pitchesPlay(notInScore);
evaluateResult{end,4} = num2cell(iNoteFirst+notInScore-1)';

%% �������������е�����
index = arrayfun(@(x) find(pitchesPlay==x),pitchesScore,'UniformOutput',false);
for iIndex = 1:length(index)
    if length(index{iIndex})>1
        evaluateResult{end,3}(end+1) = pitchesScore(iIndex);
        evaluateResult{end,4}{end+1} = num2cell(iNoteFirst+index{iIndex}-1);
    end
end
end