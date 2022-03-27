function [pianoRoll,midi] = postProcessing(h,varargin)
% postProcessing 根据pitch activation得到转录结果，分别表示为piano roll格式和midi格式
% 后处理：中值滤波、note tracking、忽略倍频错误、最短时长约束
%
% [pianoRoll,midi] = postProcessing(h,varargin)
%
% Inputs（除h外，其它均为可选参数，以变量名-值对方式输入）：
%  h                        谱因式分解算法结果，pitch activation，一行对应一个音符，第i列对应的时间为(i-1)*timeResolution
%  medfiltFlag              是否对pitch activation进行中值滤波，1：进行，其它：不进行 [0]
%  nSample                  中值滤波阶数 [7]
%  noteTrackingFlag         note tracking方法，0：加阈值，其它：HMM [0]
%  threshold                pitch activation的阈值（>） [0]
%  coeff                    threshold为空时，各帧阈值为H最大值*coeff
%  minTh                    threshold为空时，阈值的最小值
%  lambda                   CRF参数 [0.1]
%  noteTransitions          CRF参数，3维，第一维对应各个音符，与h各行对应的音符一致
%  nMaxFlag                 是否根据乐谱polyphonic level取H最大的前nMax个
%  nMax
%  ignoreOctaveErrorsFlag   是否忽略倍频错误，1：忽略，其它：不忽略 [0]
%  pianoRollGt              ground truth（忽略倍频错误时，要求输入） [[]]，
%                           要求：h、pianoRollGt各行对应的音符相同，行号相差12的行对应的音符为八度关系，各列对应的时间相同
%  minDurFlag               最短时长约束的方式，1：非实时、2：实时、其它：不进行最短时长约束 [0]
%  timeResolution           h中连续两列的时间差（s） [0.01]
%  minDur                   音符的最短时长约束（s）（>=） [0.06]
%
% Outputs:
%  pianoRoll    多音调检测结果，piano roll格式，88行
%  midi         note tracking结果，midi格式
%
% 忽略倍频错误，检测值与参考值匹配时允许多对多（若至多一对一，须计算最佳匹配）
% 最短时长约束实时方式：检测到音符被连续演奏minDur后，才认为该音符被演奏
% 未完成：对可能被演奏的音符加低阈值，对可能没被演奏的音符加高阈值
% 待验证：最短时长约束，两种方式得到的MIDI是否相同

%% 处理输入参数
[medfiltFlag, nSample,noteTrackingFlag, threshold, coeff,minTh, lambda,noteTransitions,nMaxFlag,nMax,ignoreOctaveErrorsFlag, pianoRollGt, minDurFlag, timeResolution, minDur] = ...
    parse_opt(varargin, 'medfiltFlag', 0, 'nSample', 7,...
    'noteTrackingFlag', 0, 'threshold', 0, 'coeff', 0.25, 'minTh', 250, ...
    'lambda',0.1,'noteTransitions',[],...
    'nMaxFlag',1,'nMax',2,...
    'ignoreOctaveErrorsFlag', 0, 'pianoRollGt', [], ...
    'minDurFlag', 0, 'timeResolution', 0.01, 'minDur', 0.06);

