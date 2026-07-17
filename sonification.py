"""
sonification.py

Python translation of the MATLAB function `Sonification.m`.

Transforms a numeric data series (preferably a multiple of 8 or 16 points)
into a musical sequence, writing out:
  - an ABC notation file (<FileName>.abc)
  - a MIDI file (<FileName>.mid)
  - a saved matrix of MIDI events (<FileName>.npy)

Dependencies
------------
- numpy
- scipy            (for scipy.signal.find_peaks)
- midiutil         (pip install midiutil)  -> used in place of MATLAB's
                    matrix2midi/writemidi helpers, which have no direct
                    Python equivalent.
- abcm2ps + ghostscript/ps2pdf on PATH, only if flag == 1 (sheet music PDF).

MIT License
Copyright (c) 2025 Frank Pattyn
(license text preserved from the original file; see MATLAB source)
"""

import subprocess

import numpy as np
from scipy.signal import find_peaks

try:
    from midiutil import MIDIFile
except ImportError:  # pragma: no cover
    MIDIFile = None


# ----------------------------------------------------------------------
# Helper: MIDI note number -> ABC pitch notation
# ----------------------------------------------------------------------
def midi2abc(midi_pitch, scale):
    """
    Map a single MIDI pitch value (0-127) to an ABC notation string.
    Direct translation of the user's midi2abc.m.

    midi_pitch : int, MIDI note number
    scale      : 1 to use flat spellings, otherwise sharp spellings
    """
    midi_pitch = int(round(midi_pitch))

    if scale == 1:
        note_names = ['C', '_D', 'D', '_E', 'E', 'F', '#F', 'G', '_A', 'A', '_B', 'B']  # flats
    else:
        note_names = ['C', '#C', 'D', '#D', 'E', 'F', '#F', 'G', '#G', 'A', '#A', 'B']  # sharps

    # Pitch class (0-11, C to B)
    pitch_class = midi_pitch % 12

    # Octave number (MIDI standard: C4 = middle C = note 60)
    octave = midi_pitch // 12 - 1

    base_name = note_names[pitch_class]

    # --- Apply ABC notation octave rules ---
    if octave >= 5:  # Middle C (60) and above
        if octave == 5:
            abc_note = base_name.lower()
        else:
            apostrophes = "'" * (octave - 5)
            abc_note = base_name.lower() + apostrophes
    else:  # Below middle C
        if octave == 4:
            abc_note = base_name
        else:
            commas = ',' * (4 - octave)
            abc_note = base_name + commas

    # Handle accidentals: '#' -> '^' (ABC sharp prefix); flats already use '_'
    abc_note = abc_note.replace('#', '^')

    return abc_note


