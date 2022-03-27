function newH = computeHRandom(spectrumOfFolder,template,beta,niter)
% computeHRandom 多音调检测（随机初始化H），将检测得到的pitch activation保存为mat文件
%
% newH = computeHRandom(spectrumOfFolder,template,beta,niter)
%
% Inputs:
%  spectrumOfFolder     各wav文件的STFT振幅谱，cell(1,nWav)
%
% Outputs:
%  newH                 各wav文件多音调检测得到的pitch activation，cell(1,nWav)

nFramePerWav = cellfun(@(x) size(x,2),spectrumOfFolder);
spectrumOfFolder = cell2mat(spectrumOfFolder);

nTemplate = size(template,2);
nFrameAll = size(spectrumOfFolder,2);
h = zeros(nTemplate,nFrameAll);
for iFrame = 1:nFrameAll
    if all(spectrumOfFolder(:,iFrame))
        [~,h(:,iFrame),~,~] = nmf_beta(spectrumOfFolder(:,iFrame),nTemplate,'W0',template,'W',template,'beta',beta,'niter',niter);
    end
end

newH = formatHRow(h,[]);
newH = mat2cell(newH,size(newH,1),nFramePerWav);
save('newHRandom.mat','newH');
end