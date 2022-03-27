function result = wavToMidi()
scoreEventFolder = 'scoreEvent';
scoreMidiMatFolder = 'scoreMidiMat';
performanceWavFolder = 'performanceWav';
scoreEventFiles = dir(scoreEventFolder);
scoreMidiMatFiles = dir(scoreMidiMatFolder);
performanceWavFiles = dir(performanceWavFolder);

nFile = size(scoreEventFiles,1)-2;
result = cell(nFile,1);
load('..\evaluateMAPS\1Template\1\templateWithSilence.mat');
jBarFirst = 6;      %event所在的小节中第一个event在scoreEvent中的序号
for iFile = 1%1:nFile
    %% 载入乐谱
    load([scoreEventFolder,'\',scoreEventFiles(iFile+2).name]);
    scoreEvent = event;
    clear event
    if size(scoreEvent,2)<jBarFirst
        scoreEvent{1,jBarFirst} = [];
    end
    
    %% 打印处理的演奏音频名称
    performanceName = performanceWavFiles(iFile+2).name;
    display([performanceName,'乐谱跟踪']);
    
    %% onset检测
    %x = preProcessing([performanceWavFolder,'\',performanceName],fs);
    %[fs,frameSize,hopSize,wname,fftSize] = deal(44100,512,256,@hann,512);
    %onsets = onsetDetection(x,fs,frameSize,hopSize,wname,fftSize);
    
    %% 音调检测
    [fs,frameSize,hopSize,wname,fftSize,H0,beta,niter] = deal(44100,4096,441,@hamming,4096,[],0.6,15);
    % 选模板，只考虑乐谱中[minPitch-12, maxPitch+12]的音符
    load([scoreMidiMatFolder,'\',scoreMidiMatFiles(iFile+2).name]);
    noteInTemplate = max(min(midi(:,1))-12,1):min(max(midi(:,1))+12,88);
    template = chooseTemplate(template,noteInTemplate);
    %[fs,frameSize,hopSize,wname,fftSize,noteInTemplate,H0,beta,niter] = deal(44100,4096,441,@hamming,4096,[],[],0.6,15);
    %[h, ~] = pianoTranscriptionOfWav([performanceWavFolder,'\',performanceName],fs,frameSize,hopSize,wname,fftSize,template,noteInTemplate,H0,beta,niter);
    load('HChooseTemplate\G大调小步舞曲(1级)演奏MIDI.mat');
    threshold = 87.4401;%64.8097;
    pianoRoll = h>threshold;
    
    %% 初始化定位候选candidate
    candidate.iEventErrorBegin = [];
    candidate.scoreFirstPath = cell(0);
    candidate.barFirstPath = cell(0);
    candidate.forwardPath = cell(0);
    candidate.pitches = cell(0);
    candidate.scoreFirst = cell(0);
    candidate.barFirst = cell(0);
    candidate.forward = cell(0);
    
    %% 音调检测最短时长约束
    minDurFrame = 7;
    iFrameCandidate = [];
    nFrameCount = zeros(88,1);  %各音符被连续检测到的帧数
    
    %% 上一定位对应的音符是否被演奏
    jMMidi = 3;         %音符在乐谱MIDI中的序号
    isPlayed = zeros(max(cellfun(@numel,scoreEvent(:,jMMidi))),1);
    
    %% 实时乐谱跟踪
    iFrame = 0;
    iEventPre = 1;
    isEnd = 0;
    sfResult = cell(0);
    nFrame = size(pianoRoll,2);
    while iFrame<nFrame
        iFrame = iFrame+1;
        %display(['处理第',num2str(iFrame),'帧']);
        if iFrame == 2865
        end
        %if ismember(iFrame,errorLoc0)
        %end
        if iFrame==nFrame
            isEnd = 1;
        end
        
        %% 各音符被连续检测到的帧数计数
        for iPitch = 1:88
            if pianoRoll(iPitch,iFrame)==1
                nFrameCount(iPitch) = nFrameCount(iPitch)+1;
            else
                nFrameCount(iPitch) = 0;
            end
        end
        
        %% 音符最短时长约束；合并onset间隔小于 最短时长约束 的event        
        if ~isempty(iFrameCandidate)
            thisNewPitches = find(nFrameCount==minDurFrame);
            if ~isempty(thisNewPitches)
                newPitches = sort(unique([newPitches;thisNewPitches]));
            end
            iFrameCandidate(iFrameCandidate==iFrame) = [];
        else
            newPitches = find(nFrameCount==minDurFrame);
            if ~isempty(newPitches)
                sfResult{end+1,1} = (iFrame-minDurFrame)*hopSize/fs;    %event开始时间
            end
        end
        newPitchesCandidate = (nFrameCount>0 & nFrameCount<minDurFrame);
        if ~isempty(newPitches) && any(newPitchesCandidate)
            thisIFrameCandidate = iFrame+minDurFrame-nFrameCount(newPitchesCandidate);
            iFrameCandidate = unique([iFrameCandidate;thisIFrameCandidate]);
            iFrameCandidate(iFrameCandidate>=nFrame) = [];
        end
        if ~isempty(iFrameCandidate)
            continue;
        end
        
        if ~isempty(newPitches)
            sfResult{end,2} = newPitches;                                       %event对应的音符
            [iEventPre,candidate,isPlayed] = computeNewPosition(newPitches,scoreEvent,iEventPre,candidate,isPlayed,isEnd);
            if ~isnan(iEventPre)
                sfResult(end-length(iEventPre)+1:end,3) = num2cell((iFrame-1)*hopSize/fs);%确定定位的时间            
                sfResult(end-length(iEventPre)+1:end,4) = num2cell(iEventPre);  %定位
            end
            iEventPre = iEventPre(end);         
        end
        
        if isEnd && isempty(sfResult{end,4})
            iEventErrorBegin = candidate.iEventErrorBegin;
            iEvent = findBestPath(candidate,iEventErrorBegin,scoreEvent{iEventErrorBegin,jBarFirst},isEnd);
            sfResult(end-length(iEvent)+1:end,3) = num2cell((iFrame-1)*hopSize/fs);
            sfResult(end-length(iEvent)+1:end,4) = num2cell(iEvent);
        end
    end
    result{iFile} = sfResult;
end
end