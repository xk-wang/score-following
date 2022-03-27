function newH = computeHRandom(spectrumOfFolder,template,beta,niter)
% computeHRandom ��������⣨�����ʼ��H���������õ���pitch activation����Ϊmat�ļ�
%
% newH = computeHRandom(spectrumOfFolder,template,beta,niter)
%
% Inputs:
%  spectrumOfFolder     ��wav�ļ���STFT����ף�cell(1,nWav)
%
% Outputs:
%  newH                 ��wav�ļ����������õ���pitch activation��cell(1,nWav)

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