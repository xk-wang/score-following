function newTemplate = chooseTemplate(template,noteInScore)
% chooseTemplate 根据乐谱包含的音符选择模板
%
% Inputs:
%  template     完整的模板。要求：一套模板对应NPITCH个音符，列号为音符序号；多套模板拼接，各套对应的音符相同；若有静音模板，置于末尾，静音模板数<NPITCH
%  noteInScore  乐谱包含的音符的序号
%
% Outputs:
%  newTemplate  乐谱包含的音符对应的模板。包含静音模板

global NPITCH   %多音调检测音符个数
nNoteInScore = length(noteInScore);
nTemplate = size(template,2);
nTemplateSet = floor(nTemplate/NPITCH);
iTemplate = zeros(nTemplateSet*nNoteInScore,1);	%乐谱音符对应于template的列数

for iTemplateSet = 1:nTemplateSet
    iTemplate((iTemplateSet-1)*nNoteInScore+1:iTemplateSet*nNoteInScore) = noteInScore+88*(iTemplateSet-1);
end
newTemplate = template(:,iTemplate);

if mod(nTemplate,NPITCH)~=0 %静音模板
    nSilenceTemplate = nTemplate-nTemplateSet*NPITCH;
    newTemplate(:,end+1:end+nSilenceTemplate) = template(:,nTemplateSet*NPITCH+1:end);
end
end