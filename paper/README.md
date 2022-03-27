# ScoreInformedPianoTranscription

[源码](https://code.soundsoftware.ac.uk/projects/score-informed-piano-transcription)

[数据集](http://c4dm.eecs.qmul.ac.uk/rdr/handle/123456789/13)

## 依赖库

+	TiMidity++

	[下载](http://timidity.s11.xrea.com/index.en.html#down) (信息来源：源码README.txt - http://timidity.sourceforge.net/ - TiMidity++-2.14.0 - README: Windows version)
	
	[安装说明](http://ocmnet.com/saxguru/Timidity.htm)
	
	soundfonts：[源码推荐Merlin Vienna soundfonts for timidity](http://www.soundfonts.gonet.biz/index.php)，[解压工具](http://www.composition-contest.com/db_sf2.php?home=1)
	
+	源码README中未说明的

	+	midi_lib[使用方法](http://www.mathworks.com/matlabcentral/fileexchange/27470-midi-tools)
		
		包含的函数：readmidi_java、writemidi_java（convertMIDIToPianoRoll.m、synth_midi.m）
		
		说明：synth_midi.m中readmidi、writemidi分别改为了readmidi_java、writemidi_java，因为后续提到的库Midi Toolbox 1.0及mamlib包含的readmidi、writemidi函数均未正常运行。
						
	+	[mamlib](https://code.google.com/p/mamlib/)
	
		包含的函数：gettempo、nmat_dur（synth_midi.m）
		
	+	[Midi Toolbox 1.1](https://github.com/miditoolbox)
	
		包含的函数：settempo（synth_midi.m）
		
	+	[Constant-Q Transform Toolbox](https://code.soundsoftware.ac.uk/projects/constant-q-toolbox)
	
	+	安装[TDM-GCC-64](https://sourceforge.net/projects/tdm-gcc/)、[gnumex2.06](https://sourceforge.net/projects/gnumex/)
	
		编译得到repmatC.mexw64（postProcessingCRF.m）
		
		[gnumex – Matlab下调用gcc编译](http://www.xuebuyuan.com/1002290.html)
			
## 代码移植时需要修改的：

+ 	将源码给的数据集放入Dataset\DatasetEB文件夹，将依赖库放入Libraries文件夹。

	源码的依赖库：constant-q-toolbox-2b03ca77abcc、crfChain、maml_v0.1.3、midi_lib、1.1-master、nmflib。

+ 	synth_midi.m中TiMidity++的安装路径，代码中现为'D:\Timidity\timidity\timidity '。