# ----------------------------------------------------------------------
# Main translated function
# ----------------------------------------------------------------------
def sonification(yData, LowestSeq, Key, SeqLength, FileName, IPmethod, scale, flag):
    """
    Transform a data series into a musical sequence.

    Parameters
    ----------
    yData       : array-like, one-dimensional numeric data
    LowestSeq   : int, lowest note in the chosen scale (1-7), where 1 = C
    Key         : str, major key of the sequence ('C', 'Db', 'D', 'Eb', ...)
    SeqLength   : int, tonal span of the sequence (14 = 2 octaves)
    FileName    : str, name of the output file (without extension)
    IPmethod    : int, mapping method:
                    1 = frequency
                    2 = logarithmic frequency (linear scale)
                    3 = equidistant
    scale       : str, one of 'Major', 'Pentatonic', 'Blues'
    flag        : int, 0 = only write the .abc file
                        1 = also run abcm2ps + ps2pdf to produce a PDF
                            of the sheet music (requires those tools
                            installed and on PATH)

    Returns
    -------
    ScaleIndices : np.ndarray of int, index into NewScale for each data point
    NewFreq      : np.ndarray of float, frequencies of the notes in the
                   chosen scale span
    """
    yData = np.asarray(yData, dtype=float)

    Sequence = len(yData)
    Lines = Sequence / 16
    if Lines < 1:
        Lines = 1
        maxj = 2
    else:
        Lines = int(Lines)
        maxj = 4

    ScaleNames = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']
    f0 = 440.0  # A4 as standard frequency

    if scale == 'Major':
        C4s = np.array([-9, -7, -5, -4, -2, 0, 2])
    elif scale == 'Pentatonic':
        C4s = np.array([-9, -7, -5, -2, 0])
    elif scale == 'Blues':
        C4s = np.array([-9, -7, -6, -5, -2, 0])
    else:
        print('scale options are Major, Pentatonic or Blues')
        return None, None

    scalelength = len(C4s) * 4 + 1
    Scales = np.zeros((12, scalelength))
    Scales[0, :] = np.concatenate([C4s - 24, C4s - 12, C4s, C4s + 12, [15]])
    for i in range(1, 12):
        Scales[i, :] = Scales[0, :] + i
    ScaleFreq = f0 * 2 ** (Scales / 12)

    # Key index (0-based)
    if Key not in ScaleNames:
        raise ValueError(f"Unknown key '{Key}'")
    ScaleChoice = ScaleNames.index(Key)

    # Flats vs sharps for the given key
    FlatsNames = ['C', 'Db', 'Eb', 'F', 'Gb', 'Ab', 'Bb']
    Flats = 1 if Key in FlatsNames else 0

    # Find the start/stop indices for the requested tonal span
    # (LowestSeq is 1-based in the original MATLAB code)
    strt = LowestSeq - 1
    stop = strt + SeqLength
    while Scales[ScaleChoice, stop] <= 4:
        strt += len(C4s)
        stop += len(C4s)

    NewScale = Scales[ScaleChoice, strt:stop + 1]
    NewFreq = ScaleFreq[ScaleChoice, strt:stop + 1]

    NewArray = [midi2abc(note + 69, Flats) for note in NewScale]

    yMin, yMax = yData.min(), yData.max()

    if IPmethod == 1:  # frequency
        InterpFreq = (yData - yMin) * (NewFreq[-1] - NewFreq[0]) / (yMax - yMin) + NewFreq[0]
        InterpNotes = np.round((np.log(InterpFreq) - np.log(f0)) * 12 / np.log(2))
    elif IPmethod == 2:  # log(frequency)
        InterpFreq = (yData - yMin) * (np.log(NewFreq[-1]) - np.log(NewFreq[0])) / (yMax - yMin) \
            + np.log(NewFreq[0])
        InterpNotes = np.round((InterpFreq - np.log(f0)) * 12 / np.log(2))
    else:
        InterpNotes = None  # not used for IPmethod == 3

    if IPmethod <= 2:
        # nearest-neighbor lookup of InterpNotes within NewScale
        ScaleIndices = np.array(
            [np.argmin(np.abs(NewScale - val)) for val in InterpNotes],
            dtype=int
        )
        closestVals = NewScale[ScaleIndices]
    else:  # equidistant notes
        ScaleIndices = np.round(
            (yData - yMin) / (yMax - yMin) * (len(NewScale) - 1)
        ).astype(int)
        closestVals = NewScale[ScaleIndices]

    # ---------------- MIDI output ----------------
    n = len(yData)
    M = np.zeros((n, 6))
    peaks, _ = find_peaks(yData)
    M[:, 0] = 1                        # track
    M[:, 1] = 1                        # channel
    M[:, 2] = closestVals + 69         # note numbers (69 = A4)
    M[:, 3] = 80                       # default volume
    M[peaks, 3] = 120                  # accent peaks
    M[:, 4] = np.arange(n) * 0.25      # note-on times (s)
    M[:, 5] = M[:, 4] + 0.25           # note-off times (s)

    _write_midi(M, FileName + '.mid')
    np.save(FileName + '.npy', M)

    # ---------------- ABC output ----------------
    with open(FileName + '.abc', 'w') as outfile:
        outfile.write(f'X: 1\nT: {FileName}\nM: 4/4\nL: 1/4\nK: {Key}\n')
        cnt = 0
        for _ in range(Lines):
            for _ in range(maxj):
                for _ in range(4):
                    outfile.write(NewArray[ScaleIndices[cnt]])
                    cnt += 1
                outfile.write('|')
            outfile.write('\n')

    if flag == 1:
        subprocess.run(['abcm2ps', FileName], check=False)
        subprocess.run(['ps2pdf', 'Out.ps', FileName + '.pdf'], check=False)

    return ScaleIndices, NewFreq


def _write_midi(M, midifile):
    """
    Write a MIDI file from the M matrix, using the midiutil package as a
    Python equivalent of MATLAB's matrix2midi/writemidi (from
    https://github.com/kts/matlab-midi/).

    Columns of M: [track, channel, note, volume, onset(s), offset(s)]
    """
    if MIDIFile is None:
        raise ImportError(
            "midiutil is required to write MIDI files. Install it with "
            "`pip install midiutil`."
        )

    n_tracks = int(M[:, 0].max())
    midi = MIDIFile(n_tracks, adjust_origin=False)
    tempo = 120
    for t in range(1, n_tracks + 1):
        midi.addTempo(t - 1, 0, tempo)

    beats_per_sec = tempo / 60.0
    for row in M:
        track, channel, note, volume, onset, offset = row
        track = int(track) - 1
        channel = int(channel) - 1
        note = int(round(note))
        volume = int(volume)
        start_beat = onset * beats_per_sec
        duration_beats = (offset - onset) * beats_per_sec
        midi.addNote(track, channel, note, start_beat, duration_beats, volume)

    with open(midifile, 'wb') as f:
        midi.writeFile(f)


