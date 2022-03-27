function newH = transcriptionOfFrame(xFrame,wname,fftSize,template,noteInTemplate,h0Frame,beta,niter)
% transcriptionOfFrame ת¼һ֡��Ƶ�źţ��õ���������pitch activation
% ʱƵ��ʾΪSTFT����ף�����ʽ�ֽ��㷨ΪNMF with beta-divergence
% ����Ƶ�ź�Ϊȫ0����ʱƵ��ʾ����Ԫ��Ϊ0����pitch activationΪȫ0
%
% newH = transcriptionOfFrame(xFrame,wname,fftSize,template,noteInTemplate,h0Frame,beta,niter)
%
% Inputs:
%  xFrame,wname,fftSize     spectrumOfFrame����
%  template                 ��������Ƶ��ģ�壨(floor(fftSize/2)+1) x ģ�����������㺯��formatHRow��Ҫ��
%  noteInTemplate           formatHRow����
%  h0Frame,beta,niter       nmf_beta������h0Frame��ģ���� x 1
%
% Outputs:
%  newH     pitch activation��NPITCH x 1

global NPITCH   %�����������������

% ���㵱ǰ֡��STFT�����
if any(xFrame)  %����ȫ��
    spectrum = spectrumOfFrame(xFrame,wname,fftSize);
else
    newH = zeros(NPITCH,1);
    return;
end

if ~all(spectrum)   %����Ԫ��Ϊ0
    newH = zeros(NPITCH,1);
    return;
end

% ��NMF with beta-divergence�㷨����pitch activation
[~,h,~,~] = nmf_beta(spectrum,size(template,2),'W0',template,'W',template,'H0',h0Frame,'beta',beta,'niter',niter);

% �ж���ģ��ʱ������Ӧ��ͬһ������pitch activation���
newH = formatHRow(h,noteInTemplate);
end