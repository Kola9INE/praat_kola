##################################
# vowelFormants (2017) // adapted for lafrescat
# This script goes through all the files in a folder and writes in a txt information about formants, duration, intensity and F0.
#
#		REQUIREMENTS [INPUT]
#	A sound and a Textgrid with THE SAME filename and without spaces in the filename. For example this_is_my_sentence.wav and this_is_my_sentence.TextGrid
#	The format of the TextGrid must be: tier1 interval for each sound, the script will analyse only intervals with labels that have one of these symbols
#	a, e, i ,o ,u, ɪ, ɛ, æ, ɑ, ɔ, ʊ, ʌ, ɝ. You can add more or remove them at line 100.
		
#
#		INSTRUCTIONS 
#	1. Open the script (Open/Read from file...), click Run in the upper menu and Run again. 
#	2. Set the parameters.
#		a) Folder where the files you want to analyse are
#		b) Name of the txt where the results will be saved
#		c) Data to optimise the formantic analysis
#		d) Data to optimise the pitch (F0) detection
#
#		OUTPUT
#	The output is a tab separated txt file (can be dragged to Excel, beware decimals are "." you can change that uncommenting like 118) with the following information in columns.
#		a) file name
#		b) number of the Interval
#		c) label of the interval in the tier of the analysis: vowel
#		d) F0
#		e) F1
#		f) F2
#		h) F3
#		i) F4
#		j) Duration of the vowel
#		k) Intensity of the vowel at its mid point
#
#
# (c) Wendy Elvira García (2017) wendyelvira-ga/contact
# Laboratori de Fonètica (Universitat de Barcelona) http://stel.ub.edu/labfon/en
#
#################################

# CODE FOR RUNNING FROM COMMAND LINE
    #/Applications/Praat.app/Contents/MacOS/Praat --run laFresCatFormants.praat "/Users/weg/Library/CloudStorage/OneDrive-UniversitatdeBarcelona/_hacerahora/laFresCat/1_annotated_corpora/speech_nat/" 2 "results.txt" 5 2 1


#########	FORM	###############

form Pausas vowelFormants
	comment Where do you have your wavs and TextGrids?
	sentence Folder C:\Users\USER\Documents\CLN703
	comment Type of loop
	choice: "Iterative", 1
          option: "Only files"
          option: "Folders and files" 
	comment Name of output (it will be saved in the same folder where your wavs are)
	sentence txtName KOLAWOLE_OLURANTI_LAWAL_RESULT2.txt
	comment In which tier do you have the by-sound segmentation with your vowels labelled?
	integer tier 1
	comment _
	comment Do you want to extract data from the mid point 
	comment or the mean from centered 50% of the vowel?
	choice: "Extraction", 1
          option: "From mid point"
          option: "Mean from mid 50% of the vowel" 
     comment Do you want to include some rules to avoid errors?
     comment Rule 1: If a i has a F2 lower than 1500 look for use F3 data
     comment Rule 2: For u, if F2 is higher than 1000 look for F1
	word rule_based_correction yes
endform

#################################
#################################

# variables 
pitchFloor =50
	 pitchCeiling = 800
# The max formant freq is set depending on the mean f0 in the file
# 5000 hz o 5500 hz
	 time_step= 0.01
	 maximum_number_of_formants = 5
	# this value
	#positive Maximum_formant_(Hz) 5500
	 window_length= 0.025
	preemphasis_from= 50



#checks whether the file exists
if fileReadable(folder$ + "/" + txtName$) = 1
	pause The file already exists. If you click continue it will be overwritten.
endif

#creates the txt output with its first line
writeFileLine: folder$ + "/"+ txtName$, "NAME: KOLAWOLE LAWAL OLURANTI"

appendFileLine: folder$ + "/"+ txtName$, "MATRIC NUMBER: 246389"
appendFileLine: folder$ + "/"+ txtName$, "COURSE TITLE: SPEECH PROCESSING"
appendFileLine: folder$ + "/"+ txtName$, "COURSE CODE: CLN 703"
appendFileLine: folder$ + "/"+ txtName$, "TASK: A praat script that extracts MEAN F0"
appendFileLine: folder$ + "/"+ txtName$, "SCRIPT SOURCE: https://github.com/wendyelviragarcia/vowels/blob/master/analyzes_vowels_extracts_f0_f1_f2_f3_f4_int_dur.praat"
appendFileLine: folder$ + "/"+ txtName$, "THANK YOU SIR(S)/MADAM(S)", newline$, newline$
appendFileLine: folder$ + "/"+ txtName$, "########## RESULT ##########"
appendFileLine: folder$ + "/"+ txtName$, "Folder", tab$ , "Filename", tab$ ,"nInterval", tab$, "Label_interval", tab$, "F0(Mean Value)", tab$

if iterative = 2
	myListFolders = Create Strings as folder list: "myFolders", folder$ + "/"
	nFolders = Get number of strings

		if nFolders = 0
			nFolders = 1
		endif
	#loops all files in folder

else 
		nFolders = 1
endif



for subfolder to nFolders
	if iterative = 2
		selectObject: myListFolders
		subfolder$ = Get string: subfolder
		
		path$ = folder$ + "/" + subfolder$
	else
		path$ = folder$
		subfolder$= folder$

	endif


