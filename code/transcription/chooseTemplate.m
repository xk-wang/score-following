function newTemplate = chooseTemplate(template,noteInScore)
% chooseTemplate �������װ���������ѡ��ģ��
%
% Inputs:
%  template     ������ģ�塣Ҫ��һ��ģ���ӦNPITCH���������к�Ϊ������ţ�����ģ��ƴ�ӣ����׶�Ӧ��������ͬ�����о���ģ�壬����ĩβ������ģ����<NPITCH
%  noteInScore  ���װ��������������
%
% Outputs:
%  newTemplate  ���װ�����������Ӧ��ģ�塣��������ģ��

global NPITCH   %�����������������
nNoteInScore = length(noteInScore);
nTemplate = size(template,2);
nTemplateSet = floor(nTemplate/NPITCH);
iTemplate = zeros(nTemplateSet*nNoteInScore,1);	%����������Ӧ��template������

for iTemplateSet = 1:nTemplateSet
    iTemplate((iTemplateSet-1)*nNoteInScore+1:iTemplateSet*nNoteInScore) = noteInScore+88*(iTemplateSet-1);
end
newTemplate = template(:,iTemplate);

if mod(nTemplate,NPITCH)~=0 %����ģ��
    nSilenceTemplate = nTemplate-nTemplateSet*NPITCH;
    newTemplate(:,end+1:end+nSilenceTemplate) = template(:,nTemplateSet*NPITCH+1:end);
end
end