%% 中值滤波
if medfiltFlag == 1
    h = medfilt1(h',nSample)';  %要求：h 行对应音符
end

%% 加阈值
if noteTrackingFlag == 0
    if isempty(threshold)
        pianoRoll = zeros(size(h));
        for iFrame = 1:size(h,2)
            thisTh = max(max(h(:,iFrame))*coeff,minTh);
            pianoRoll(:,iFrame) = double(h(:,iFrame)>thisTh);
        end
    elseif length(threshold)==1
        pianoRoll = double(h>threshold);
    else
        pianoRoll = zeros(size(h));
        for iPitch = 1:size(h,1)
            pianoRoll(iPitch,:) = double(h(iPitch,:)>threshold(iPitch));
        end
    end
else
    [nPitch,nFrame] = size(h);
    pianoRoll = zeros(nPitch,nFrame);
    nodePot = zeros(nFrame,2);
    for iPitch = 1:nPitch
        bbb = 0.5*(h(iPitch,:)+[0 h(iPitch,1:nFrame-1)])*lambda;
        nodePot(:,1) = exp(-bbb);
        nodePot(:,2) = 1-exp(-bbb);
        pianoRoll(iPitch,:) = crfChain_decode(nodePot,squeeze(noteTransitions(iPitch,:,:)));
    end
    pianoRoll = pianoRoll-1;
end

%% 根据乐谱polyphonic level取H最大的前nMax个
if nMaxFlag
    for iFrame =1:size(pianoRoll,2)
        if sum(pianoRoll(:,iFrame))>nMax
            [~,index] = sort(h(:,iFrame));
            pianoRoll(index(nMax+1:end),iFrame) = 0;
        end
    end
end

%% 忽略倍频错误
if ignoreOctaveErrorsFlag == 1  %要求：pianoRoll、pianoRollGt各列对应的时间相同
    nCol = min(size(pianoRoll,2),size(pianoRollGt,2));
    for iFrame = 1:nCol
        pianoRoll(:,iFrame) = ignoreOctaveErrors(pianoRoll(:,iFrame),pianoRollGt(:,iFrame));    %要求：见ignoreOctaveErrors
    end
end

%% 最短时长约束
if minDurFlag == 1  %非实时
    [midi,pianoRoll] = pianoRollToMidi(pianoRoll,timeResolution,minDur);
elseif minDurFlag == 2    %实时：检测到音符被连续演奏minDur后，才认为该音符被演奏
    noteDurCount = zeros(size(pianoRoll,1),1);  %各音符被连续演奏的帧数
    for iFrame = 1:size(pianoRoll,2)
        [pianoRoll(:,iFrame),noteDurCount] = minDurConstraint(pianoRoll(:,iFrame),noteDurCount,timeResolution,minDur);
    end
    
    [midi,~] = pianoRollToMidi(pianoRoll,timeResolution);
    midi(:,2) = midi(:,2)-ceil(minDur/timeResolution)*timeResolution;
else
    [midi,~] = pianoRollToMidi(pianoRoll,timeResolution);
end
end

function pianoRollChanged = ignoreOctaveErrors(pianoRollFrame,pianoRollGtFrame)
% ignoreOctaveErrors 忽略倍频错误时，修改原始多音调检测结果
% 检测值与参考值匹配时允许多对多（若至多一对一，须计算最佳匹配）
%
% Inputs:
%  pianoRollFrame   1帧原始多音调检测结果（向量）
%  pianoRollGtFrame 对应的ground truth，piano roll格式
%  要求：pianoRollFrame、pianoRollGtFrame各行对应的音符相同，行号相差12的行对应的音符为八度关系
%
% Outputs:
%  pianoRollChanged 忽略倍频错误时的多音调检测结果

pianoRollChanged = zeros(size(pianoRollFrame));
noteTot = find(pianoRollFrame==1);
noteRef = find(pianoRollGtFrame==1);
isMatched = zeros(length(noteTot),1);  %用于指示转录得到的音符在ground truth中是否有匹配
for iNoteRef = 1:length(noteRef)
    indexRef = noteRef(iNoteRef);       %ground truth中音符的行号
    for iNoteTot = 1:length(noteTot)
        indexTot = noteTot(iNoteTot);   %转录得到的音符的行号
        if mod(indexRef-indexTot,12) == 0
            pianoRollChanged(indexRef) = 1;  %转录正确的音符
            isMatched(iNoteTot) = 1;
        end
    end
end
pianoRollChanged(noteTot(isMatched==0)) = 1; %false positives
end

function [pianoRollFrame,noteDurCount] = minDurConstraint(pianoRollFrame,noteDurCount,timeResolution,minDur)
% minDurConstraint 对多音调检测结果进行最短时长约束——检测到音符被连续演奏minDur后，才认为该音符被演奏
%
% Inputs:
%  pianoRollFrame   1列
%  noteDurCount     各音符被连续演奏的帧数
%  timeResolution   pianoRoll中连续两列的时间差（s）
%  minDur           音符的最短时长约束（s）（>=）
%  要求：pianoRollFrame、noteDurCount维度相同
%
% Outputs:
%  pianoRollFrame   添加最短时长约束后的多音调检测结果

minNFrame = ceil(minDur/timeResolution)+1;   %最短时长对应的帧数
for iNote = 1:length(pianoRollFrame)
    if pianoRollFrame(iNote)==0
        noteDurCount(iNote) = 0;
    else
        noteDurCount(iNote) = noteDurCount(iNote)+1;
        if noteDurCount(iNote)<minNFrame
            pianoRollFrame(iNote) = 0;
        end
    end
end
end