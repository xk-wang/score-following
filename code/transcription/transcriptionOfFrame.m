function newH = transcriptionOfFrame(xFrame,wname,fftSize,template,noteInTemplate,h0Frame,beta,niter)
% transcriptionOfFrame 转录一帧音频信号，得到各音符的pitch activation
% 时频表示为STFT振幅谱，谱因式分解算法为NMF with beta-divergence
% 若音频信号为全0，或时频表示中有元素为0，则pitch activation为全0
%
% newH = transcriptionOfFrame(xFrame,wname,fftSize,template,noteInTemplate,h0Frame,beta,niter)
%
% Inputs:
%  xFrame,wname,fftSize     spectrumOfFrame参数
%  template                 各音符的频谱模板（(floor(fftSize/2)+1) x 模板数），满足函数formatHRow的要求
%  noteInTemplate           formatHRow参数
%  h0Frame,beta,niter       nmf_beta参数。h0Frame：模板数 x 1
%
% Outputs:
%  newH     pitch activation，NPITCH x 1

global NPITCH   %多音调检测音符个数

% 计算当前帧的STFT振幅谱
if any(xFrame)  %若非全零
    spectrum = spectrumOfFrame(xFrame,wname,fftSize);
else
    newH = zeros(NPITCH,1);
    return;
end

if ~all(spectrum)   %若有元素为0
    newH = zeros(NPITCH,1);
    return;
end

% 用NMF with beta-divergence算法计算pitch activation
[~,h,~,~] = nmf_beta(spectrum,size(template,2),'W0',template,'W',template,'H0',h0Frame,'beta',beta,'niter',niter);

% 有多套模板时，将对应于同一音符的pitch activation相加
newH = formatHRow(h,noteInTemplate);
end