function evaluate(datasetPath,frameSize,hopSize,wname,fftSize,beta,niter)
% evaluate('..\Dataset\MUS_first30Sec', 4096, 441, @hamming, 4096, 0.6, 15)

%% 添加依赖库路径
addpath('..\Libraries\nmflib');
addpath(genpath('..\code'));

%% 分别对各.wav文件计算STFT
% wavs = dir([datasetPath,'/*.wav']);
% nWavs = length(wavs);
% spectrum = cell(1,nWavs);
% nFramePerWav = ones(nWavs,1);
% for iWav = 1:nWavs
%     [x,fs] = audioread([datasetPath,'\',wavs(iWav).name]);
%     x = preProcessing(x);
%     spectrum{iWav} = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize);
%     nFramePerWav(iWav) = size(spectrum{iWav},2);
% end
% spectrumAll = cell2mat(spectrum);
% save('spectrumAll.mat','spectrumAll','nFramePerWav');

%% 载入ground truth
% load('spectrumAll.mat','nFramePerWav');
% timeResolution = 0.01;  %piano roll格式ground truth时间分辨率固定为0.01 
% 
% midis = dir([datasetPath,'/*.mat']);
% nMidis = length(midis);
% pianoRollGt = cell(1,nMidis);
% midiGt = cell(nMidis,1);
% for iMidi = 1:nMidis
%     load([datasetPath,'\',midis(iMidi).name]);
%     midiGt{iMidi} = midi;
%     pianoRollGt{iMidi} = convertMidiToPianoRoll(midi,timeResolution);
%     pianoRollGt{iMidi}(:,end+1:nFramePerWav(iMidi))=0;      
% end
% save('gtPerWav.mat','pianoRollGt','midiGt');
% 
% pianoRollGtAll = cell2mat(pianoRollGt);
% for iMidi = 1:nMidis
%     midiGt{iMidi}(:,[2,3]) = midiGt{iMidi}(:,[2,3])+ sum(nFramePerWav(1:iMidi-1))*timeResolution;
% end
% midiGtAll = cell2mat(midiGt);
% save('gtAll.mat','pianoRollGtAll','midiGtAll');

%% 用NMF with beta-divergence算法进行多音调检测
% load('spectrumAll.mat');
% load('templateWithSilence.mat');
% %只包含loudness为M(mezzo-forte)的一套模板+静音段模板
% template = template(:,[89:176,265]);
% template = template(:,1:264);
% load('templateWoSilenceDetection.mat');
% nTemplate = size(template,2);  %频谱模板总数
% nFrameAll = size(spectrumAll,2);
% h = zeros(nTemplate,nFrameAll);

%% 随机初始化
% for iFrame = 1:nFrameAll
%     if all(spectrumAll(:,iFrame))
%         [~,h(:,iFrame),~,~] = nmf_beta(spectrumAll(:,iFrame),nTemplate,'W0',template,'W',template,'beta',beta,'niter',niter);
%     end
% end

%% ground truth初始化
% load('gtAll.mat');
% nTemplateSet = 3;   %3对应H0Gt265.mat；1对应H0Gt89.mat
% H0Gt = zeros(nTemplateSet*88,nFrameAll);
% pianoRollGtChanged = pianoRollGtAll;
% for jFrame = 1:10   %参考正确结果前后100ms的信息，即pianoRollGt前后10(=0.1s/0.01s)帧
%     pianoRollGtChanged = pianoRollGtChanged|[zeros(88,jFrame) pianoRollGtAll(:,1:end-jFrame)]|[pianoRollGtAll(:,jFrame+1:end) zeros(88,jFrame)];
% end
% pianoRollGtChanged = double(pianoRollGtChanged);
% nNotePlayed = sum(pianoRollGtChanged);    %该帧被演奏的音符数
% 
% pianoRollGtChanged(pianoRollGtChanged==1) = 24.0681/nTemplateSet;  %随机初始化得到的H中应判为1的activition的均值
% pianoRollGtChanged(pianoRollGtChanged==0) = 0.0702/nTemplateSet;   %随机初始化得到的H中应判为0的activition的均值
% for k = 1:nTemplateSet
%     H0Gt((k-1)*88+1:k*88,:) = pianoRollGtChanged;
% end
% H0Gt(k*88+1:nTemplate,(nNotePlayed>0)) = 0.0702/(nTemplate-nTemplateSet*88);
% H0Gt(k*88+1:nTemplate,(nNotePlayed==0)) = 24.0681/(nTemplate-nTemplateSet*88);
% save('H0Gt265.mat','H0Gt');

% load('H0Gt264.mat');
% % H0Gt = H0Gt(1:264,:);
% for iFrame = 1:nFrameAll
%     if all(spectrumAll(:,iFrame))
%         [~,h(:,iFrame),~,~] = nmf_beta(spectrumAll(:,iFrame),nTemplate,'W0',template,'W',template,'H0',H0Gt(:,iFrame),'beta',beta,'niter',niter);
%     end
% end

%% 只包含乐谱音符
% load('gtPerWav.mat','midiGt');
% load('H0Gt265.mat');
% 
% nWav = size(midiGt,1);
% newH = cell(1,nWav);
% for iWav = 1:nWav
%     noteInScore = unique(midiGt{iWav}(:,1));
%     newTemplate = chooseTemplate(template,noteInScore);
%     newH0Gt = H0Gt(:,3001*(iWav-1)+1:3001*iWav);
%     newH0Gt = chooseTemplate(newH0Gt',noteInScore);
%     newH0Gt = newH0Gt';
%     nTemplate = size(newTemplate,2);  %频谱模板总数
%     
%     spectrum = spectrumAll(:,3001*(iWav-1)+1:3001*iWav);
%     nFrameAll = size(spectrum,2);
%     h = zeros(nTemplate,nFrameAll);
%     
%     for iFrame = 1:nFrameAll
%         if all(spectrum(:,iFrame))
%             [~,h(:,iFrame),~,~] = nmf_beta(spectrum(:,iFrame),nTemplate,'W0',newTemplate,'W',newTemplate,'H0',newH0Gt(:,iFrame),'beta',beta,'niter',niter);
%         end
%     end
%     
%     newH{iWav} = formatHTo88Rows(h,noteInScore);
% end
% newH = cell2mat(newH);
% save('newH.mat','newH');

%% post processing及评价
fs = 44100;
load('h.mat');
newH = formatHTo88Rows(h);
load('gtAll.mat');
[threshChose,fMeasure] = chooseThresh(newH,pianoRollGtAll,midiGtAll);
pianoRoll = double(newH>threshChose);
midi = convertPianoRollToMidi(pianoRoll,hopSize/fs);
resultNoteLevel = computeAccuracyNoteLevel(midi,midiGtAll);
resultFrameLevel = computeAccuracyFrameLevel(pianoRoll,pianoRollGtAll);
save('result.mat','newH','threshChose','resultFrameLevel','resultNoteLevel','fMeasure');

% numReference = round(followingError/(hopSize/fs));
% percent = 0.1;
% %% 演奏少弹了乐谱10%的音符
% midiGtMiss = modifyMidiGtAll(midiGtAll,percent,'miss');
% 
% 
% %% 演奏错弹了乐谱10%的音符
% midiGtError = modifyMidiGtAll(midiGtAll,percent,'error');
% 
% %% 演奏多弹了乐谱10%的音符
% midiGtFalse = modifyMidiGtAll(midiGtAll,percent,'false');
% 
% % 频谱振幅初始化
% H0All = computeH0Spectrum(fftAll,fs,windowSize,nTemplate,numFrameAll);
% hSpectrum = zeros(nTemplate,numFrameAll);
% for iFrame = 1:numFrameAll
%     [~,hSpectrum(:,iFrame),~,~] = nmf_beta(fftAll(:,iFrame),nTemplate,'W0',template,'W',template,'H0',H0All(:,iFrame),'beta',beta,'niter',niter);
% end
% newHSpectrum = formatTo88Rows(hSpectrum);
% 
% [threshChose,maxFNoteLevel,maxFFrameLevel,fMeasure] = chooseThresh(newHSpectrum,pianoRollGtAll,midiGtAll);
% save('spectrum.mat','newHSpectrum','threshChose','maxFNoteLevel','maxFFrameLevel','fMeasure');
% 
% %% 局部函数
%     function H0All = computeH0Spectrum(fftAll,fs,windowSize,numOfTemplates,numFrameAll)
%         detaF = fs/windowSize;
%         fBin = 0:detaF:detaF*windowSize/2;
%         f0Note = zeros(1,88);
%         for iNote = 1:88
%             f0Note(1,iNote) = 440*2.^((iNote-49)/12);
%         end
%         H0All = zeros(numOfTemplates,numFrameAll);
%         for kFrame = 1:numFrameAll
%             H0All(1:88,kFrame) = interp1(fBin, fftAll(:,kFrame)', f0Note);
%         end
%         for k = 2:numOfTemplates/88
%             H0All((k-1)*88+1:k*88,:) = H0All(1:88,:);
%         end
%     end


%% 删除依赖库路径
rmpath('..\Libraries\nmflib');
rmpath(genpath('..\code'));
end