# index files for loop
myList = Create Strings as file list: "myList", path$ + "/" +"*.TextGrid"
nFiles = Get number of strings
appendInfoLine: subfolder$
#loops all files in folder
for file to nFiles
	writeInfoLine: subfolder$ + " file ", file, " of " , nFiles

	selectObject: myList
	nameFile$ = Get string: file
	myTextGrid = Read from file: path$ + "/"+ nameFile$
	#base name
	myTextGrid$ = selected$("TextGrid")
	mySound = Read from file: path$ + "/"+ myTextGrid$ + ".wav"
	selectObject: myTextGrid
	nOfIntervals = Get number of intervals: tier
	Convert to Unicode
	
	selectObject: mySound
	myPitch= To Pitch (filtered autocorrelation): 0, 50, 800, 15, "no", 0.03, 0.09, 0.5, 0.055, 0.35, 0.14
	f0mean= Get mean: 0, 0, "Hertz"

	maximum_formant = 5000

	if f0mean > 180
		maximum_formant = 5500
	endif

	selectObject: mySound

	myFormant = To Formant (burg): time_step, maximum_number_of_formants, maximum_formant, window_length, preemphasis_from
	selectObject: mySound
	myIntensity = To Intensity: 500, 0, "yes"

	

	#loops intervals
	nInterval=1
	for nInterval from 1 to nOfIntervals
		selectObject: myTextGrid
		labelOfInterval$ = Get label of interval: tier, nInterval
		#maus$ = Get label of interval: tier-1, nInterval

		#perform actions only for vowels
		# IPA and SAMPA if there are not overlappings
		if index_regex(labelOfInterval$, "[aeiouɪɛæɑɔʊʌəAEIOU@]")  <> 0

		#if index(labelOfInterval$, "a")  <> 0 or 
		#... index(labelOfInterval$, "e") <> 0
		
		
			#Gets time of the interval
			endPoint = Get end point: tier, nInterval
			startPoint = Get starting point: tier, nInterval
			durInterval = endPoint- startPoint
			midInterval = startPoint +(durInterval/2)
			durIntervalms = durInterval*1000
			#fix decimals
			durIntervalms$ = fixed$(durIntervalms, 0)
			#change decimal marker for commas
			#durIntervalms$ = replace$ (durIntervalms$, ".", ",", 1)


			
			
			#writes interval in the output
			appendFile: folder$ + "/"+ txtName$, subfolder$, tab$, myTextGrid$, tab$, nInterval, tab$, labelOfInterval$, tab$
						
			
			selectObject: myPitch
			f0 = Get value at time: midInterval, "Hertz", "Linear"
			
			if extraction = 2
				margin = durInterval * 0.5 / 2
				f0 = Get mean: startPoint+margin, endPoint-margin, "Hertz"
				f0$ = fixed$(f0, 0)

				selectObject: myFormant

				f1 = Get mean: 1, startPoint+margin, endPoint-margin, "hertz"
				f2 = Get mean: 2, startPoint+margin, endPoint-margin, "hertz"
				f3 = Get mean: 3, startPoint+margin, endPoint-margin, "hertz"
				f4 = Get mean: 4, startPoint+margin, endPoint-margin, "hertz"

				f1$ = fixed$(f1, 0)
				f2$ = fixed$(f2, 0)
				f3$ = fixed$(f3, 0)
				f4$ = fixed$(f4, 0)
			else 
				f0$ = fixed$(f0, 0)
				#look for formants
				selectObject: myFormant
				
				f1 = Get value at time: 1, midInterval, "Hertz", "Linear"
				f2 = Get value at time: 2, midInterval, "Hertz", "Linear"
				f3 = Get value at time: 3, midInterval, "Hertz", "Linear"
				f4 = Get value at time: 4, midInterval, "Hertz", "Linear"
				f1$ = fixed$(f1, 0)
				f2$ = fixed$(f2, 0)
				f3$ = fixed$(f3, 0)
				f4$ = fixed$(f4, 0)
			endif


			# Save result to text file:
			appendFileLine: folder$ + "/"+ txtName$, f0$, tab$
			
			# look for intensity
			selectObject:myIntensity
			midInt = Get value at time: midInterval, "Cubic"
			midInt$ = fixed$(midInt,0)
			# appendFileLine: folder$ + "/"+ txtName$, startPoint, tab$, durIntervalms$, tab$, midInt$
		endif
		#close interval loop
	
	endfor
	#close file loop
removeObject: myTextGrid, mySound, myFormant, myIntensity, myPitch
endfor
# final loop of subfolders
endfor
removeObject: myList
	echo Done

writeInfoLine: "JUSTIFICATION FOR CHOOSING AND USING THIS SCRIPT -- ADDED BY KOLAWOLE OLURANTI LAWAL(AS REQUIRED IN QUESTION 4)", newline$
appendInfoLine: "This is a script chosen from a github repository as indicated above in the SCRIPT SOURCE."
appendInfoLine: "This script extracts a host of features (Mean values of the F0, F1, F2, Intensity among others), but has been remodified"
appendInfoLine: "to return only the MEAN value of the Fundamental Frequency(F0) of the vowels. The task at hand is to CALCULATE THE MEAN VALUE OF THE F0"
appendInfoLine: "OF THE SOME VOWELS - WHICH WILL BE SELECTED TO A .xlsx FILE THAT IS ATTACHED IN THE SAME FOLDER AS THESE FILES."
appendInfoLine: "Hence, the justification."	