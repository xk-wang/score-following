function spectrum = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize)
% spectrumOfSignal 对信号进行STFT，计算振幅谱
% 采样数据前后填充半帧0，则第一帧中间时刻为0s
%
% spectrum = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize)
%
% Inputs:
%  x            单声道信号（列向量）
%  frameSize    帧长（samples）
%  hopSize      两连续帧起点的间隔（samples）
%  wname        窗函数名称（如@hamming、@hann）
%  fftSize      FFT长度（samples）
%
% Outputs:
%  spectrum     振幅谱（前半段，(floor(fftSize/2)+1) x 帧数）

if size(x,2)~=1
    error('输入信号x应为列向量');
end

x = [zeros(round(frameSize/2),1);x;zeros(round(frameSize/2),1)];  %采样数据前后填充半帧0
nFrame = floor((length(x)-frameSize)/hopSize)+1;    %总帧数
spectrum = zeros(floor(fftSize/2)+1,nFrame);
curPos = 1;
for iFrame = 1:nFrame
    xFrame = x(curPos:curPos+frameSize-1);  %当前帧的采样数据
    spectrum(:,iFrame) = spectrumOfFrame(xFrame,wname,fftSize);
    curPos = curPos+hopSize;
end
end