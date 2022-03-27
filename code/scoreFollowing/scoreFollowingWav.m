function [sfResult,sfResultMat] = scoreFollowingWav(scoreEvent,pianoRoll,timeResolution,varargin)
% scoreFollowingWav 乐谱跟踪（wav-to-midi alignment）
%
% [sfResult,sfResultMat] = scoreFollowingWav(scoreEvent,pianoRoll,timeResolution,varargin)
%
% Inputs:
%  scoreEvent       格式见midiToEvent
%  pianoRoll        音调检测结果，各行对应的音符的序号为行号，第i列对应的时间为(i-1)*timeResolution
%  timeResolution   pianoRoll中连续两列的时间差（s）
%
% Options（以变量名-值对方式输入）:
%  minDurFlag           是否进行最短时长约束 [1]
%  minDur               音符的最短时长约束（s）（>=） [0.06]
%  onsetDetectionFlag   是否进行onset检测（为了区分连续演奏的相同音符，特征：两个极大值）
%  h                    NMF结果pitch activity
%  判定为相同音符连续演奏的条件：
%  (1)min<max1*k1
%  (2)max2>max1*k2
%  (3)max2-min>max1*k3
%  combineEventFlag     是否合并onset间隔小于minInterval的event [1]
%  minInterval          [0.06]
%
% Outputs:
%  sfResult         乐谱跟踪结果，cell(nEvent,3)，event包含的[onset 音符序号]矩阵 - 是否在当帧确定定位 - 定位
%  sfResultMat      乐谱跟踪结果，矩阵(nNote,3)，onset(s) - 音符序号 - 定位
%
% minInterval未实现，暂与minDur相同

global JPITCHES
%% 初始化
[minDurFlag,minDur,onsetDetectionFlag,h,k1,k2,k3,combineEventFlag,minInterval] = parse_opt(varargin,'minDurFlag',1, 'minDur',0.06, 'onsetDetectionFlag',1,'h',[],'k1',0.5,'k2',0.3,'k3',0.2, 'combineEventFlag',1, 'minInterval',0.06);
[nPitch,nFrame] = size(pianoRoll);
nFrameCount = zeros(nPitch,1);  %各音符连续检测到的帧数
if minDurFlag
    minDur = ceil(minDur/timeResolution)+1;    %最短时长约束对应的帧序号差
else
    minDur = 1;
end

if onsetDetectionFlag
    hMaxMin = NaN(nPitch,4);    %最大值 - 最大值所在的帧序号 - 最小值 - 最小值所在的帧序号
end

if combineEventFlag
    minInterval = ceil(minInterval/timeResolution)+1;     %最短onset间隔对应的帧序号差
    sameOnset = []; %待合并、验证最短时长约束的帧序号，从小到大排序
end

iFrame = 0;
isEnd = 0;  %音频是否结束
iEventPre = 1;  %上一个定位
isSureFlag = 1; %当前演奏的定位是否确定
isPlayed = zeros(max(cellfun(@numel,scoreEvent(:,JPITCHES))),1);  %上一定位对应的音符是否被演奏，维度由乐谱决定
% candidate：不确定定位时，定位候选信息
% iEventLastSure：上一确定的定位
% path：完全匹配的路径,cell(1,路径数),cell内，列向量
% pitches：新演奏的音符,cell(1,nNotSure),cell内，列向量
% matching：与乐谱中各位置的匹配程度,cell(1,nNotSure),cell内，列向量
candidate = struct('iEventLastSure',{[]},'path',{cell(0)},'pitches',{cell(0)},'matching',{cell(0)});
sfResult = cell(0);

