function [template,noteList] = computeTemplateWav(wavPath,midiPath,fs,frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateWav �����������࣬��ȡ��������Ƶ��ģ��
%
% [template,noteList] = computeTemplateWav(wavPath,midiPath,fs,frameSize,hopSize,wname,fftSize,beta,niter)
%
% Inputs:
%  wavPath      ���������������Ƶ·��
%  midiPath     ��Ƶ��Ӧ��MIDI���ݣ�midi��������1-3�зֱ��ʾ��������� - onset time(s) - offset time(s)��
%  fs           ����Ƶ��
%  frameSize,hopSize,wname,fftSize  spectrumOfSignal����
%  beta,niter   nmf_beta����
%
% Outputs:
%  template     ��������Ƶ��ģ��
%  noteList     template��i�ж�Ӧ���������ΪnoteList(i)

xWav = preProcessing(wavPath,fs);
load(midiPath);
noteList = midi(:,1);
nNote = size(midi,1);
template = zeros(floor(fftSize/2)+1,nNote);
for iNote = 1:nNote
    onset = ceil(midi(iNote,2)*fs);
    if onset == 0
        onset = 1;
    end
    xNote = xWav(onset:floor(midi(iNote,3)*fs));
    
    spectrum = spectrumOfSignal(xNote,frameSize,hopSize,wname,fftSize);
    [template(:,iNote),~,~,~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);   %thresh=eps�����������ܼ������ʱ��ֹͣ
    template(:,iNote) = template(:,iNote)/sum(template(:,iNote)); %ģ���һ��
end
end