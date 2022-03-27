function prepareDataset(isolPathMaps,isolPath,musPathMaps,wavMusPath,midiMusPath,midiMusPath2)
%% 准备孤立音符数据集
if exist(isolPathMaps,'dir')==0
    error('原始的MAPS孤立音符数据集所在目录不存在');
end
if exist(isolPath,'dir')==0     %若isolPath文件夹不存在则创建
    mkdir(isolPath);
end

% 为使MATLAB遍历文件的顺序为音调顺序，重命名文件
files = dir(isolPathMaps);
for iFile = 3:length(files)     %MATLAB遍历该文件夹，前面有两个空文件
    [~,name,ext] = fileparts(files(iFile).name);
    
    loudness = name(14:15);   %e.g. F_
    usePedal = name(16:17);   %e.g. S0
    if name(20) =='1'   %MIDI pitch的首位
        midiPitch = name(19:23);  %e.g. M100_
    else
        midiPitch = ['M','0',name(20:22)];    %e.g. M021_
    end
    
    copyfile([isolPathMaps,'\',files(iFile).name],[isolPath,'\',loudness,midiPitch,usePedal,ext]);
end

% 提取txt文件中各孤立音符音频的MIDI pitch - onset(s) - offset(s)
txts = dir([isolPath,'/*.txt']);
nTxt = length(txts);
timeInfo = zeros(nTxt,3);
for iTxt = 1:nTxt;
    A = importdata([isolPath,'\',txts(iTxt).name]);
    txtData = A.data;
    timeInfo(iTxt,:) = txtData(:,[3,1,2]);  %MAPS数据集中.txt文件存储MIDI信息，第1-3列分别表示：onset(s) - offset(s) - MIDI pitch
end
save([isolPath,'\timeInfoTxtRead.mat'],'timeInfo');
rmdir(isolPathMaps,'s');

%% 准备乐曲数据集（MAPS ENSTDkAm中音频前30s）
if exist(musPathMaps,'dir')==0
    error('原始的MAPS乐曲数据集所在目录不存在');
end
cutWav(musPathMaps,wavMusPath,0,30);
txtMidiToMat(musPathMaps,midiMusPath,0,30); %将MAPS数据集中.txt文件内的MIDI信息作为ground truth
midiToMat(musPathMaps,midiMusPath2,0,30);   %解析MAPS数据集中的.mid文件作为ground truth

rmdir(musPathMaps,'s');
delete([midiMusPath,'\','MAPS_MUS-chpn-p14_ENSTDkAm.mat']);     %因其对应的音频的时长小于30s
delete([midiMusPath2,'\','MAPS_MUS-chpn-p14_ENSTDkAm.mat']);
end