# Sonification: climate grooves

Function that transforms any dataseries (preferably a multiple of 8 or 16
data points) into a musical sequence.

INPUT

yData       =  one-dimensional vector containing numerical data

StartingSeq =  lowest note in the chosen scale (1-7), where 1 = C in the scale of C

Key         =  major key of the sequence (C, Db, D, Eb, ...)

SeqLength   =  tonal span of the sequence (14 = 2 octaves)

FileName    =  name of outputfile (without extension)

IPmethod    =  mapping method: 1: frequency; 2: logarithmic frequency
                 (linear scale); 3: equidistant
flag        =  0: only abc output file is created
               1: abc software and ps2pdf is executed to produce a pdf
                 file with sheet music

OUTPUT

FileName.abc:
Text file written with musical written in abc notation
(https://abcnotation.com/). The file has the extension '.abc'.
If 'flag=1', the abc2ps programme will be executed and a pdf file created
with the sheet music. This requires installation of the abc notation
software as well as ghostscript and ps2pdf.
Alternatively the .abc file can be transformed into sheet music using
online abc tools (see https://abcnotation.com/ for more info).

FileName.mid:
MIDI file with output of the track that can be imported in
a DAW (using subroutines listed below).

FileName.mat:
Matrix M with basic MIDI information for further editing.
Can be translated into a MIDI file with the commands
midi=matrix2midi(M) and writemidi(midi, midifile), taken from 
https://kenschutte.com/midi/ and https://github.com/kts/matlab-midi/
