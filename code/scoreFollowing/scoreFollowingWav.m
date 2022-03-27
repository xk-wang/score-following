function [sfResult,sfResultMat] = scoreFollowingWav(scoreEvent,pianoRoll,timeResolution,varargin)
% scoreFollowingWav ���׸��٣�wav-to-midi alignment��
%
% [sfResult,sfResultMat] = scoreFollowingWav(scoreEvent,pianoRoll,timeResolution,varargin)
%
% Inputs:
%  scoreEvent       ��ʽ��midiToEvent
%  pianoRoll        ��������������ж�Ӧ�����������Ϊ�кţ���i�ж�Ӧ��ʱ��Ϊ(i-1)*timeResolution
%  timeResolution   pianoRoll���������е�ʱ��s��
%
% Options���Ա�����-ֵ�Է�ʽ���룩:
%  minDurFlag           �Ƿ�������ʱ��Լ�� [1]
%  minDur               ���������ʱ��Լ����s����>=�� [0.06]
%  onsetDetectionFlag   �Ƿ����onset��⣨Ϊ�����������������ͬ��������������������ֵ��
%  h                    NMF���pitch activity
%  �ж�Ϊ��ͬ�������������������
%  (1)min<max1*k1
%  (2)max2>max1*k2
%  (3)max2-min>max1*k3
%  combineEventFlag     �Ƿ�ϲ�onset���С��minInterval��event [1]
%  minInterval          [0.06]
%
% Outputs:
%  sfResult         ���׸��ٽ����cell(nEvent,3)��event������[onset �������]���� - �Ƿ��ڵ�֡ȷ����λ - ��λ
%  sfResultMat      ���׸��ٽ��������(nNote,3)��onset(s) - ������� - ��λ
%
% minIntervalδʵ�֣�����minDur��ͬ

global JPITCHES
%% ��ʼ��
[minDurFlag,minDur,onsetDetectionFlag,h,k1,k2,k3,combineEventFlag,minInterval] = parse_opt(varargin,'minDurFlag',1, 'minDur',0.06, 'onsetDetectionFlag',1,'h',[],'k1',0.5,'k2',0.3,'k3',0.2, 'combineEventFlag',1, 'minInterval',0.06);
[nPitch,nFrame] = size(pianoRoll);
nFrameCount = zeros(nPitch,1);  %������������⵽��֡��
if minDurFlag
    minDur = ceil(minDur/timeResolution)+1;    %���ʱ��Լ����Ӧ��֡��Ų�
else
    minDur = 1;
end

if onsetDetectionFlag
    hMaxMin = NaN(nPitch,4);    %���ֵ - ���ֵ���ڵ�֡��� - ��Сֵ - ��Сֵ���ڵ�֡���
end

if combineEventFlag
    minInterval = ceil(minInterval/timeResolution)+1;     %���onset�����Ӧ��֡��Ų�
    sameOnset = []; %���ϲ�����֤���ʱ��Լ����֡��ţ���С��������
end

iFrame = 0;
isEnd = 0;  %��Ƶ�Ƿ����
iEventPre = 1;  %��һ����λ
isSureFlag = 1; %��ǰ����Ķ�λ�Ƿ�ȷ��
isPlayed = zeros(max(cellfun(@numel,scoreEvent(:,JPITCHES))),1);  %��һ��λ��Ӧ�������Ƿ����࣬ά�������׾���
% candidate����ȷ����λʱ����λ��ѡ��Ϣ
% iEventLastSure����һȷ���Ķ�λ
% path����ȫƥ���·��,cell(1,·����),cell�ڣ�������
% pitches�������������,cell(1,nNotSure),cell�ڣ�������
% matching���������и�λ�õ�ƥ��̶�,cell(1,nNotSure),cell�ڣ�������
candidate = struct('iEventLastSure',{[]},'path',{cell(0)},'pitches',{cell(0)},'matching',{cell(0)});
sfResult = cell(0);

