# Sonification

Function that transforms any dataseries (preferably a multiple of 8 or 16
data points) into a musical sequence.

INPUT

yData       =  one-dimensional vector containing numeric (eral) data

StartingSeq =  note in the chosen scale on which to start the sequence (1-7)

Key         =  major key of the sequence (C, Db, D, Eb, ...)

SeqLength   =  tonal span of the sequence (14 = 2 octaves)

FileName    =  name of outputfile (without extension)

flag        =  0: only abc output file is created
               1: abc software and ps2pdf is executed to produce a pdf
               file with sheet music

OUTPUT

Text file written with musical written in abc notation

(https://abcnotation.com/). The file has the extension '.abc'

If 'flag=1', the abc2ps programme will be executed and a pdf file created
with the sheet music. This requires installation of the abc notation
software as well as ghostscript and ps2pdf.

Alternatively the .abc file can be transformed into sheet music using
online abc tools (see https://abcnotation.com/ for more info).
