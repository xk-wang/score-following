import mir_eval;

ref_time, ref_freq = mir_eval.io.load_ragged_time_series('DataPy\multipitchGt.txt');
est_time, est_freq = mir_eval.io.load_ragged_time_series('DataPy\multipitch.txt');
scores = mir_eval.multipitch.evaluate(ref_time, ref_freq, est_time, est_freq);
print "multipitch result:"
print "Precision:", scores['Precision']
print "Recall:", scores['Recall']
print "Accuracy:", scores['Accuracy']
print "Chroma Precision:", scores['Chroma Precision']
print "Chroma Recall:", scores['Chroma Recall']
print "Chroma Accuracy:", scores['Chroma Accuracy']
print "\n"

ref_intervals, ref_pitches = mir_eval.io.load_valued_intervals(r'DataPy\transcriptionGt.txt'); #路径前r表示不对字符串中\进行转义，不加时报错invalid mode ('r') or filename
est_intervals, est_pitches = mir_eval.io.load_valued_intervals(r'DataPy\transcription.txt');
(precision_no_offset,recall_no_offset,f_measure_no_offset,avg_overlap_ratio_no_offset) = mir_eval.transcription.precision_recall_f1_overlap(ref_intervals, ref_pitches, est_intervals, est_pitches, offset_ratio=None, onset_tolerance=0.05);
print "transcription result no offset:"
print "Precision:", precision_no_offset
print "Recall:", recall_no_offset
print "F-Measure:", f_measure_no_offset