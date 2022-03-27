function prepareDataset(isolPathMaps,isolPath,musPathMaps,wavMusPath,midiMusPath,midiMusPath2)
%% ׼�������������ݼ�
if exist(isolPathMaps,'dir')==0
    error('ԭʼ��MAPS�����������ݼ�����Ŀ¼������');
end
if exist(isolPath,'dir')==0     %��isolPath�ļ��в������򴴽�
    mkdir(isolPath);
end

% ΪʹMATLAB�����ļ���˳��Ϊ����˳���������ļ�
files = dir(isolPathMaps);
for iFile = 3:length(files)     %MATLAB�������ļ��У�ǰ�����������ļ�
    [~,name,ext] = fileparts(files(iFile).name);
    
    loudness = name(14:15);   %e.g. F_
    usePedal = name(16:17);   %e.g. S0
    if name(20) =='1'   %MIDI pitch����λ
        midiPitch = name(19:23);  %e.g. M100_
    else
        midiPitch = ['M','0',name(20:22)];    %e.g. M021_
    end
    
    copyfile([isolPathMaps,'\',files(iFile).name],[isolPath,'\',loudness,midiPitch,usePedal,ext]);
end

% ��ȡtxt�ļ��и�����������Ƶ��MIDI pitch - onset(s) - offset(s)
txts = dir([isolPath,'/*.txt']);
nTxt = length(txts);
timeInfo = zeros(nTxt,3);
for iTxt = 1:nTxt;
    A = importdata([isolPath,'\',txts(iTxt).name]);
    txtData = A.data;
    timeInfo(iTxt,:) = txtData(:,[3,1,2]);  %MAPS���ݼ���.txt�ļ��洢MIDI��Ϣ����1-3�зֱ��ʾ��onset(s) - offset(s) - MIDI pitch
end
save([isolPath,'\timeInfoTxtRead.mat'],'timeInfo');
rmdir(isolPathMaps,'s');

%% ׼���������ݼ���MAPS ENSTDkAm����Ƶǰ30s��
if exist(musPathMaps,'dir')==0
    error('ԭʼ��MAPS�������ݼ�����Ŀ¼������');
end
cutWav(musPathMaps,wavMusPath,0,30);
txtMidiToMat(musPathMaps,midiMusPath,0,30); %��MAPS���ݼ���.txt�ļ��ڵ�MIDI��Ϣ��Ϊground truth
midiToMat(musPathMaps,midiMusPath2,0,30);   %����MAPS���ݼ��е�.mid�ļ���Ϊground truth

rmdir(musPathMaps,'s');
delete([midiMusPath,'\','MAPS_MUS-chpn-p14_ENSTDkAm.mat']);     %�����Ӧ����Ƶ��ʱ��С��30s
delete([midiMusPath2,'\','MAPS_MUS-chpn-p14_ENSTDkAm.mat']);
end