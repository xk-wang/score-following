function midiCut = cutMidi(midi,startSec,endSec)
% cutMidi ������MIDI���ݣ���ȡstartSec-endSec(s)���һ�Σ�����startSec��Ϊ0s
%
% midiCut = cutMidi(midi,startSec,endSec)
%
% midi      ��1-3�зֱ��ʾ��������� - onset(s) - offset(s)
% midiCut   3�У�������� - onset(s) - offset(s)��

%% ʵ��һ
% nRow = 0;   %midi��ȡ�������
% for iRow = 1:size(midi,1)
%     if midi(iRow,2)<endSec && midi(iRow,3)>startSec
%         nRow = nRow+1;
%         midiCut(nRow,1) = midi(iRow,1);
%         midiCut(nRow,2) = max(midi(iRow,2),startSec)-startSec;
%         midiCut(nRow,3) = min(midi(iRow,3),endSec)-startSec;
%     end
% end

%% ʵ�ֶ�
iRow = (midi(:,2)<endSec & midi(:,3)>startSec);
midiCut(:,1:3) = [midi(iRow,1),max(midi(iRow,2),startSec)-startSec,min(midi(iRow,3),endSec)-startSec];
end