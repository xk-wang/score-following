function midiToEvent(folder,destination,minDur)
% midiToEvent 将folder文件夹中的MIDI数据转换为event信息，以同名文件存入destination文件夹
% 若输入参数个数>2，则合并间隔小于minDur（s）的onset
%
% midiToEvent(folder,destination,minDur)
%
% 若folder、destination相同，则原MIDI数据将被event信息覆盖。
% 若destination文件夹不存在则创建
% mat文件中存储midi变量，第1-3列分别表示：音符序号 - onset(s) - offset(s)
% 生成的.mat文件中存储event元胞数组，5列，
%  (1)onset(s)（用于计算演奏节奏）
%  (2)此刻演奏的音符在MIDI数据中的行号（用于音符结束后判断是否被演奏）
%  (3)此刻新演奏的音符在MIDI数据中的行号（用于乐谱跟踪中标记上一定位对应的音符是否被演奏）
%  (4)此刻新演奏的音符的音符序号
%  (5)忽略倍频时，此刻新演奏的音符的音符序号（[0,11]）
% 若输入参数个数>2，要求MIDI数据按onset排序，生成的event第2、5列为[],第3、4列不一一对应

if exist(folder,'dir')==0
    error('MIDI数据所在的文件夹不存在');
end

% 若destination文件夹不存在则创建
if exist(destination,'dir')==0
    mkdir(destination);
end

midis = dir([folder,'/*.mat']);
for iMidi = 1:length(midis)
    midiName = midis(iMidi).name;
    load([folder,'\',midiName]);
    if nargin>2
        event = [];
        onsetDiff = [diff(midi(:,2));minDur+eps];
        iNote = 1;
        while(iNote<=size(midi,1))
            jNote = iNote+find(onsetDiff(iNote:end)>=minDur,1)-1;
            event{end+1,1} = unique(midi(iNote:jNote,2));
            event{end,3} = iNote:jNote;
            event{end,4} = sort(midi(iNote:jNote,1));
            iNote = jNote+1;
        end
        event{1,5} = [];
    else
        onset = unique(midi(:,2));  %unique函数已排序
        nOnset = length(onset);
        event = cell(nOnset,5);
        event(:,1) = num2cell(onset);
        for iOnset = 1:nOnset
            thisOnset = onset(iOnset);
            mAll = find(midi(:,2)<=thisOnset & midi(:,3)>thisOnset);
            mNew = mAll(midi(mAll,2)==thisOnset);
            %pitchesAll = midi(mAll,1);
            pitchesNew = midi(mNew,1);
            %pitchesAllOctave = mod(pitchesAll,12);
            pitchesNewOctave = mod(pitchesNew,12);
            %event(iOnset,2:7) = {mAll,mNew,pitchesAll,pitchesNew,pitchesAllOctave,pitchesNewOctave};
            event(iOnset,2:5) = {mAll,mNew,pitchesNew,pitchesNewOctave};
        end
    end
    
    %event = cell2struct(event,{'onset','mAll','mNew','pitchesAll','pitchesNew','pitchesAllOctave','pitchesNewOctave'},2);
    %struct 不能同时从多个结构体变量中取出某个成员变量，必须使用循环语句
    %event = cell2table(event,'VariableNames',{'onset' 'mAll' 'mNew' 'pitchesAll' 'pitchesNew' 'pitchesAllOctave' 'pitchesNewOctave'});
    %table 取数据一般为table或cell型，不方便矩阵操作
    save([destination,'\',midiName],'event');
end
end