%% ʵʱ���׸���
while ~isEnd
    iFrame = iFrame+1;
    if iFrame == nFrame
        isEnd = 1;
    end
    
    %display(['��',num2str(iFrame),'֡']);
    %if iFrame == nFrame
    %end
    
    %% ��������������⵽��֡��
    for iPitch = 1:nPitch
        if pianoRoll(iPitch,iFrame)==1
            nFrameCount(iPitch) = nFrameCount(iPitch)+1;
        else
            nFrameCount(iPitch) = 0;
        end
    end
    
    %% onset��⣨��Ҫ�洢�����minDur֡H��
    if onsetDetectionFlag
        [JMAX,JMAXFRAME,JMIN,JMINFRAME] = deal(1,2,3,4);    %hMaxMin�и����ݵ������
        thisPitches = find(nFrameCount>=minDur); %��ǰ֡������Ĵﵽ���ʱ��Լ���ĸ�����
        % thisPitches = find(pianoRoll(:,iFrame)==1);
        for iPitch = 1:length(thisPitches)
            thisPitch =  thisPitches(iPitch);
            thisH = h(thisPitch,iFrame);
            hMax = hMaxMin(thisPitch,JMAX);
            hMin = hMaxMin(thisPitch,JMIN);
            switch isnan(hMax)*10+isnan(hMin)
                case 11 %���ֵ����Сֵ��ΪNaN
                    [thisHMax,iFrameMax] = max(h(thisPitch,iFrame-minDur+1:iFrame));
                    [thisHMin,iFrameMin] = min(h(thisPitch,iFrame-minDur+1:iFrame));
                    hMaxMin(thisPitch,[JMAX,JMAXFRAME]) = [thisHMax,iFrameMax+iFrame-minDur];
                    if thisHMin < hMax*k1 %���ַ�����������Сֵ
                        hMaxMin(thisPitch,[JMIN,JMINFRAME]) = [thisHMin,iFrameMin+iFrame-minDur];
                    end
                case 01 %�������ֵ������Сֵ
                    if thisH > hMax %���ָ����ֵ������
                        hMaxMin(thisPitch,[JMAX,JMAXFRAME]) = [thisH,iFrame];
                    elseif thisH < hMax*k1 %���ַ�����������Сֵ
                        hMaxMin(thisPitch,[JMIN,JMINFRAME]) = [thisH,iFrame];
                    end
                otherwise %���ֵ��Сֵ���Ѵ���
                    if thisH < hMin %���ָ�С��ֵ������
                        hMaxMin(thisPitch,[JMIN,JMINFRAME]) = [thisH,iFrame];
                    elseif (thisH > (hMax*k2)) && ((thisH-hMin) > (hMax*k3))
                        nFrameCount(thisPitch) = min(iFrame - hMaxMin(thisPitch,JMINFRAME)+1,minDur);  %�ж�Ϊ������
                        % Ϊ���ں�������������������������min(,Dur)�����������
                        hMaxMin(thisPitch,1:4) = [thisH,iFrame,NaN,NaN];
                    end
            end
        end
    end
    hMaxMin(nFrameCount==0,1:4) = NaN;
    
    %% ��������������
    % �ȼ���thisNewPitches = find(nFrameCount==minDur);
    % if�жϼ����˱���nFrameCount�Ĵ���
    if ~combineEventFlag || isempty(sameOnset) || sameOnset(1)==iFrame
        thisNewPitches = find(nFrameCount==minDur);
    else
        thisNewPitches = [];
    end
    
    %% �ϲ�onset���С��minInterval��event
    if combineEventFlag
        if isempty(sameOnset)
            if ~isempty(thisNewPitches)
                sfResult{end+1,1}(:,2) = thisNewPitches;    %��Ϊͬʱ��⵽�����������ж������д��
                sfResult{end,1}(:,1) = (iFrame-minDur)*timeResolution;    %event onset(s)
                newPitchesCandidate = (nFrameCount>0 & nFrameCount<minDur);
                if any(newPitchesCandidate)
                    sameOnset = unique(iFrame+minDur-nFrameCount(newPitchesCandidate));    %unique����������
                end
            end
            newPitches = thisNewPitches;
        else
            if sameOnset(1)==iFrame
                if ~isempty(thisNewPitches)
                    newPitches = unique([newPitches;thisNewPitches]);   %unique����������
                    sfResult{end,1}(end+1:end+length(thisNewPitches),1) = (iFrame-minDur)*timeResolution;    %�ϲ�����������Ϣ
                    sfResult{end,1}(end+1-length(thisNewPitches):end,2) = thisNewPitches;
                end
                sameOnset(1) = [];
            end
            if any(nFrameCount==1)
                sameOnset(end+1) = iFrame+minDur-1;
            end
        end
        if  ~isempty(sameOnset) && ~isEnd
            continue;
        end
    else
        if ~isempty(thisNewPitches)
            sfResult{end+1,1}(:,2) = thisNewPitches;    %��Ϊͬʱ��⵽�����������ж������д��
            sfResult{end,1}(:,1) = (iFrame-minDur)*timeResolution;  %event onset(s)
            newPitches = thisNewPitches;
        end
    end
    
    %% ���¶�λ
    if ~isempty(newPitches)
        [iEventPre,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(newPitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed);
        sfResult{end,2} = isSureFlag;   %�Ƿ��ڵ�֡ȷ����λ
        sfResult(end-length(iEventPre)+1:end,3) = num2cell(iEventPre);  %��λ
        iEventPre = iEventPre(end);
    end
    
    %% ���������ʱδȷ����λ
    if isEnd && ~isSureFlag
        iEventPre = findPath(candidate,[],scoreEvent{candidate.iEventLastSure,JBARFIRST});
        sfResult(end-length(iEventPre)+1:end,3) = num2cell(iEventPre);  %��λ
    end
end
% sfResultMat = offlineCheck(sfResult,scoreEvent);
end