%% 实时乐谱跟踪
while ~isEnd
    iFrame = iFrame+1;
    if iFrame == nFrame
        isEnd = 1;
    end
    
    %display(['第',num2str(iFrame),'帧']);
    %if iFrame == nFrame
    %end
    
    %% 各音符被连续检测到的帧数
    for iPitch = 1:nPitch
        if pianoRoll(iPitch,iFrame)==1
            nFrameCount(iPitch) = nFrameCount(iPitch)+1;
        else
            nFrameCount(iPitch) = 0;
        end
    end
    
    %% onset检测（需要存储最近的minDur帧H）
    if onsetDetectionFlag
        [JMAX,JMAXFRAME,JMIN,JMINFRAME] = deal(1,2,3,4);    %hMaxMin中各数据的列序号
        thisPitches = find(nFrameCount>=minDur); %当前帧被演奏的达到最短时长约束的各音符
        % thisPitches = find(pianoRoll(:,iFrame)==1);
        for iPitch = 1:length(thisPitches)
            thisPitch =  thisPitches(iPitch);
            thisH = h(thisPitch,iFrame);
            hMax = hMaxMin(thisPitch,JMAX);
            hMin = hMaxMin(thisPitch,JMIN);
            switch isnan(hMax)*10+isnan(hMin)
                case 11 %最大值、最小值都为NaN
                    [thisHMax,iFrameMax] = max(h(thisPitch,iFrame-minDur+1:iFrame));
                    [thisHMin,iFrameMin] = min(h(thisPitch,iFrame-minDur+1:iFrame));
                    hMaxMin(thisPitch,[JMAX,JMAXFRAME]) = [thisHMax,iFrameMax+iFrame-minDur];
                    if thisHMin < hMax*k1 %出现符合条件的最小值
                        hMaxMin(thisPitch,[JMIN,JMINFRAME]) = [thisHMin,iFrameMin+iFrame-minDur];
                    end
                case 01 %已有最大值但无最小值
                    if thisH > hMax %出现更大的值，更新
                        hMaxMin(thisPitch,[JMAX,JMAXFRAME]) = [thisH,iFrame];
                    elseif thisH < hMax*k1 %出现符合条件的最小值
                        hMaxMin(thisPitch,[JMIN,JMINFRAME]) = [thisH,iFrame];
                    end
                otherwise %最大值最小值都已存在
                    if thisH < hMin %出现更小的值，更新
                        hMaxMin(thisPitch,[JMIN,JMINFRAME]) = [thisH,iFrame];
                    elseif (thisH > (hMax*k2)) && ((thisH-hMin) > (hMax*k3))
                        nFrameCount(thisPitch) = min(iFrame - hMaxMin(thisPitch,JMINFRAME)+1,minDur);  %判定为新音符
                        % 为便于后续检测新演奏的音符，进行了min(,Dur)操作，有误差
                        hMaxMin(thisPitch,1:4) = [thisH,iFrame,NaN,NaN];
                    end
            end
        end
    end
    hMaxMin(nFrameCount==0,1:4) = NaN;
    
    %% 检测新演奏的音符
    % 等价于thisNewPitches = find(nFrameCount==minDur);
    % if判断减少了遍历nFrameCount的次数
    if ~combineEventFlag || isempty(sameOnset) || sameOnset(1)==iFrame
        thisNewPitches = find(nFrameCount==minDur);
    else
        thisNewPitches = [];
    end
    
    %% 合并onset间隔小于minInterval的event
    if combineEventFlag
        if isempty(sameOnset)
            if ~isempty(thisNewPitches)
                sfResult{end+1,1}(:,2) = thisNewPitches;    %因为同时检测到的音符可能有多个，先写入
                sfResult{end,1}(:,1) = (iFrame-minDur)*timeResolution;    %event onset(s)
                newPitchesCandidate = (nFrameCount>0 & nFrameCount<minDur);
                if any(newPitchesCandidate)
                    sameOnset = unique(iFrame+minDur-nFrameCount(newPitchesCandidate));    %unique函数已排序
                end
            end
            newPitches = thisNewPitches;
        else
            if sameOnset(1)==iFrame
                if ~isempty(thisNewPitches)
                    newPitches = unique([newPitches;thisNewPitches]);   %unique函数已排序
                    sfResult{end,1}(end+1:end+length(thisNewPitches),1) = (iFrame-minDur)*timeResolution;    %合并的音符的信息
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
            sfResult{end+1,1}(:,2) = thisNewPitches;    %因为同时检测到的音符可能有多个，先写入
            sfResult{end,1}(:,1) = (iFrame-minDur)*timeResolution;  %event onset(s)
            newPitches = thisNewPitches;
        end
    end
    
    %% 更新定位
    if ~isempty(newPitches)
        [iEventPre,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(newPitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed);
        sfResult{end,2} = isSureFlag;   %是否在当帧确定定位
        sfResult(end-length(iEventPre)+1:end,3) = num2cell(iEventPre);  %定位
        iEventPre = iEventPre(end);
    end
    
    %% 若演奏结束时未确定定位
    if isEnd && ~isSureFlag
        iEventPre = findPath(candidate,[],scoreEvent{candidate.iEventLastSure,JBARFIRST});
        sfResult(end-length(iEventPre)+1:end,3) = num2cell(iEventPre);  %定位
    end
end
% sfResultMat = offlineCheck(sfResult,scoreEvent);
end