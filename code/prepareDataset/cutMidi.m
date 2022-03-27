function midiCut = cutMidi(midi,startSec,endSec)
% cutMidi 将输入MIDI数据，截取startSec-endSec(s)间的一段，并将startSec设为0s
%
% midiCut = cutMidi(midi,startSec,endSec)
%
% midi      第1-3列分别表示：音符序号 - onset(s) - offset(s)
% midiCut   3列（音符序号 - onset(s) - offset(s)）

%% 实现一
% nRow = 0;   %midi截取后的行数
% for iRow = 1:size(midi,1)
%     if midi(iRow,2)<endSec && midi(iRow,3)>startSec
%         nRow = nRow+1;
%         midiCut(nRow,1) = midi(iRow,1);
%         midiCut(nRow,2) = max(midi(iRow,2),startSec)-startSec;
%         midiCut(nRow,3) = min(midi(iRow,3),endSec)-startSec;
%     end
% end

%% 实现二
iRow = (midi(:,2)<endSec & midi(:,3)>startSec);
midiCut(:,1:3) = [midi(iRow,1),max(midi(iRow,2),startSec)-startSec,min(midi(iRow,3),endSec)-startSec];
end