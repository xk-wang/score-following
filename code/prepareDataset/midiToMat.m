function midiToMat(folder,destination,startSec,endSec)
% midiToMat 解析folder文件夹中的.mid文件，以同名.mat文件存入destination文件夹
% 若输入参数个数>2，则截取startSec-endSec(s)间的一段，并将startSec设为0s
%
% midiToMat(folder,destination,startSec,endSec)
%
% 若destination文件夹不存在则创建
% mat文件中存储midi变量，3列（音符序号（MIDI pitch-20） - onset(s) - offset(s)，MIDI pitch 60 --> C4 = middle C)，按onset - 音符序号排序
% 依赖库：midi_lib

if exist(folder,'dir')==0
    error('MIDI文件所在的文件夹不存在');
end

% 若destination文件夹不存在则创建
if exist(destination,'dir')==0
    mkdir(destination);
end

midis = dir([folder,'/*.mid']);
for iMidi = 1:length(midis)
    % 读MIDI文件，并表示为3列格式
    midiName = midis(iMidi).name;
    midi = readmidi_java([folder,'\',midiName]);
    midi = [midi(:,4)-20,midi(:,6),midi(:,6)+midi(:,7)];    %音符序号 = MIDI pitch - 20
    
    % 若只截取startSec-endSec(s)间的一段
    if nargin > 2
        midi = cutMidi(midi,startSec,endSec);
    end
    
    % 保存为.mat文件
    midi = sortrows(midi,[2,1]);    %按onset - 音符序号排序
    save([destination,'\',midiName(1:end-4),'.mat'],'midi');
end
end