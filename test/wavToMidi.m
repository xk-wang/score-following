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
jBarFirst = 6;      %event���ڵ�С���е�һ��event��scoreEvent�е����
for iFile = 1%1:nFile
    %% ��������
    load([scoreEventFolder,'\',scoreEventFiles(iFile+2).name]);
    scoreEvent = event;
    clear event
    if size(scoreEvent,2)<jBarFirst
        scoreEvent{1,jBarFirst} = [];
    end
    
    %% ��ӡ�����������Ƶ����
    performanceName = performanceWavFiles(iFile+2).name;
    display([performanceName,'���׸���']);
    
    %% onset���
    %x = preProcessing([performanceWavFolder,'\',performanceName],fs);
    %[fs,frameSize,hopSize,wname,fftSize] = deal(44100,512,256,@hann,512);
    %onsets = onsetDetection(x,fs,frameSize,hopSize,wname,fftSize);
    
    %% �������
    [fs,frameSize,hopSize,wname,fftSize,H0,beta,niter] = deal(44100,4096,441,@hamming,4096,[],0.6,15);
    % ѡģ�壬ֻ����������[minPitch-12, maxPitch+12]������
    load([scoreMidiMatFolder,'\',scoreMidiMatFiles(iFile+2).name]);
    noteInTemplate = max(min(midi(:,1))-12,1):min(max(midi(:,1))+12,88);
    template = chooseTemplate(template,noteInTemplate);
    %[fs,frameSize,hopSize,wname,fftSize,noteInTemplate,H0,beta,niter] = deal(44100,4096,441,@hamming,4096,[],[],0.6,15);
    %[h, ~] = pianoTranscriptionOfWav([performanceWavFolder,'\',performanceName],fs,frameSize,hopSize,wname,fftSize,template,noteInTemplate,H0,beta,niter);
    load('HChooseTemplate\G���С������(1��)����MIDI.mat');
    threshold = 87.4401;%64.8097;
    pianoRoll = h>threshold;
    
    %% ��ʼ����λ��ѡcandidate
    candidate.iEventErrorBegin = [];
    candidate.scoreFirstPath = cell(0);
    candidate.barFirstPath = cell(0);
    candidate.forwardPath = cell(0);
    candidate.pitches = cell(0);
    candidate.scoreFirst = cell(0);
    candidate.barFirst = cell(0);
    candidate.forward = cell(0);
    
    %% ����������ʱ��Լ��
    minDurFrame = 7;
    iFrameCandidate = [];
    nFrameCount = zeros(88,1);  %��������������⵽��֡��
    
    %% ��һ��λ��Ӧ�������Ƿ�����
    jMMidi = 3;         %����������MIDI�е����
    isPlayed = zeros(max(cellfun(@numel,scoreEvent(:,jMMidi))),1);
    
    %% ʵʱ���׸���
    iFrame = 0;
    iEventPre = 1;
    isEnd = 0;
    sfResult = cell(0);
    nFrame = size(pianoRoll,2);
    while iFrame<nFrame
        iFrame = iFrame+1;
        %display(['�����',num2str(iFrame),'֡']);
        if iFrame == 2865
        end
        %if ismember(iFrame,errorLoc0)
        %end
        if iFrame==nFrame
            isEnd = 1;
        end
        
        %% ��������������⵽��֡������
        for iPitch = 1:88
            if pianoRoll(iPitch,iFrame)==1
                nFrameCount(iPitch) = nFrameCount(iPitch)+1;
            else
                nFrameCount(iPitch) = 0;
            end
        end
        
        %% �������ʱ��Լ�����ϲ�onset���С�� ���ʱ��Լ�� ��event        
        if ~isempty(iFrameCandidate)
            thisNewPitches = find(nFrameCount==minDurFrame);
            if ~isempty(thisNewPitches)
                newPitches = sort(unique([newPitches;thisNewPitches]));
            end
            iFrameCandidate(iFrameCandidate==iFrame) = [];
        else
            newPitches = find(nFrameCount==minDurFrame);
            if ~isempty(newPitches)
                sfResult{end+1,1} = (iFrame-minDurFrame)*hopSize/fs;    %event��ʼʱ��
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
            sfResult{end,2} = newPitches;                                       %event��Ӧ������
            [iEventPre,candidate,isPlayed] = computeNewPosition(newPitches,scoreEvent,iEventPre,candidate,isPlayed,isEnd);
            if ~isnan(iEventPre)
                sfResult(end-length(iEventPre)+1:end,3) = num2cell((iFrame-1)*hopSize/fs);%ȷ����λ��ʱ��            
                sfResult(end-length(iEventPre)+1:end,4) = num2cell(iEventPre);  %��λ
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