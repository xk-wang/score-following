function spectrum = spectrumOfFrame(xFrame,wname,fftSize)
% spectrumOfFrame 对一帧信号进行FFT，计算振幅谱
% 分帧-加窗-末尾补零-FFT，窗长=帧长，为偶数时窗函数满足DFT偶对称
%
% spectrum = spectrumOfFrame(xFrame,wname,fftSize)
%
% Inputs:
%  xFrame   一帧音频采样（列向量，长度为帧长）
%  wname    窗函数名称（如@hamming、@hann）
%  fftSize  FFT长度（samples）
%
% Outputs:
%  spectrum 振幅谱（前半段，(floor(fftSize/2)+1) x 1）

if size(xFrame,2)~=1
    error('输入音频采样xFrame应为列向量');
end

win = window(wname,length(xFrame),'periodic');
xFrame = xFrame.*win;
fftFrame = fft(xFrame,fftSize);
spectrum = abs(fftFrame(1:fftSize/2+1));
end