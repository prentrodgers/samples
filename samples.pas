(*
profile ..\tc.pro
*)
(*{$B-}    {Boolean complete evaluation off}*)
{$S+}    {Stack checking on}
{$I-}    {I/O checking off}
{$M 65520,16384,655360} {Turbo 3 default stack and heap}

Program Samples; { Expands a macro file to a Csound .sco file including samples }

{
All tag names: & . ; @ C D E F G H I L M N O P R S T U V W Z
Next Modification
    - Fix forever the erasure of samples that are actually needed. The routine that upsamples and downsamples screws it up.
    - Set up a push/pop mechanism.
       ~tt0 pushes the current value for t, and then sets t to a new value
       ^t sets t to the previously pushed value of t.
       Decisions: Should the stack be a common stack for all values, or one for each of velocity,
       tone, octave, etc?
Last modified 3/4/18
      Added write to .csv file for input to machine learning
Last modified 12/26/16
      Modification of randomization algorithm 12/26/16 - added Drunkard's Walk
last modified 12/28/15
      made changes here on 12/28/15 to deal with negative numbers in SampleIndex
Last modified 3/25/14
       If Not AutoOctaveShift then Oct := Oct - 1;  see if not automatically incrementing keeps the octaves under control 3/25/14
Last modified 7/22/12
    Ported to Free Pascal 7/22/12 - mostly just making sure we never reference Nil
    this was added 4/9/12 to make sure upsample didn't go outside sample range
Last modified 3/29/07
    - Added the A and F parameters. A is the current overall amplitude. It is used to crescendo and decrescendo
      all instruments at the same time. I suppose it should be better to have a different amplitude for each instrument.
      Later. For now, it is useful to control the overall amplitude of the piece, and allow a gradual change of
      volume over many notes. F is to pass the line as is to the output file.
Last Modified 5/27/04
    - Allow for an additional parameter, envelope2 for the second side of the envelope. Used to implement doppler shift
    - New variable takes the place of warp, which was the old way to do bent notes. w = envelope for right channel
    - If w = 0 then w = e, so they both have the same envelope.
Last modified 9/12/03
    Loudness 0..127, if over 200, set it to zero 7/29/02 - changed to 200 9/12/03

Last Modified 7/31/02
    - Find a way to determine the tempo for the start time fix from 4/10/01.

Last Modified 7/30/02
    - Put an additional check on velocity to make sure it doesn't wrap around to 255, 253, and blow eardrums again.
    - It should kick in at anything over 200, but seems to do so at 100

Last Modified 1/1/02
    - Allow adjustment to the cent value by an amount in the McGill.dat file
      CentsTable := CentsTable + ' 0 '; - this is the old way. Assumes they are all in tune. -

Last Modified 12/7/01
    - Put in a check on the length of the macro contents to limit it to 230 bytes

Last modified 11/10/01
    - Allow for sequential random choices: allow for the selection not of the same random choice,
      but the next one in the series, with wrap around. Distinguish between p32: always the
      same, and p33, always the next in the series, and p34, always the previous in the series.

Last modified 4/10/01
    - Fixed the upsample so that it would not stray into another instrument. Still not very good,
      but better than it used to be.
      Allow the start time to be reduced to account for some samples not starting at time zero, especially
      those that have an attack transient that is interesting, but does not represent the start of the beat.
      This still needs work. See MoveForward, and TimeFactor.

Last modified 10/24/00
    - Create a new variable (u for upsample) which will be used to select a different
      sample instead of the one that would be selected based on note. u1 selects the
      next higher sample. u0 selects the normally selected sample. u255 selects
      the next lower sample. Need to change the routine that checks if a sample is
      needed to remember that up sampling can take place.
Last modified 10/22/00
    - Create a new variable (g for glissando) which will be used to specify a
      function table that will be multiplied by the frequency of the note, to create
      step functions, glissando, slides from notes to notes, etc. The variable will
      point to one function table. g0 points to a flat fuction table that won't change
      each note.
Last modified 10/11/00
    - List non-referenced macros after the reference count.
    - Create a new variable (z?) which slightly perturbs the rhythm by a small amount
      For example: z1 will change all the durations from integers to slightly out of
      synch start times. Instead of 256, it will start at a random number between 255.75
      and 256.25. z10 will set the perturbation to a random number between 255.1 and 256.9.
      z0 resets it to no perturbation. z100 will perturb up to ten beats plus or minus.
    - Allow random seed to be taken from a file, making the same random pattern each
      time. Never implemented this one. Prefer to create a file of random numbers and save it.
Last modified 9/27/2000
  - Allow the user to influence the likelihood of repeating the same
    selected macro a second time, or never repeating it until all the
    possible choices have been selected. Employ a new variable: p,
    which if set to 8 makes the selection of macro the same as it is
    today. If p is greater than 8, the likelihood of repeating the
    same macro as previous choice becomes higher. If p is 16, it
    always repeats the previous choice, non-randomly.

    Enhanced 10/18/2001 to increase this to 32

    If p is less than 8, the likelihood of repeating is lower, until
    it reaches 0, when the program will always select any other choice
    if one is available, random round robin style. The goal is for low
    numbers to select a different macro, and for high numbers to tend
    to repeat the same macro. The farther from 8, the more extreme the
    tendency.

    This will require two new variables to store with each macro:
    - LastChosen: Boolean; which is set to true when a macro is
      selected. All other possible macros must have this set to false
      when one is chosen.
    - ChosenTimes: Integer; Initially set to 0, is incremented each
      time a macro is chosen. This is used to determine which one to
      select next. When p is low, the lowest number not LastChosen
      will be picked.

    Example:
    .macro1 &C.
    .macro2 &E.
    .macro3 &G.
    .macro4 &A++.
    p0&macro*. &macro*. &macro*. &macro*. &macro*. &macro*.
    @ should produce:
    @&C. &G. &A++. &E. &G. &C. &A++. &E. &C. &E. &A++. &G.
    p16&macro*. &macro*. &macro*. &macro*. &macro*. &macro*.
    @ should produce:
    @&C. &C. &C. &C. &G. &G. &G. &G. &G. &G. &A++. &A++.

    - LastChosen: Boolean; which is set to true when a macro is
    - ChosenTimes: Integer; Initially set to 0, is incremented each
Last modified 7/8/2000
enhancements:
  - n0f1 - use the first function table - removed 3/16/04
  - n0i1 - use instrument #1 in the mwsynth.ini file     - remove 3/16/04
  - Allow the phrase n1i10 to be used for both MWSYNTH.INI use and also to
    refer to instruments already defined in comments. n0i10 for channel 0
    play sample file starting at function table 11. How to switch from the
    MWSYNTH.INI interpretation of this as instrument 10 to function table 11?
    Run time switch? Another switch in the file? A different letter from i,
    for example f? F is currently a comment line, but there is no real
    reason for it. Make is a function table start line, and use it to
    write the voice number (parameter 7).
  - Allow a tag to indicate slurred notes, with no retriggering
    and modify the instrument to accept this. Set this by a new
    instrument that supports two note, three note, four note slurs.
    Tag name: W for warped, bent notes.  - reused for second envelope 5/27/04
  - if the W value is non-zero, this sets the amount the second note
    should play, the value of p12. How to create one line for both notes is
    left as an exercise for the programmer.....
    Use instrument number 2 (i2) instead of i1 to use the slurred instrument.
    Instrument 2 expects extra parms for the second ton,oct,dur
    How to indicate in the score that you want the second note to be
    a continuation of the first is a non-zero W value, e.g.:
        c0v90d32t0o5r16s8 t8w8
    Instead of writing this out as two lines, make one line from it.
    How to anticipate that the second line is warped?
        Input will look like this:
        c0v90d32t0o5r16s8w8 t8
        The first note will need to know that the second note is to be warped
        to. You will know that the next note is a warp note, but not
        what it will warp to.
        Method:
           1. List the first note now, but don't Writeln, just Write.
              On second pass, finish the writeln
        Requirements:
           1. Must write both notes to instrument #2
           2. Can only support two notes in slur - what to do when there are
              3 or more? Error message? For wimps!

  - Print the input file with all macros expanded. - done - printed to xref.txt file
  - Print a report of all macros as saved, and as first used for debuging
    purposes. - done - printed to xref.txt file
  - Allow for other than 53 tones per octave for non-Csound version.
Ported to Free Pascal 7/22/12 - mostly just making sure we never reference Nil
     Pointers or exceed array bounds. Rearrange some While loops to check the
     Pointer = Nil prior to the other check. And is sequential
     }
uses dos,crt; {, crt Standard Turbo Units }

Const
  MaxEqual = 255; { Tones per octave }
  MaxChans = 128 - 1; { channels 0 to 127 }
  SampleFilesPerIns = 70; { Really only need 10-20 }
  McGillSamples = 1250; { Getting close? }
  MaxMacroLength = 250; { Needs to be 250 to run cuenta14 }
  MaxMacroNameLength = 23; { this should be enough, no? }

Type
  { VisNoteType is not used, as far as I can tell }
  VisNoteType = Record
                  Name: String[3];     { C, C+,C++,C#,C##,Dbb,Db,D--,D-,D etc }
                  TwelveTone:Byte;   { 0 to 12, closest 12 tone note }
                  Cents:Byte;        { 7 bit 2's complement -64 to +64 }
                  Interval: String[5]; { ' 3:2 ','11:10', etc. '    ', if none }
                end;
  AudNotePtr = ^AudNoteType;
  AudNoteType = Record
                  Octave: Byte; { 0..11 }
                  ToneInScale: Byte; { 0..MaxEqual }
                  Velocity: Byte;   { Loudness 0..127, if over 200, set it to zero 7/29/02 - changed to 200 9/12/03 }
                  Rand: Byte; { Random chance that note will play 0 - 16 }
                  Ranf: Byte; { File of Random numbers to pick from instead of generating in real time }
                  Stereo: Byte; { Stereo 0 left 15 right }
                  Perturb: Byte; { 0 is no change, 100 is 100 plus or minus }
                  Glisand: Integer; { 0 is flat, 1-500 are tables  }
                  Glisand2: Integer; { 0 is flat, 1-500 are tables  }
                  Glisand3: Integer; { 0 is flat, 1-500 are tables  }
                  Mult: Byte; { amplitude multiplicand  35 = normal, higher louder, lower softer }
                  Upsample: Byte; { 0 is normal, 1 is next higher, 255 is next lower }
                  Envelope: Byte; { Pick an Envelope Function Table  0 to 255 }
                  Duration: Integer;  { 0..32767 }
                  HoldDuration: Integer; { 0..32767 }
                  WarEnvelope: Byte; { 0..255 }
                  LyricNumber: Byte; {0..50}
                  NowVolume: Byte; {0..255}
                  NowTempo: Integer; {0..32k}
                  LineNum: Integer; {0..n}
                  { Next: AudNotePtr; }
                  Next: LongInt; { file position, not a pointer any more }
                end;
  ChannelType = Record
                  { First: AudNotePtr; } { Points to first note in channel }
                  { Current: AudNotePtr; } { Points to first note in channel }
                  First: Longint;  { points to a record location in the file }
                  Current: Longint; { Last written spot }
                  StartTime: LongInt; { Sum of Durations }
                  Instrument: Byte;     { 1 to 129 named instruments }
                  FunctionTable: Byte; { unique function table set }
                  NumSamples: Byte; { this was added 4/9/12 to make sure upsample didn't go outside sample range }
                end;
  InstrumentType = Record
                  FileName: String[12];  { trump69.wav }
                  WavePitch: Integer;       { 69 }
                  DetuneCents: Integer;     { etc }
                  Velocity: Integer;
                  MinimumNote: Integer;
                  MaximumNote: Integer;
                  MinVel: Integer;
                  MaxVel: Integer;
                  StartLoop: Integer;
                  EndLoop: Integer;
                  SustainEnv: Integer;
                  ReleaseEnv: Integer;
                end;
  McGillSampleType = Record
                  FunctionTableNum: Integer; { Which sample set is this for }
                  BaseNote: Integer;
                  Channel: Byte;
                  FTable: String[60];
                  Used: Boolean;
                  MoveForward: Single; { how many beats to subtract from start time }
                  SampleNumber: Byte; { relative number of this sample in the set }
                end;
  MacroPtr = ^MacroType;
  MacroType = Record
                  Name: String[MaxMacroNameLength];
                  Content: String[MaxMacroLength];
                  LastChosen: Boolean;
                  ChosenTimes: Integer;
                  Next: MacroPtr;
              end;
  EndType = Record
                  ToneInScale: Byte;
                  Octave: Byte;
                  Channel: Byte;
              end;
Var
  { 236 }
  CallsToMyRandom: Array[0..255] of Longint;
  Ovv : Byte;
  Ntp : Integer;
  OldMethod: Boolean;
  AutoOctaveShift: Boolean;
  Channels: Array[0..MaxChans] of ChannelType;
  LowChannel,HighChannel:Byte;
  { AudNote: AudNotePtr; }
  AudNote: AudNoteType;
  AudNoteFile: File of AudNoteType;
  ChannelFile: File of ChannelType;
  Randfile1: File of Real;
  Randfile2: File of Real;
  Randfile3: File of Real;
  Randfile4: File of Real;
  Randfile5: File of Real;
  Randfile6: File of Real;
  Randfile7: File of Real;
  Randfile8: File of Real;
  Randfile9: File of Real;
  RandfileA: File of Real;
  RandfileB: File of Real;
  RandfileC: File of Real;
  {  VisNote: Array[0..MaxEqual] of VisNoteType; }
  {InstrumentDesc: Array[0..SampleFilesPerIns] of InstrumentType;}
  McGillDesc: Array[0..McGillSamples] of McGillSampleType;
  McGillDescIndex, McGillRelativeNum: Integer;
  (* InstrumentName: String[20]; { e.g. [Trumpet] } *)
  Music,Sco,Csv,Ovf,McGill,xref: Text;
  { Warped: Boolean; }
  TimeFactor: Single;
  Input: String;
  MusicLines: Integer;
  Cha,Ran,Oct,Env,Ton,Vel,Mul: Integer;
  MaxDuration: LongInt;
  MaxTableSlot: Integer;
  FunctionTableNumber: Integer;
  StartOfFunctionTable, MonoStereoAkaiTable: String;
  Root: Byte;
  Ste: Byte;
  Dur: Integer;
  Hol: Integer;
  War: Integer;
  Pat: Byte;
  Raf: Byte;
  Num,Ins,Per,Ups,Lyr: Byte;
  Gli: Integer;
  Gl2: Integer;
  Gl3: Integer; { added 4-22-19 for a third glissando }
  { NoteFile: File of VisNoteType; }
  TotalNotes: LongInt;
  TotalMacros: Integer;
  MacroList:Record
                  First: MacroPtr;
                  Current: MacroPtr;
              end;
  DelayKeyPress: Integer;
  SampleCount: Byte;

(*{$i DectoHex.Inc }*)

Procedure Init;

var I,Io: Integer;

Begin
  For i := 0 to 12 do CallsToMyRandom[i] := 0;
  Assign(xref,'xref.txt');
  {$i-}
  ReWrite(xref);  { open for Writing }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Create xref file failed. Io = ',io);
      Writeln('File was called xref.txt');
      Halt(Io);
    end;
  Writeln('In Init');
  {Writeln('Total memory avail: ,MemAvail,MaxAvail Not available in Free Pascal');}
  For i := 0 to MaxChans do
    Begin
      { Channels[i].First := Nil; }{ Make all channels empty }
      Channels[i].First := -1;
      Channels[i].Instrument := 0;
      Channels[i].FunctionTable := 0;
    end;
  for i := 0 to McGillSamples do
    Begin
      McGillDesc[i].Used := False;
      McGillDesc[i].SampleNumber := 0;
    End;
  FunctionTableNumber := 600; { updated 4-7-17 to move sample tables above the Glides, which are now up to 536 }
  StartOfFunctionTable := 'f1 0 64 -2 0 '; { locations of start of function tables }
  MonoStereoAkaiTable := 'f2 0 64 -2 0';  { 4= akai sample points }
  McGillDescIndex := 0;
  McGillRelativeNum := 0;
  MaxDuration := 0;
  MacroList.First := Nil;
  MacroList.Current := Nil;
  DelayKeyPress := 0;
  TotalNotes := 0;
  TotalMacros := 0;
  Cha := 0; { channel }
  Oct := 3; { octave }
  Mul := 35; { Amplitude Multiplicand - intensity }
  Env := 0; { envelope to use 0 = 197, 1 = 196, 2 = 195 etc. }
  Ton := 0;  { tone in scale }
  Lyr := 0;  { LyricNumber }
  Ovv := 0;  { overall volume level }
  Ntp := 0;  { overall Tempo level }
  Vel := 0;  { velocity or volume }
  Ran := 16; { random play or silence }
  Ste := 8; { stereo placement }
  Hol := 0; { hold note for how long }
  War := 0; { Right Channel Envelope - if 0 then same as Env }
  Pat := 8; { 8 is standard random wild card parse; <8 is less repeat >8 is mostly repeat }
  Raf := 0; { default is zero, don't use a random number file. any other use random-xx.dat }
  Per := 0; { default is no perturbation }
  Gli := 0; { default is no glissando }
  Gl2 := 0; { default is no 2nd glissando }
  Gl3 := 0; { default is no 3rd glissando }
  Ups := 0; { default is no up sample }
  OldMethod := ParamStr(4) = '1997';
  OldMethod := True;
  MusicLines := 0;
  AutoOctaveShift := ParamStr(4) = '2014';
  Writeln('AutoOctaveShift = ',AutoOctaveShift);
  Val(Copy(ParamStr(5),1,3),Root,Io);
  If Io <> 0 then Root := 72;
  { Warped := False; }
  LowChannel := MaxChans;
  HighChannel := 0;
  Assign(Music,ParamStr(1));
  {$i-}
  ReSet(Music);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find music file failed. Io = ',io);
      Writeln('File was called ',ParamStr(1));
      Halt(Io);
    end;
  Assign(Sco,ParamStr(2));
  {$i-}
  ReWrite(Sco);  { open for Writing }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Create Sco file failed. Io = ',io);
      Writeln('File was called ',ParamStr(2));
      Halt(Io);
    end;
  Assign(Csv,ParamStr(1) + '.csv');
  {$i-}
  ReWrite(Csv);  { open for Writing }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Create Csv file failed. Io = ',io);
      Writeln('File was called ',ParamStr(1),'.csv');
      Halt(Io);
    end;
  Assign(Ovf,ParamStr(3));
  {$i-}
  ReWrite(Ovf);  { open for Writing }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Create Ovf file failed. Io = ',io);
      Writeln('File was called ',ParamStr(3));
      Halt(Io);
    end;
  Assign(McGill,'McGill.dat');
  {$i-}
  ReSet(McGill);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find McGill Sample Description file. Io = ',io);
      Writeln('File was called McGill.dat');
      Halt(Io);
    end;
  Assign(AudNoteFile,'Notes.fil');
  {$i-}
  ReWrite(AudNoteFile);
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to create AudNoteFile failed. Io = ',io);
      Writeln('File was called Notes.fil');
      Halt(Io);
    end;
  Assign(ChannelFile,'Chann.fil');
  {$i-}
  ReWrite(ChannelFile);
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to create ChannelFile failed. Io = ',io);
      Writeln('File was called Chann.fil');
      Halt(Io);
    end;
  Assign(Randfile1,'random-1.dat');
  {$i-}
  ReSet(Randfile1);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-1.dat');
      Halt(Io);
    end;

  Assign(Randfile2,'random-2.dat');
  {$i-}
  ReSet(Randfile2);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-2.dat');
      Halt(Io);
    end;

  Assign(Randfile3,'random-3.dat');
  {$i-}
  ReSet(Randfile3);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-3.dat');
      Halt(Io);
    end;

  Assign(Randfile4,'random-4.dat');
  {$i-}
  ReSet(Randfile4);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-4.dat');
      Halt(Io);
    end;

  Assign(Randfile5,'random-5.dat');
  {$i-}
  ReSet(Randfile5);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-5.dat');
      Halt(Io);
    end;

  Assign(Randfile6,'random-6.dat');
  {$i-}
  ReSet(Randfile6);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-6.dat');
      Halt(Io);
    end;

  Assign(Randfile7,'random-7.dat');
  {$i-}
  ReSet(Randfile7);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-7.dat');
      Halt(Io);
    end;

  Assign(Randfile8,'random-8.dat');
  {$i-}
  ReSet(Randfile8);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-8.dat');
      Halt(Io);
    end;

  Assign(Randfile9,'random-9.dat');
  {$i-}
  ReSet(Randfile9);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-9.dat');
      Halt(Io);
    end;

  Assign(RandfileA,'random-10.dat');
  {$i-}
  ReSet(RandfileA);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-10.dat');
      Halt(Io);
    end;

  Assign(RandfileB,'random-11.dat');
  {$i-}
  ReSet(RandfileB);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-11.dat');
      Halt(Io);
    end;

  Assign(RandfileC,'random-12.dat');
  {$i-}
  ReSet(RandfileC);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-12.dat');
      Halt(Io);
    end;

  { set the 2000 to the beats per minute factor in the file. Someday read it from the file. later }
  { this seems like a lot of dead code. 12-31-16. Take a look at why I did this some day }
  TimeFactor := 1 / 2000 * 2646000;  { 2000 beats per minute }
  TimeFactor := 1 / 480 * 2646000;  { 480 beats per minute }
  TimeFactor := 1 / 5200 * 2646000;  { 5200 beats per minute - time factor ~ 50 }
  Writeln('TimeFactor: ',TimeFactor);
end; { Init }

Function MyRandom(MaxValue,FileToRead: Integer): Integer;
(* Modification of randomization algorithm 12/26/16
  Goal is to be able to either do the normal random thing that Pascal does, or
  to read the next sequential random number from up to ten files of up to 250,000 random numbers each.

  Generate the random file with values between 0 and 1, and then multiply it by the
  MaxValue when the funtion is called. For example, generate a file with 250k random numbers like this,
  or a binary representation of these values:

    0.7656498470487
    0.4650250714942
    0.4735189315579
    0.2654021118206
    0.5619755515020
    0.5558796246562
    0.9731881973878
    0.7007745748483
    0.4312899372006
    0.0520914127049

  I still want to use the P pat value to determine how to use the random numbers, Markov Chain Drunkard's Walk, etc.
  Instead B value raf tells us what random number file to use.
  For example, b0 would not use a file, but rather just generate as I always have.
  b1 would read the next random number from a file called random-1.dat.
  b2 would read the next random number from a file called random-2.dat. and so on.

  b255 resets to the start of all the files. Maybe it would be better to reset individual files instead? Later.

  I will need a variable to tell me which random number file to use. Let's call it the B value for Raf.

  I've pre-opened the files at program initiation, so that all I have to do here is read the next number.

  Maybe would be nice to start at the nth record in the random number file. Later.
  Current problem. The path through the randomizer is different if it's the first time picking an alternative.
  For example, &chor-x*. choses from the list of .chor-x1 - x16 choices. If it's the first time, it picks one at
  random. The second time, it picks the next or previous choice. Need a way to control this. Easier said than done.

  So, I've figured out why the design doesn't work. The random number generator for the Markov Chain Drunkard's
  Walk returns the next or previous item in the list as it exists at the moment. If the last item was number 8,
  then the next one is either 7 or 9. So if you go through the routine twice, the first time with item number 8,
  and the next time with item number 4, you get different results for the second time through the routine
  than the first time through. Duh.

  If Pat = 8, then replication of a list is possible, only barely, with random numbers from a file.
  But sometimes it picks a differnt one anyway.


*)

{ Assume the RandFile-x is open prior to getting here }

Procedure ResetRandomFiles;

var IO: integer;

Begin
  { Writeln(xref,'Inside ResetRandomFiles'); }
  {$i-}
  Reset(Randfile1);
  Reset(Randfile2);
  Reset(Randfile3);
  Reset(Randfile4);
  Reset(Randfile5);
  Reset(Randfile6);
  Reset(Randfile7);
  Reset(Randfile8);
  Reset(Randfile9);
  Reset(RandfileA);
  Reset(RandfileB);
  Reset(RandfileC);
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Attempt to Find random number file failed. Io = ',io);
      Writeln('File was called random-12.dat');
      Halt(Io);
    end;
  For Io := 0 to 255 do CallsToMyRandom[Io] := 0;
End; { ResetRandomeFiles }

var
  RandomReal: Real;
  ReturnValue: Integer;
  { 609 }
Begin
  RandomReal := 0;
  CallsToMyRandom[FileToRead] := CallsToMyRandom[FileToRead] + 1;
  { Writeln(xref,'Inside MyRandom. MaxValue = ',MaxValue,' FileToRead = ',FileToRead,' Calls to read this: ',CallsToMyRandom[FileToRead]); }
  Case FileToRead of
    0: ReturnValue := Random(MaxValue);
    1: Read(Randfile1,RandomReal);
    2: Read(Randfile2,RandomReal);
    3: Read(Randfile3,RandomReal);
    4: Read(Randfile4,RandomReal);
    5: Read(Randfile5,RandomReal);
    6: Read(Randfile6,RandomReal);
    7: Read(Randfile7,RandomReal);
    8: Read(Randfile8,RandomReal);
    9: Read(Randfile9,RandomReal);
    10: Read(RandfileA,RandomReal);
    11: Read(RandfileB,RandomReal);
    12: Read(RandfileC,RandomReal);
    255: ResetRandomFiles;
    Else
      Begin
        Writeln('Invalid Random File value. "',FileToRead,'"');
        Halt(3);
      end
    end; { case }
  If FileToRead = 0 then
    Begin
      { Writeln(xref,'Returning value: ',ReturnValue,' out of MaxValue: ',MaxValue); }
      MyRandom := ReturnValue;
    end
  Else if FileToRead = 255 then
    Begin
      { Writeln(xref,'reset all files to beginning'); }
      MyRandom := 0;
    end
  Else
    Begin
      { Writeln(xref,'RandomReal = ',RandomReal:1:5,' Returning value: ',Trunc(RandomReal * Maxvalue),' out of MaxValue: ',MaxValue); }
      MyRandom := Trunc(RandomReal * Maxvalue);
    end;

End; { MyRandom }

Procedure ExpandMcGill(Channel,Ins: Byte);

var
  FoundIns: Boolean;
  i: integer;

Procedure ParseMcGill(Ins,FtabNum: Byte);

var
  Found: Boolean;
  RangeTable, FunctionTable, CentsTable, LoopTable: String;
  TopOfRangeBaseNumber,FunctionTableName,InstrumentNumber,TableNumber: String;
  BaseNumber,Code,Io: Integer;
  SampleOffset: Integer;

Begin
  Found := False;
  {$i-}
  ReSet(McGill);  { open for reading }
  {$i+}
  Io := Ioresult;
  If Io <> 0 then
    Begin
      Writeln('Could not find "McGill.dat" in current Directory. Io = ',io);
      Halt(Io);
    end;
  Str(Ins:3,InstrumentNumber);
  Repeat
    Readln(McGill,Input);
    Found := (Copy(Input,1,3) = InstrumentNumber);
  Until Eof(McGill) or (Found);
  If Not Found then
    Begin
      Writeln('Could not find instrument #',Ins:4,' in McGill.dat');
      Halt(4);
    end
  Else
    Begin { Found the first of several lines referring to the instrument }
      SampleCount := 0;
      FunctionTableNumber := FunctionTableNumber + 1;
      Str(FunctionTableNumber,TableNumber); { Start with 600 }
      StartOfFunctionTable := StartOfFunctionTable + TableNumber + ' ';
      { changed 5-4-17 to move the sample type directly in to the MonoStereoAkaiTable }
      MonoStereoAkaiTable := MonoStereoAkaiTable +  ' ' + Copy(Input,6,1);
      { Note that some percussion ensembles have a mix of mono and stereo in the same directory }
      RangeTable := 'f' + TableNumber + ' 0 128 -17 0 ';
      FunctionTableNumber := FunctionTableNumber + 1;
      Str(FunctionTableNumber,TableNumber);
      { 11/24/05 - increased the number of samples per instrument to 64 }
      FunctionTable := 'f' + TableNumber + ' 0 64 -2 0 ';
      FunctionTableNumber := FunctionTableNumber + 1;
      Str(FunctionTableNumber,TableNumber);
      CentsTable := 'f' + TableNumber + ' 0 64 -2 0 ';
      FunctionTableNumber := FunctionTableNumber + 1;
      Str(FunctionTableNumber,TableNumber);
      LoopTable := 'f' + TableNumber + ' 0 64 -2 0 ';
      McGillRelativeNum := 0;
      Repeat  { write the name of the sample file name for each sample }
        FunctionTableNumber := FunctionTableNumber + 1;
        SampleCount := SampleCount + 1;
        { Store the Function table number in the McGillDesc.FunctionTableNum field }
        Str(FunctionTableNumber,FunctionTableName);
        McGillDesc[McGillDescIndex].FTable := Copy(Input,23,255); { file name of this sample }
        { moved from 19 to 23 1/1/02 for CentsTable }
        { moved from 14 to 19 3/31/01 for MoveForward }
        Val(Copy(Input,8,3),BaseNumber,Code);
        If Code <> 0 then
          Begin
            Writeln('Invalid base number for instrument sample. Sample name: "',Input,'"');
            Halt(4);
          end;
        Str(BaseNumber+1,TopOfRangeBaseNumber); { Should be average of this and next number }
        RangeTable := RangeTable + FunctionTableName + ' ' + TopOfRangeBaseNumber + ' ';
        { enhanced on 4-19-17 to allow for more samples per sample set, spill over to another line of the SCO file }
        If Length(RangeTable) > 240 then
          Begin
            Writeln(Sco,RangeTable); { if it's almost too long, write it out and null the RangeTable variable }
            RangeTable := '  ';
          end;
        FunctionTable := FunctionTable + Copy(Input,8,3) + ' '; { BaseNumber 55,57,59 etc. }
        CentsTable := CentsTable + Copy(Input,19,4); { Read cent adjustment from McGill 1/1/02 }
        { CentsTable := CentsTable + ' 0 ';  Assume the samples are in tune. Oh Really? 1/1/02 looking here }
        LoopTable := LoopTable + Copy(Input,12,1) + ' ';
        McGillDesc[McGillDescIndex].FunctionTableNum := FunctionTableNumber;
        { 4-9-12 find the lowest and highest base notes in the sample set }
        { 12/2/19 reset the max function table number to 1500 from 1200. No idea why }
        If FunctionTableNumber > 1500 then
          Begin
            Writeln('Too many instruments. Attempt to set FunctionTableNumber > 1500');
            Halt(5);
          end;
        Val(Copy(Input,14,4),SampleOffset,Code); { 3/31/01 for MoveForward }
        If Code <> 0 then
          Begin
            Writeln('Invalid sample offset for instrument sample. Sample name: "',Input,'"');
            Halt(4);
          end;
        { SampleOffset is an integer count of the number of samples before the real start of the note.
          All else is leading sound }
        McGillDesc[McGillDescIndex].MoveForward := SampleOffset / TimeFactor; { 3/31/01 for MoveForward }
        { MoveForward is a single precision count of beats, based on TimeFactor (2000 for now) }
        McGillDesc[McGillDescIndex].BaseNote := BaseNumber;
        { ########## }
        McGillDesc[McGillDescIndex].Channel := FTabNum;
        { ########## }
        { McGillDescIndex stores the relative sample in all sets. }
        McGillRelativeNum := McGillRelativeNum + 1;
        McGillDesc[McGillDescIndex].SampleNumber := McGillRelativeNum;
        {Writeln(xref,'McGillDesc[',McGillDescIndex,'].SampleNumber = ',McGillDesc[McGillDescIndex].SampleNumber);}
        McGillDescIndex := McGillDescIndex + 1;
        If McGillDescIndex > McGillSamples then
          Begin
            Writeln('Too many samples to handle. Max is ',McGillSamples);
            Halt(5);
          end;
        Repeat
          Readln(McGill,Input); { look out for comment lines }
        Until (Copy(Input,1,1) <> ';') or (eof (McGill));
        Found := (Copy(Input,1,3) = InstrumentNumber);
      Until (Not Found) or (Eof(McGill));
      (*
      For j := Length(RangeTable)-1 downto 1 do
          If RangeTable[j] = ' ' then
            Begin                 { fix the last number. It must be 127, not 1+base }
              RangeTable := Copy(RangeTable,1,j) + '127';
              j := 1;
            end;
            *)
      Writeln(Sco,RangeTable); { need to modify the last entry }
      Writeln(Sco,FunctionTable);
      Writeln(Sco,CentsTable);
      Writeln(Sco,LoopTable);
    end;
end; { ParseMcGill }

Begin { ExpandMcGill }
  { Find out if there have been any other requests for this instrument # }
  MaxTableSlot := 0;
  FoundIns := False;
  i := 0;
  While (i < MaxChans) and (Not FoundIns) do
    Begin
      if Channels[i].FunctionTable > MaxTableSlot then
            MaxTableSlot := Channels[i].FunctionTable;
      if Channels[i].Instrument = Ins then
        Begin
          FoundIns := True;
          Channels[Channel].FunctionTable := Channels[i].FunctionTable;
          { if the first channel is 40, why is the second lowsample set to 36? }
          Channels[Channel].NumSamples := Channels[i].NumSamples;
          {Writeln(xref,'Copy from another instrument. Channels[',Channel,
                  '].NumSamples = ',Channels[Channel].NumSamples);}
        end;
      i := i + 1;
    end;
  Channels[Channel].Instrument := Ins;
  If (Not FoundIns) then
     Begin
       { must now build the .sco function tables for this note }
       Channels[Channel].FunctionTable := MaxTableSlot+1;
       ParseMcGill(Ins,Channels[Channel].FunctionTable);
       Channels[Channel].NumSamples := SampleCount;
       {Writeln(xref,'Channels[',Channel,'].NumSamples = ',Channels[Channel].NumSamples);}
     end;
end; { ExpandMcGill }

{ 3-23-12 extended glissando to an integer value }
{12-07-19 added intensity varible as amplitude multiplicand }
{Procedure LoadValues(Channel,Oct,ToneInScale,Vel,Ran,Ste,Env,Per,Gli,Ups,Ovv: Byte; Ntp,Dur,Hol,War,Lyr:Integer);}
Procedure LoadValues(Channel,Oct,Mul,ToneInScale,Vel,Ran,Ste,Env,Per,Ups,Ovv: Byte; Ntp,Dur,Hol,War,Lyr,Gli,Gl2,Gl3,MusicLines:Integer);

Var
  WhereAreWe: Longint;
  TempNote: AudNoteType;

Begin
  DelayKeyPress := DelayKeyPress + 1;
  If DelayKeyPress > 20000 then
    Begin
      If KeyPressed then Halt(1);
      DelayKeyPress := 0;
    end;
  If Channel < LowChannel then LowChannel := Channel;
  If Channel > HighChannel then HighChannel := Channel;
  TotalNotes := TotalNotes + 1;
  If (TotalNotes mod 1000 = 0) or (TotalNotes = 1) then
      Writeln('Created note  ',TotalNotes:6);
  WhereAreWe := FileSize(AudNoteFile); { new note always goes at the end }
  If Channels[Channel].First = -1 then Channels[Channel].First := WhereAreWe
  else
    Begin
      Seek(AudNoteFile,Channels[Channel].Current);
      Read(AudNoteFile,TempNote);
      TempNote.Next := WhereAreWe; { currently at the end of the file }
      Seek(AudNoteFile,Channels[Channel].Current);
      Write(AudNoteFile,TempNote);
    end;
  { Need to find the current one, and update its next pointer }
  AudNote.Octave := Oct;
  AudNote.Mult := Mul;
  AudNote.ToneInScale := ToneInScale;
  AudNote.Velocity := Vel;
  AudNote.Rand := Ran;
  AudNote.Ranf := Raf;
  AudNote.Stereo := Ste;
  AudNote.Envelope := Env;
  AudNote.Duration := Dur;
  AudNote.HoldDuration := Hol;
  AudNote.WarEnvelope := War;
  AudNote.LyricNumber := Lyr;
  AudNote.NowVolume := Ovv;
  AudNote.NowTempo := Ntp;
  AudNote.Perturb := Per;
  AudNote.Glisand := Gli;
  AudNote.Glisand2 := Gl2;
  AudNote.Glisand3 := Gl3;
  AudNote.Upsample := Ups;
  AudNote.Next := -1;
  AudNote.LineNum := MusicLines;
  Seek(AudNoteFile,WhereAreWe);
  Write(AudNoteFile,AudNote); { Store this note in notes.fil at the next available position }
  Channels[Channel].Current := WhereAreWe;      { Where are we in the file }
end; { LoadValues }

Procedure ReadValues(Var Input:String);

var
  i: byte;

Begin
  Readln(Music,Input);
  MusicLines := MusicLines + 1;
  {Writeln(xref,'         1         2         3         4         5         6         7         8');}
  {Writeln(xref,'12345678901234567890123456789012345678901234567890123456789012345678901234567890');}
  {Writeln(xref,Input);                                                                             }
  Input := Input + ' ';
  i := 1;
  Repeat
    If Copy(Input,i,2) = '  ' then Delete(Input,i,1)
    else i := i + 1;
  Until (i = Length(Input));
end; {ReadValues}

Procedure ParseValues(Input:String);

Var
  InputPos: Byte;
  Notes : Boolean;

Procedure StoreMacro(MacroName,Content:String);

Var
  Macro: MacroPtr;
  {Found: Boolean;}
  Current: MacroPtr;
  LeadingBlanks: Boolean;

Begin
  {Writeln('In StoreMacro. MacroName = "',MacroName,'" Content = "',Content,'"');}
  Repeat
    LeadingBlanks := Copy(Content,1,1) = ' ';
    If LeadingBlanks then Content := Copy(Content,2,Length(Content));
  Until (Not LeadingBlanks);
  {Writeln('About to set Current := MacroList.First');}
  { the next line is what triggers the error 216.}
  { Free Pascal does not permit referencing variables with Nil addresses }
  { You must be sure the variable is not Nil before referencing it }
  Current := MacroList.First;
  {Writeln('Current = Nil is ',Current=Nil);}
  { See if this Macro is already in the current list of Macros }
  If Current <> Nil then
        While (Current <> Nil) and (Current^.Name <> MacroName) do
              Current := Current^.Next;
  If Current = Nil then
    Begin
      {Writeln('Current = Nil. About to call New(Macro).');}
      New (Macro);
      TotalMacros := TotalMacros + 1;
      If (TotalMacros mod 500 = 0) or (TotalMacros = 1) then
          Writeln('Created macro ',TotalMacros:6);
      If MacroList.First = Nil then MacroList.First := Macro
      else MacroList.Current^.Next := Macro;
      Macro^.Name := MacroName;
      { Check first to make sure it will fit }
      If Length(Content) > MaxMacroLength then
        Begin
          Writeln('Macro named "',MacroName,'" is too long');
          Writeln('    Truncating "',Content,'"');
          Writeln('Only room for "',Copy(Content,1,MaxMacroLength),'"');
          Writeln(Length(Content),' > ',MaxMacroLength);
          Halt(1);
        end;
      Macro^.Content := Content;
      Macro^.LastChosen := False;
      Macro^.ChosenTimes := 0;
      Macro^.Next := Nil;
      MacroList.Current := Macro;
    end
  Else
    Begin
    {1055}
    { 6/23/19. Need to put out a message when you do this. You may have done it by mistake }
    { start here: need an exclusion list for things like &init. which will always be redefined }
    { one idea: pick a first letter for the macros that you don't care about their redefinition. }
    { what letter should be the trigger? #macroname? }
      Write(xref,'Rdfine Mac: ');
      Write(xref,'.',MacroName);
      Write(xref,'   "',Current^.Content,'"');
      Writeln(xref,'   "',Content,'"');
      Current^.Content := Content; { replace the contents of the existing macro }
    end;
end; { StoreMacro }

Procedure DefineMacro(MacroName:String);

{ This procedure is passed the line following the . in a macro
  definition. The Procedure then stores everything following
  the space after the macro name as the contents of the macro.
  e.g. '.melody t+0 t+10 t+10', would store
  't+0 t+10 t+10' in the macro melody }

Var
  i: Byte;
  Blank: Boolean;
  Content: String;

Begin
  {Writeln('In DefineMacro. MacroName = "',MacroName,'"');}
  Blank := False;
  i := 0;
  Repeat
    i := i + 1;
    If Copy(MacroName,i,1) = ' ' then Blank := True;
  Until (i = Length(MacroName)) or Blank;
  {Writeln('Blank = ',Blank,' i = ',i,' MacroName = "',MacroName,'"');}
  {Writeln('i+1 = ',i+1,' length(MacroName) = ',Length(MacroName));}
  Content := Copy(MacroName,i+1,Length(MacroName));
  {Writeln('Content = "',Content,'"');}
  If Blank then MacroName := Copy(MacroName,1,i-1)
  Else
    Begin
      Writeln('Invalid macro. Name too long or no content in "',MacroName,'"');
      Halt(2); { quit the bat file }
    end;
  {Writeln('In DefineMacro. About to store macro named "',MacroName,'" with content: "',Content,'"');}
  StoreMacro(MacroName,Content);
  InputPos := Length(Input);
end; { DefineMacro }

Procedure ExpandMacro(MacroName:String);

Var
  i,j : Byte;
  BlankOrDot: Boolean;
  PreDeAmpLen, PostDeAmpLen: Byte;
  Name: String;
  Current: MacroPtr;
  PotentialContents: Array [0..128] of MacroPtr; { increased size to 128 members to avoid runtime error 216 General Protection Fault. 5-2-2020 }
  PotentialIndex: Integer;
  ChosenIndex, Least: Byte;
  FixedPortion: String;
  Done: Boolean;

{ Passed a string with some number of ampersand macros, expands them inside out to return final string }
Function DeAmpersand(Name: String): String;

Var
  i,AmpersandLoc,DotLoc: Byte;
  Ampersand,Dot: Boolean;
  PreAmp, MacroName, PostDot: String[MaxMacroNameLength];
  Temp: String[MaxMacroNameLength];

Begin
  { If you discover a dot before you find an ampersand, you've found a normal macro. }
  { If you find a ampersand before a dot, this is a macro within a marco }
  i := 0;
  Ampersand := False;
  Dot := False;
  Repeat
    i := i + 1;
    Ampersand := (Copy(Name,i,1) = '&');
    Dot := (Copy(Name,i,1) = '.');
    If Dot then DotLoc := i;
  Until (i = Length(Name)) or Ampersand;
  AmpersandLoc := i;
  i := 0;
  Dot := False;
  Repeat
    i := i + 1;
    Dot := (Copy(Name,i,1) = '.');
  Until (i = Length(Name)) or Dot;
  If Dot then DotLoc := i Else DotLoc := 0;
  If AmpersandLoc < DotLoc then
    Begin
      (*
      Writeln('found an Ampersand at ',AmpersandLoc,' and a Dot at ',DotLoc);
      *)
      PreAmp := Copy(Name,1,AmpersandLoc-1);
      MacroName := Copy(Name,AmpersandLoc+1,DotLoc-(AmpersandLoc+1));
      PostDot := Copy(Name,DotLoc+1,Length(Name)-DotLoc);
      (*
      Writeln('Preamp = "',PreAmp,'" MacroName = "',MacroName,'" PostDot = "',PostDot,'"');
      *)
      { Need to reset current to first element in the linked list }
      Current := MacroList.First;
      While (Current <> Nil) and (Current^.Name <> MacroName) do
          Current := Current^.Next;
      If Current = Nil then
        Begin
          { 5/20/19 I really need to beef up this error message. I've spent the last 20 minutes looking for
            a declaration of &sidm*., which I've done before. If only I knew which line was being parsed at the time of the error }
          Writeln('Macro Not Found. Name = "',MacroName,'"');
          Writeln('Text before the ampersand: "',PreAmp,'"');
          Writeln('Text after the dot: "',PostDot,'"');
          Close(xref);
          Halt(3); { quit the bat file }
        end
      Else
        Begin { found the macro in the list of macros }
          { Keep track of how often it has been called }
          Current^.ChosenTimes := Current^.ChosenTimes + 1;
          Current^.LastChosen := True; { do you want to set this even if it is chosen explicitly? I guess so. }
          { Pass the contents of the macro as if it just regular values in the file }
          Temp := PreAmp + Current^.Content + PostDot;
        end;
      {Writeln('Passing Temp = "',Temp,'" to DeAmpersand');}
      Name := DeAmpersand(Temp);
      {Writeln('Back from passing Temp to DeAmpersand. Name = "',Name,'"');}
    end;
  DeAmpersand := Name;
end; {DeAmpersand}

Function Asterisk(Name: String):Boolean;
{ returns true if it ends in an asterisk }


Begin
  Asterisk := Name[Length(Name)] = '*';
end; { Asterisk }

Begin  { ExpandMacro }
  { Find out how long macro is }
  { leading first ampersand has already been stripped off }
  { store the length of the whole MacroName before being DeAmpersanded }
  PreDeAmpLen := Length(MacroName);
  (*
  Writeln('In ExpandMacro with MacroName = "',MacroName,'" InputPos = ',InputPos);
  Writeln('Before DeAmpersand MacroName = "',MacroName,'"');
  *)
  MacroName := DeAmpersand(MacroName); { resolve a macro within a macro }
  PostDeAmpLen := Length(MacroName);
  (*
  Writeln('After DeAmpersand MacroName = "',MacroName,'"');
  *)
  BlankOrDot := False;
  i := 0;
  { This section does a very poor job of error handling. There has to be a
    better way to handle a missing dot at the end of macro name }
  Repeat
    i := i + 1;
    If (Copy(MacroName,i,1) = ' ') or (Copy(MacroName,i,1) = '.')
          then BlankOrDot := True;
  Until (i = Length(MacroName)) or BlankOrDot;
  If BlankOrDot then
    Begin
      { need to make sure we advance InputPos by the right length. }
      { It should advance by the number of bytes before its internal macros are resolved }
      InputPos := InputPos + i +(PreDeAmpLen - PostDeAmpLen);
      Name := Copy(MacroName,1,i-1);
    end
  Else
    Begin
      Writeln('A Macro near the one Named "',Name,'" had a problem. It could be one of the following:');
      Writeln('It did not terminate in a dot as it should have');
      Writeln('or it was over 248 characters long, ');
      Writeln('or the name was over ',MaxMacroNameLength,' long ');
      Writeln('or there is a missing x at the end of a redirect macro');
      Writeln('or something else I have failed to properly document. Sorry!');
      Writeln('Processing line containing:');
      Writeln('"',Input,'"');
      Halt(3); { quit the bat file }
    end;
  { At this point Name consists of the macro with leading ampersand and the trailing dot stripped off. }
  { If there was an ampersand inside the name it has been resolved by now }
  { Name has been altered to be the resolved name with no internal ampersands left }
  { Find the macro name in the list of macro names }
  { See if the macro ends with an asterisk, which would indicate that }
  {  the name could be one of many that match up to the asterisk }
  { 5-2-2020 there seems to be a hard limit on 100 different choices before I get a
    Runtime error 216, General Protection Fault. access memory out of bounds in line 1338}
  {Writeln(xref,'InputPos = ',InputPos);}
  Current := MacroList.First;
  If Asterisk(Name) then
    Begin
      PotentialIndex := 0;
      FixedPortion := Copy(Name,1,Length(Name)-1); { drop the asterisk from the end }
      Done := False;
      Repeat { examine every macro to find all the ones that match }
        While (Current <> Nil) and
              (Copy(Current^.Name,1,Length(FixedPortion)) <> FixedPortion)
                   do Current := Current^.Next; { do the letters up to the asterisk match?}
        If Current = Nil then Done := True
        Else
          Begin { store this macro address in an array of potential macros }
            PotentialContents[PotentialIndex] := Current;
            PotentialIndex := PotentialIndex + 1;
            If PotentialIndex = 200 then
              Begin
                Writeln('Too many similar macros');
                Writeln('Macro called "',Name,'"');
                Halt(1);
              end;
            Current := Current^.Next;
          end;
      Until (Done);
      If PotentialIndex > 0 then
        Begin
          { start here. Need to track the "pump priming" of the lists. The first time through asks for more random #s }
          { pick a random number from zero to one less than the number of potential choices }
          (*
          Writeln(xref,Name,' Pat = ',Pat,' PotentialIndex = ',PotentialIndex);
          *)
          If Pat = 8 then
            Begin
              { Writeln(xref,'line 1219. Pat = ',Pat,' PotentialIndex = ',PotentialIndex,' Raf = ',Raf); }
              ChosenIndex := MyRandom(PotentialIndex,Raf);
            end
          Else if Pat = 0 then
            Begin { pick least chosen macro in the list of potential candidates. }
              Least := MyRandom(PotentialIndex,Raf); { Start with a random pull }
              {Writeln(xref,'line 1226. PotentialIndex = ',PotentialIndex,' Raf = ',Raf); }
              For j := 0 to PotentialIndex - 1 do { swap if another is least used }
                    If PotentialContents[j]^.ChosenTimes <
                          PotentialContents[Least]^.ChosenTimes then Least := j;
              ChosenIndex := Least; { save the result }
            end
          Else if Pat = 32 then
            Begin { repeat the last one chosen, not random }
              j := 0;
              While (j < PotentialIndex) and not (PotentialContents[j]^.LastChosen) do
                  j := j + 1;
              If j = PotentialIndex then
                Begin
                  {Writeln(xref,'line 1239. PotentialIndex = ',PotentialIndex,' Raf = ',Raf);}
                  ChosenIndex := MyRandom(PotentialIndex,Raf)
                end
              else ChosenIndex := j;
            end
          Else if Pat = 35 then
            Begin { Markov Drunkard's Walk: Either the next or the previous }
              {Writeln(xref,'decide if go forward or back in MCDW line 1234.  Raf = ',Raf);}
              If MyRandom(2,Raf) = 0 then
                Begin { Get the next one in the list }
                  j := 0;
                  { start here. Need to track the "pump priming" of the lists. The first time through asks for more random #s }
                  While (j < PotentialIndex) and not (PotentialContents[j]^.LastChosen) do
                      j := j + 1;
                  If j = PotentialIndex then
                    Begin
                      {Writeln(xref,'line 1242. PotentialIndex = ',PotentialIndex,' Raf = ',Raf,' FixedPortion "',FixedPortion,'"');}
                      j := MyRandom(PotentialIndex,Raf);
                      ChosenIndex := j;
                    end
                  else if j+1 = PotentialIndex then
                    Begin
                      j := 0;
                      ChosenIndex := j;
                    end
                  else
                    Begin
                      j := j + 1;
                      ChosenIndex := j;
                    end;
                end
              Else
                Begin { Get the previous one in the list }
                  j := 0;
                  { start here. Need to track the "pump priming" of the lists. The second time through it's not done }
                  While (j < PotentialIndex) and not (PotentialContents[j]^.LastChosen) do
                      j := j + 1;
                  If j = PotentialIndex then
                    Begin
                      {Writeln(xref,'line 1265. PotentialIndex = ',PotentialIndex,' Raf = ',Raf,' FixedPortion "',FixedPortion,'"');}
                      j := MyRandom(PotentialIndex,Raf);
                      ChosenIndex := j;
                    end
                  else if j <> 0 then
                    Begin
                      j := j - 1;
                      ChosenIndex := j;
                    end
                  else
                    Begin
                      j := PotentialIndex - 1;
                      ChosenIndex := j;
                    end;
                end
            end
          Else if Pat = 33 then
            Begin { pick the next one in the series, not random }
              j := 0;
              While (j < PotentialIndex) and not (PotentialContents[j]^.LastChosen) do
                  j := j + 1;
              If j = PotentialIndex then
                Begin
                  {Writeln(xref,'line 1288. PotentialIndex = ',PotentialIndex,' Raf = ',Raf);}
                  j := MyRandom(PotentialIndex,Raf);
                  ChosenIndex := j;
                end
              else if j+1 = PotentialIndex then
                Begin
                  j := 0;
                  ChosenIndex := j;
                end
              else
                Begin
                  j := j + 1;
                  ChosenIndex := j;
                end;
            end
          Else if Pat = 34 then
            Begin { pick the previous one in the series, not random }
              j := 0;
              While (j < PotentialIndex) and not (PotentialContents[j]^.LastChosen) do
                  j := j + 1;
              If j = PotentialIndex then
                Begin
                  {Writeln(xref,'line 1310. PotentialIndex = ',PotentialIndex,' Raf = ',Raf);}
                  j := MyRandom(PotentialIndex,Raf);
                  ChosenIndex := j;
                end
              else if j <> 0 then
                Begin
                  j := j - 1;
                  ChosenIndex := j;
                end
              else
                Begin
                  j := PotentialIndex - 1;
                  ChosenIndex := j;
                end;
            end
          Else if Pat < 8 then
            Begin { try to not pick the same one you picked for this macro last time }
              j := 8;
              Repeat
                {Writeln(xref,'line 1329. PotentialIndex = ',PotentialIndex,' Raf = ',Raf);}
                ChosenIndex := MyRandom(PotentialIndex,Raf);
                (*
                Writeln(xref,'ChosenIndex=',ChosenIndex,' j = ',j,' PotentialIndex = ',PotentialIndex);
                *)
                j := j - 1;
              Until (j < Pat) or (Not PotentialContents[ChosenIndex]^.LastChosen) or (j=0);
            end
          Else
            Begin { Pat => 8 then try to pick the same one you picked for this macro last time }
              j := 8;
              Repeat
                ChosenIndex := MyRandom(PotentialIndex,Raf);
                {Writeln(xref,'line 1342. PotentialIndex = ',PotentialIndex,' Raf = ',Raf);}
                j := j + 1; { if not the same, try one more time }
              Until (j > Pat) or PotentialContents[ChosenIndex]^.LastChosen;
            end;
          {Writeln('PotentialIndex = ',PotentialIndex);}
          { Remember if you chose it this time }
          For j := 0 to PotentialIndex-1 do
            Begin
              (*
              Writeln(xref,'line 1351. j = ',j);
              Writeln(xref,'PotentialContents[',j,'].LastChosen = ',
                   PotentialContents[j]^.LastChosen); *)
                   { Free Pascal has trouble with the next line. Perhaps we need to test
                     if it's pointing to Nil. }
              PotentialContents[j]^.LastChosen := (ChosenIndex = j);
            end;
          PotentialContents[ChosenIndex]^.ChosenTimes :=
                PotentialContents[ChosenIndex]^.ChosenTimes + 1;
          (*
          Writeln(xref,'PotentialContents[ChosenIndex]^.Content = "',
                PotentialContents[ChosenIndex]^.Content,'"');
                *)
          ParseValues(PotentialContents[ChosenIndex]^.Content)
        end
      Else
        Begin
          { for some reason, wild card macros are never reported as missing, just go runtime error 216 }
          Writeln('Wild Card Macro Not Found. Name = "',Name,'"');
          Halt(3); { quit the bat file }
        end
    end
  Else
    Begin { Not asterisk }
      {Writeln('looking for macro "',Name,'"');}
      While (Current <> Nil) and (Current^.Name <> Name) do
        Current := Current^.Next;
      If Current = Nil then
        Begin
          Writeln('Macro Not Found. Name = "',Name,'"');
          Halt(3); { quit the bat file }
        end
      Else
        Begin { found the macro in the list of macros }
          { Keep track of how often it has been called }
          Current^.ChosenTimes := Current^.ChosenTimes + 1;
          Current^.LastChosen := True; { do you want to set this even if it is chosen explicitly? I guess so. }
          { Pass the contents of the macro as if it just regular values in the file }
          {Writeln(xref,'About to send ParseValues this: "',Current^.Content,'"');}
          ParseValues(Current^.Content);
        end;
    end;
end; { ExpandMacro }

Function Extract(Value: Integer;Chars:String):Integer;

Var
  Temp,Code: Integer;
  ValStr: String;

Function Parens(Chars: String): String;

Var
  i: Integer;
  x,y,z: Integer;
  More: Boolean;
  Fact: String[1];
  Result: String;
  Code, Code2: Integer;

Begin
  i := 0;
  More := False;
  Repeat
    i := i + 1;
    If Copy(Chars,i,1) = '(' then More := True;
  Until (i = Length(Chars)) or More;
  If More then
    Begin
      Result := Parens(Copy(Chars,i+1,Length(Chars)-1));
      Chars := Copy(Chars,1,i-1) + Result;
    end;
  Val(Chars, x, Code);
  if Code = 0 then z := x
  else
    Begin
      Fact := Copy(Chars,Code,1);
      Val(Copy(Chars,1,Code - 1),x,Code2);
      Val(Copy(Chars,Code + 1,Length(Chars)-Code),y,Code2);
      If Code2 <> 0 then
            Val(Copy(Chars,Code + 1,Code2-1),y,Code2);
      Case Ord(Fact[1]) of
        Ord('+'): z := x + y;
        Ord('-'): z := x - y;
        Ord('*'): z := x * y;
        Ord('/'): z := x div y;
        Else
          Begin
            Writeln('Invalid factor. "',Fact,'"');
            Halt(3);
          end
      end;
    end;
  Str(z,Result);
  Parens := Result;
end; { Parens }

Begin { Extract }
  Str(Value,ValStr);
  Case Ord(Chars[1]) of
    Ord('('): Val(Parens(Copy(Chars,2,Length(Chars)-1)),Temp,Code);
    Ord('+'),Ord('-'),Ord('*'),Ord('/'):
          Chars := Parens(ValStr + Chars[1] + Copy(Chars,2,Length(Chars)));
  end;
  Val(Chars, Temp, Code);
  if Code = 0 then Temp := Temp
  Else if Code > 1 then Val(Copy(Chars,1,Code-1),Temp,Code)
  Else Temp := 0;
  Extract := Temp;
end; { Extract }


Begin { ParseValues }
  { Oct,ToneInScale,Vel,Dur,Hol,Ran,Ste,Env,War,Lyr }
  Notes := False;
  InputPos := 1;
  {Writeln(xref,'In ParseValues. Input = "',Input,'"');}
  While InputPos < Length(Input)+1 do
    Begin
      Case Ord(Upcase(Input[InputPos])) of
        Ord('@'): InputPos := Length(Input); { Comment Line ignore the rest of the line }
        Ord(';'): Begin { Comment Line that will make it to Csound input }
                    InputPos := Length(Input);
                    Writeln(sco,Input);
                  end;
        Ord('F'): Begin { Pass it to Csound 2nd pass }
                    InputPos := Length(Input);
                    Writeln(Ovf,Copy(Input,2,Length(Input)-1));
                  end;
        Ord('A'): Begin { OverallVolume }
                    Ovv := Extract(Ins,Copy(Input,InputPos+1,7));
                  end;
        Ord('Q'): Begin { OverallTempo }
                    Ntp := Extract(Ins,Copy(Input,InputPos+1,7));
                  end;
        Ord('E'): Begin { Envelope }
                    Env := Extract(Env,Copy(Input,InputPos+1,7));
                    If (Env > 255) then Env := 0;
                    Notes := True;
                  end;
        Ord('N'): Begin   {channel}
                    Num := Extract(Num,Copy(Input,InputPos+1,7)); { Channel number}
                  end;
        Ord('I'): Begin { amplitude multiplicand   }
                    { start here. Make the amplitude multiplicand used here: }
                    { iamp = ampdb(iVel)*3.5 }
                    { unique for every note. Have it compensate for quiet notes without
                      changing the v which is used to change which sample is used v60-v80 }
                    Mul := Extract(Mul,Copy(Input,InputPos+1,7)); { Multiplicand }
                    { InputPos := Length(Input); }
                  end;
        Ord('M'): Begin { voice from McGill.dat file }
                    Ins := Extract(Ins,Copy(Input,InputPos+1,7));
                    ExpandMcGill(Num,Ins);
                    InputPos := Length(Input);
                  end;
        Ord('L'): Begin                        { Literal }
                    InputPos := Length(Input); { Pass it to Csound }
                    Writeln(sco,Copy(Input,2,Length(Input)-1));
                  end;
        Ord('Y'): Begin                           { Lyrics Y  }
                    Lyr := Extract(Lyr,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('C'): Begin                           { Channel }
                    Cha := Extract(Cha,Copy(Input,InputPos+1,7));
                    If (Cha > MaxChans) then Cha := 0;
                    Notes := True;
                  end;
        Ord('O'): Begin                            { Octave }
                    Oct := Extract(Oct,Copy(Input,InputPos+1,7));
                    If (Oct > 15) then Oct := 0;
                    Notes := True;
                  end;
        Ord('T'): Begin                             { Tone in scale }
                    Ton := Extract(Ton,Copy(Input,InputPos+1,7));
                    If (Ton >= Root) then
                      Begin
                        Ton := Ton - Root;
                        If Not AutoOctaveShift then Oct := Oct + 1;
                      end
                    Else if (Ton < 0) then
                      Begin
                        Ton := Root + Ton;
                        If Not AutoOctaveShift then Oct := Oct - 1; { see if not automatically incrementing keeps the octaves under control 3/25/14 }
                      end;
                    Notes := True;
                  end;
        Ord('V'): Begin           { Velocity, Volume }
                    Vel := Extract(Vel,Copy(Input,InputPos+1,7));
                    If (Vel > 200) then Vel := 0;   { changed to 200 9/13/03 }
                    Notes := True;
                  end;
        Ord('R'): Begin            { Random chance of hearing }
                    Ran := Extract(Ran,Copy(Input,InputPos+1,7));
                    if Ran > 16 then Ran := 16
                    else if Ran < 0 then Ran := 0;
                    Notes := True;
                  end;
        Ord('S'): Begin           { Stereo location: s = 0 left 8 = middle 15 = right }
                    Ste := Extract(Ste,Copy(Input,InputPos+1,7));
                    If Ste > 16 then Ste := 0
                    Else if Ste = 0 then Ste := 15;
                    Notes := True;
                  end;
        Ord('D'): Begin             { Duration of note }
                    Dur := Extract(Dur,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('Z'): Begin             { perterb start time }
                    Per := Extract(Per,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord(' '): Begin { Store the previous note for later performance }
                    If Notes then
                          LoadValues(Cha,Oct,Mul,Ton,Vel,Ran,Ste,Env,Per,Ups,Ovv,Ntp,Dur,Hol,War,Lyr,Gli,Gl2,Gl3,MusicLines);
                  end;
        Ord('.'): Begin { define macro }
                    DefineMacro(Copy(Input,InputPos+1,
                          Length(Input)-(InputPos + 1)));
                  end;
        Ord('&'): Begin          { execute macro }
                    {Writeln(xref,'Found a &. "',Copy(Input,InputPos+1,MaxMacroNameLength),'"');}
                    ExpandMacro(Copy(Input,InputPos+1,MaxMacroNameLength));
                    Notes := True;
                  end;
        Ord('H'): Begin           { Hold note for duration }
                    Hol := Extract(Hol,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('W'): Begin               { W_envelpe - right channel envelope }
                    War := Extract(War,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('P'): Begin                { random algorithm }
                    Pat := Extract(Pat,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('G'): Begin                 { glissando }
                    Gli := Extract(Gli,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('J'): Begin                { 2nd glissando }
                    Gl2 := Extract(Gl2,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('K'): Begin                { 3rd glissando }
                    Gl3 := Extract(Gl3,Copy(Input,InputPos+1,7)); { added 4-22-19 for a third glissando }
                    Notes := True;
                  end;
        Ord('U'): Begin               { upsample }
                    Ups := Extract(Ups,Copy(Input,InputPos+1,7));
                    Notes := True;
                  end;
        Ord('X'): Begin     { pass this info to xref.txt file for reporting what was chosen }
                    InputPos := Length(Input); { Ignore all that follows and pass the line to xref.txt }
                    Writeln(xref,Copy(Input,2,Length(Input)-1));
                  end;
        Ord('B'): Begin   { which random number file to use: 0 don't use one, all others random-xx.dat }
                    Raf := Extract(Raf,Copy(Input,InputPos+1,7));
                    {Writeln(xref,'Found a B variable. Raf set to : "',Raf,'"');}
                    If Raf = 255 then MyRandom(1,255);
                    Notes := True;
                  end;
        Ord(','): Begin  { error. no commas allowed! }
                    Writeln('Error - invalid comma found in input "',Input,'"');
                    Halt(3);
                  end;
        end; { Case }
      InputPos := InputPos + 1;
    end; { Begin }
end; { ParseValues }

Procedure ShowNotes;

Var
  i: Byte;
  Lines: byte;
  {OldTime,NewTime,Delta: Integer;}
  TempVel: Byte;
  MaxTime: LongInt;
  LastTempo: Integer;
  TempAudNote: AudNoteType;
  SameEndTime: Boolean;
  RealStart: Real;
  UnMatchedTimes: Boolean;
  SampleIndex: Integer;
  FoundSample, FoundFunctionTable: Boolean;
  OverallVolumeChan: Byte;
  OverallVolumeTime: Real;
  CheckF: integer;
  LastVolume: Integer;
  LastDuration: integer;


Function AllChannelsDone: Boolean;

Var
  i: Byte;
  Done: Boolean;

Begin
  Done := True;
  i := LowChannel;
  While (i < HighChannel + 1) and (Done) do
    Begin
      If Channels[i].Current <> -1 then Done := False;
      i := i + 1;
    end;
  AllChannelsDone := Done;
end; { AllChannelsDone }

Begin { ShowNotes }
  OverallVolumeChan := 0;
  If FunctionTableNumber > 4 then
    Begin
      Writeln(Sco,StartOfFunctionTable);
      Writeln(Sco,MonoStereoAkaiTable);
    end;
  Writeln(sco,';Inst Start        Dur  Vel    Ton   Oct  ',
        ' Voice Stere Envlp Gliss Upsamp R-Env 2nd-gl 3rd Mult Line # ; Channel');
  Writeln(sco,';p1   p2           p3   p4     p5    p6   ',
        ' p7    p8    p9    p10   p11    p12   p13   p14  p15; Channel');
  Writeln(Csv,'"Start","Dur","Vel","Ton","Oct",',
        '"Voice","Stere","Envlp","Gliss","Upsamp","R-Env","2nd-gl","3rd-gl","Mult","chan"');
  MaxTime := 0;
  For i := LowChannel to HighChannel do
    Begin
      Channels[i].Current := Channels[i].First;
      Channels[i].StartTime := 0;
      (*
      Writeln(xref,'Channels[',i,'].NumSamples = ',Channels[i].NumSamples,
             ' Instrument = ',Channels[i].Instrument,
             ' FunctionTable = ',Channels[i].FunctionTable );
      *)
    end;
  For i := LowChannel to HighChannel do
    Begin
      With Channels[i] do
         Repeat
            If (Current <> -1) then
              Begin
                Seek(AudNoteFile,Current);
                Read(AudNoteFile,TempAudNote);
                With TempAudNote do
                  Begin
                    {Writeln('in ShowNotes Ton=',ToneInScale,' octave=',Octave,' Channel i =',i);}
                    { e.g if Rand = 1, then very unlikely to play it }
                    {     if Rand = 16, then always play it }
                    {Writeln(xref,'line 1687. Ranf  = ',Ranf,' Raf = ',Raf);}
                    If MyRandom(16,Raf) < Rand then
                          TempVel := Velocity
                    Else TempVel := 0;
                    If TempVel > 200 then TempVel := 0; { fixed 9/13/03 to make 200 the max}
                    If HoldDuration = 0 then HoldDuration := Duration;
                    (* if ((TempVel > 0) and (Duration > 0)) then *)
                    { 1/21/05 we need to allow for zero duration but non zero hold time }
                    if ((TempVel > 0) and (HoldDuration > 0)) then
                      Begin { If not zero velocity, play the note }
                        { if the Ovv value (A) is non-zero, then this is an overall velocity channel }
                        If (NowVolume > 0) then OverallVolumeChan := i;
                        { Find out what sample is being used here, then see if the start time needs adjusting }
                        SampleIndex := 0;
                        FoundSample := False;
                        FoundFunctionTable := False;
                        CheckF := Trunc(Octave * 12 + ((ToneInScale/Root)*12)); { find midi note number nearest this one }
                        (*
                        Writeln(xref,'********Octave = ',Octave,' Ton = ',ToneInScale,' Root = ',Root);
                        Writeln(xref,'CheckF = ',CheckF);
                        *)
                        { this section puts the wrong samples into the output file }
                        { it needs some serious work. Samples are being left out }
                        { I don't think it does anything any more }
                        Repeat { until found or all samples examined }
                          If McGillDesc[SampleIndex].Channel = FunctionTable then { found the channel }
                            Begin { Now figure out which sample is for this note } { need to ensure sample exists }
                              FoundFunctionTable := True;
                              If McGillDesc[SampleIndex].BaseNote >= CheckF then
                                Begin { Function table is needed }
                                  if UpSample > 128 then
                                    Begin { Down sample. This means a lower instrument note will be raised farther }
                                          {- makes a sharper sound }
                                      SampleIndex := SampleIndex + (UpSample - 256);
                                      If SampleIndex < 0 then SampleIndex := 0; { fixed 12-28-15 }
                                      { Writeln('SampleIndex = ',SampleIndex,' McGillSamples = ',McGillSamples,' McGillDescIndex = ',McGillDescIndex); }
                                      { check if within bounds first }
                                      While McGillDesc[SampleIndex].Channel <> FunctionTable do
                                            SampleIndex := SampleIndex + 1; { Runtime error 216 here }
                                    end
                                  Else
                                    Begin { Up sample. A higher instrument note will be lowered farther }
                                          { - makes a mellower sound }
                                      SampleIndex := SampleIndex + UpSample;
                                      While McGillDesc[SampleIndex].Channel <> FunctionTable do
                                            SampleIndex := SampleIndex - 1;
                                    end;
                                  FoundSample := True;
                                end; { This particular Function Table is needed }
                            end; { Found the channel, now figure out which sample is for this note }
                          SampleIndex := SampleIndex + 1;
                        Until (FoundSample) or (SampleIndex = McGillDescIndex-1) or
                              ((McGillDesc[SampleIndex].Channel <> FunctionTable) and FoundFunctionTable);
                        SampleIndex := SampleIndex - 1;
                        RealStart := StartTime + Perturb/16-Perturb*Random/8 - McGillDesc[SampleIndex].MoveForward;
                        { Should I add the time to the beginning and also make the duration longer to compensate? }
                        { Not for now }
                        { HoldDuration := HoldDuration +  Round(McGillDesc[SampleIndex].MoveForward); }
                        If RealStart < 0 then RealStart := 0;
                        If WarEnvelope = 0 then WarEnvelope := Envelope;
                        (*
                        Writeln(xref,'Check to see if Upsample will ask for a sample out of range');
                        Writeln(xref,'Upsample = ', Upsample, ' McGillDesc[', SampleIndex, '].SampleNumber = ',
                              McGillDesc[SampleIndex].SampleNumber, ' Channels[', i, '].NumSamples = ', NumSamples);
                        *)
                        If Upsample > 128 then
                          Begin { downsample requested. Deny it if there is no lower samples to raise  }
                            (*
                            Writeln(xref,'Upsample - 256 = ',Upsample - 256);
                            Writeln(xref,'prior to do loop. McGillDesc[',SampleIndex,'].SampleNumber = ',
                                   McGillDesc[SampleIndex].SampleNumber);
                            Writeln(xref,'Prior to do loop Calc = ',
                                  McGillDesc[SampleIndex].SampleNumber + (Upsample - 256));
                            *)
                            While ((McGillDesc[SampleIndex].SampleNumber + (Upsample - 256) < 1)
                                  and (Upsample <> 0))
                              do
                                If Upsample = 255 then Upsample := 0
                                Else Upsample := Upsample + 1;
                            {Writeln(xref,'Upsamp > 128. After while do loop Upsample = ',Upsample);}
                          end
                        Else if Upsample > 0 then
                          Begin { Upsample a higher sample will be lowered, but not if there aren't any }
                            (*
                            Writeln(xref,'Upsample > 0 loop. Upsample = ',Upsample);
                            Writeln(xref,'McGillDesc[',SampleIndex,'].SampleNumber = ',
                                  McGillDesc[SampleIndex].SampleNumber);
                            Writeln(xref,'NumSamples = ',NumSamples);
                            *)
                            While(McGillDesc[SampleIndex].SampleNumber + Upsample > NumSamples)
                              do Upsample := Upsample - 1;
                            {Writeln(xref,'Upsamp GT 0 LT 128. After while do loop Upsample = ',Upsample);}
                          end;
                        (*
                        Writeln(xref,'HoldDuration = ',HoldDuration,' McGillDesc[',SampleIndex,'].BaseNote = ',
                              McGillDesc[SampleIndex].BaseNote);
                        Writeln(xref,'Upsample = ',UpSample,' ToneInScale = ', ToneInScale,' Octave = ',Octave);
                        Writeln(xref,'Channels[',i,'].NumSamples = ',NumSamples);
                        Writeln(xref,'Sample File Name = "',McGillDesc[SampleIndex].FTable,'"');
                        Writeln(xref,'Relative Instrument # = ',FunctionTable,' Instrument # ',i:6);
                        *)
                        if OldMethod then
                          Begin
                            Writeln(sco,'i1 ', RealStart:13:10,
                              HoldDuration:6, TempVel:6,ToneInScale:6,
                              Octave:6, FunctionTable:6,Stereo:6,
                              Envelope:6,Glisand:6,Upsample:6,WarEnvelope:6,
                              Glisand2:6, Glisand3:6, Mult:6,
                              ' ; ',LineNum:6, i:6);
                            Writeln(Csv,RealStart:13:10,',',
                              HoldDuration:6,',',TempVel:6,',',ToneInScale:6,',',
                              Octave:6,',',FunctionTable:6,',',Stereo:6,',',
                              Envelope:6,',',Glisand:6,',',Upsample:6,',',WarEnvelope:6,',',
                              Glisand2:6,',',Glisand3:6,',',Mult:6,',',i:6);
                          end
                        Else
                            Writeln(sco,'i1 ', RealStart:13:10,
                              HoldDuration:6, TempVel:6,ToneInScale:6,
                              Octave:6,Mult:6,Instrument:6,Stereo:6,
                              Envelope:6,Glisand:6,Upsample:6,WarEnvelope:6,
                              Glisand2:6, Glisand3:6, ' ; ', i:6);
                      end;
                    StartTime := StartTime + Duration;
                    If StartTime > MaxDuration then MaxDuration := StartTime;
                  end;
                Current := TempAudNote.Next; { where are we in the file }
              end;
         Until (Current = -1);
         if Channels[i].StartTime > MaxTime then MaxTime := Channels[i].StartTime;
      end; { For i := LowChannel to HighChannel do }
  { only needed for reverb unit }
  { 1250 }
  { at this point we know how long the piece is in beats, we have one instrument created for the sole purpose of
    keeping track of what the overall volume should be along the way, and we need to write out the array that
    includes that. }
  { it should be a function table that looks like this:
    f1 0 65536 7
      and then a pair of levels and beats for each change of volume in the input file which look like this:
       dur level dur level dur level }
  { write the overallVolume csound file }
  Write(Ovf,' f1 0 65536 7 ');
  Channels[OverallVolumeChan].Current := Channels[OverallVolumeChan].First;
  Channels[OverallVolumeChan].StartTime := 0;
  Lines := 0;
  With Channels[OverallVolumeChan] do
        Repeat
          If (Current <> -1) then
            Begin
              Seek(AudNoteFile,Current);
              Read(AudNoteFile,TempAudNote);
              With TempAudNote do
                  Begin
                    StartTime := StartTime + Duration;
                    OverallVolumeTime := Duration*(65536/Maxtime);
                    Write(Ovf,'  ',NowVolume:6,' ',OverallVolumeTime:8:0);
                    LastVolume := NowVolume;
                    Lines := Lines + 1;
                    If Lines > 5 then
                      Begin
                        Writeln(Ovf,' ');
                        Write(Ovf,'  ');
                        Lines := 0;
                      end;
                  end;
                Current := TempAudNote.Next; { where are we in the file }
            end;
        Until (Current = -1);
  Writeln(Ovf,'  ',LastVolume); { need to fix this so it doesn't prematurely fade to silence }
  { find a way to reduce the number of values in T0 function tables - limit is 100 on Windows or less }
  { If the one you are about to write has the same NowTempo as the LastNowTempo, don't write it. }
  { The t0 function table can't be larger than a certain amount. I don't know what that is }
  { we should also write the t0 tempo array at this point }
  { I think the 2016 version of Csound fixed this }
  { It still fails with Csound 6.12 in 2018 }
  Write(Ovf,' t0 ');
  Write(sco,' t0 ');
  Channels[OverallVolumeChan].Current := Channels[OverallVolumeChan].First;
  Channels[OverallVolumeChan].StartTime := 0;
  Lines := 0;
  SameEndTime := False;
  { treat the OverallVolumeChan (where v is set to 1 like in &vel. ) differently.
    4/13/19 changed so that every &vel. note gets a new tempo only if it changes }
  LastVolume := 0;
  With Channels[OverallVolumeChan] do
        Repeat
          If (Current <> -1) then
            Begin
              Seek(AudNoteFile,Current);
              Read(AudNoteFile,TempAudNote);
              With TempAudNote do
                  Begin
                    StartTime := StartTime + Duration;
                    If StartTime < Maxtime then
                      Begin
                        If NowTempo <> LastVolume then
                          Begin
                            Writeln(Ovf,' ',NowTempo:6,StartTime:8);
                            { Start here: Figure out why the wrong tempo is being chosen}
                            { Also, why are we writing a new tempo for every measure? }
                            { That was true when we called tempo several times in the piece, but not it's only called once }
                            Writeln(sco,' ',NowTempo:6,StartTime:8);
                            LastVolume := NowTempo;
                          end
                      end
                    Else
                      Begin
                        Writeln(Ovf,' ',NowTempo:6);
                        Writeln(sco,' ',NowTempo:6);
                        SameEndTime := True;
                      end;
                    LastTempo := NowTempo;
                  end;
                Current := TempAudNote.Next; { where are we in the file }
            end;
        Until (Current = -1);
  { now explain what you wrote }
  If SameEndTime then Writeln(sco,' ')
  Else Writeln(sco,' ',LastTempo:6);
  Writeln(Ovf,'; Maxtime = ',Maxtime);
  Writeln(Ovf,'; Actual beats in the piece');
  Writeln(Ovf,'; Start Duration Volume Tempo  StartN   DurN');
  Channels[OverallVolumeChan].Current := Channels[OverallVolumeChan].First;
  Channels[OverallVolumeChan].StartTime := 0;
  With Channels[OverallVolumeChan] do
        Repeat
          If (Current <> -1) then
            Begin
              Seek(AudNoteFile,Current);
              Read(AudNoteFile,TempAudNote);
              With TempAudNote do
                  Begin
                    StartTime := StartTime + Duration;
                    LastDuration := Duration;
                    Writeln(Ovf,'; ',StartTime:6,Duration:6,NowVolume:6,'  ',
                          NowTempo:6,Int(StartTime*(65536/Maxtime)):8:0,Int(Duration*(65536/Maxtime)):8:0);
                  end;
                Current := TempAudNote.Next; { where are we in the file }
            end;
        Until (Current = -1);
  Writeln(Ovf,'i99   0 ',MaxDuration+LastDuration+10); { Used for an instrument that modifies overall volume }
  Writeln(Ovf,'</CsScore>');
  Writeln(Ovf,'</CsoundSynthesizer>');
  Writeln(sco,'</CsScore>');
  Writeln(sco,'</CsoundSynthesizer>');
  Writeln('Last StartTime  = ',MaxTime:6);
  {Writeln('Total memory at end:,MemAvail:8,MaxAvail:8 changed for Free Pascal');}
  UnMatchedTimes := False;
  For i := LowChannel to HighChannel do
      If Channels[i].StartTime <> 0 then
          If Channels[i].StartTime <> MaxTime then
              UnMatchedTimes := True;
  If UnMatchedTimes then
        For i := LowChannel to HighChannel do
              Writeln('Channel ',i:4,' Last start time was ',Channels[i].StartTime:7);
end; { ShowNotes }

Procedure PlayNotes;

Var
  Current: MacroPtr;

Function AllChannelsDone: Boolean;

Var
  i: Byte;
  Done: Boolean;

Begin
  Done := True;
  i := LowChannel;
  While (i < HighChannel + 1) and (Done) do
    Begin
      If Channels[i].Current <> -1 then Done := False;
      i := i + 1;
    end;
  AllChannelsDone := Done;
end; { AllChannelsDone }

Begin { PlayNotes }
  Writeln(xref,'Name           LastCh ChosenT Content');
  Current := MacroList.First;
  While (Current <> Nil) do
    Begin
      with Current^ do if ChosenTimes > 0 then
            If Length(Name) < 8 then
                  Writeln(xref,Name,Chr(09),Chr(09),LastChosen:5,' ',
                  ChosenTimes:6,' "',Content,'"')
            Else
                  Writeln(xref,Name,Chr(09),LastChosen:5,' ',
                  ChosenTimes:6,' "',Content,'"');
      Current := Current^.Next;
    end;
  Current := MacroList.First;
  Writeln(xref,'The following macros were never referenced in this pass of the program');
  While (Current <> Nil) do
    Begin
      with Current^ do if ChosenTimes = 0 then
            If Length(Name) < 8 then
                  Writeln(xref,'-->',Name,Chr(09),Chr(09),'"',Content,'"')
            else
                  Writeln(xref,'-->',Name,Chr(09),'"',Content,'"');
      Current := Current^.Next;
    end;
end; { PlayNotes }

Procedure WriteSampleFiles;

var
  SampleIndex: Integer;
  FoundSample, FoundFunctionTable: Boolean;
  i,CheckF: integer;
  TempAudNote: AudNoteType;

Begin
  For i := LowChannel to HighChannel do Channels[i].Current := Channels[i].First;
  For i := LowChannel to HighChannel do
    Begin
      Write(ChannelFile,Channels[i]);
      With Channels[i] do
         Repeat { for every channel }
            If (Current <> -1) then
              Begin { if you're not at the end of the channel }
                Seek(AudNoteFile,Current);
                Read(AudNoteFile,TempAudNote);
                With TempAudNote do
                  Begin { look at this note }
                    { Check all the sample files to see if they are needed to play this note }
                    SampleIndex := 0;
                    FoundSample := False;
                    FoundFunctionTable := False;
                    CheckF := Trunc((Octave + 1) * 12 + ((ToneInScale/Root)*12)); { find midi note number nearest this one }
                    Repeat { until found or all samples examined }
                      If McGillDesc[SampleIndex].Channel = FunctionTable then { found the channel, see if this sample }
                        Begin
                          { 4/1/01 Trying to fix this so that up or down sampling does not change the instrument }
                          FoundFunctionTable := True;
                          If McGillDesc[SampleIndex].BaseNote >= CheckF then
                            Begin { Function table is needed }
                              { made changes here on 12/28/15 to deal with negative numbers in SampleIndex }
                              if UpSample > 128 then
                                Begin { Down sample. This means a lower instrument note will be raised farther }
                                  SampleIndex := SampleIndex + (UpSample - 256);
                                  { Writeln('UpSample was >128 ',UpSample,' SampleIndex = ',SampleIndex,' McGillSamples = ',McGillSamples,' McGillDescIndex = ',McGillDescIndex); }
                                  If SampleIndex < 0 then SampleIndex := 0; { fixed 12-28-15 }
                                  { Runtime error 216 in the next line. Need to test for less than 0 }
                                  While McGillDesc[SampleIndex].Channel <> FunctionTable do
                                        SampleIndex := SampleIndex + 1;
                                end
                              Else
                                Begin { Up sample. A higher instrument note will be lowered farther }
                                  SampleIndex := SampleIndex + UpSample;
                                  { Writeln('UpSample was not> ',UpSample,' SampleIndex = ',SampleIndex,' McGillSamples = ',McGillSamples,' McGillDescIndex = ',McGillDescIndex);  }
                                  { SampleIndex := SampleIndex + (UpSample - 256); }
                                  While McGillDesc[SampleIndex].Channel <> FunctionTable do
                                        SampleIndex := SampleIndex - 1;
                                end;
                              McGillDesc[SampleIndex].Used := True;
                              FoundSample := True;
                            end; { if this function table is needed }
                        end;  { Found the channel }
                      SampleIndex := SampleIndex + 1;
                    Until (FoundSample) or (SampleIndex = McGillDescIndex-1) or
                          ((McGillDesc[SampleIndex].Channel <> FunctionTable) and FoundFunctionTable);
                    If ((McGillDesc[SampleIndex].Channel <> FunctionTable) and FoundFunctionTable) then
                          McGillDesc[SampleIndex-1].Used := True;
                    If SampleIndex = McGillDescIndex-1 then
                          McGillDesc[SampleIndex].Used := True;
                    { 2/13/04 hard code so samples are always used regardless of notes called for - }
                    { temporary fix - doesn't work very well - very mysterious }
                    McGillDesc[SampleIndex].Used := True;
                  end; { with Current^ do }
                Current := TempAudNote.Next; { where are we in the file }
              end;
         Until (Current = -1);
    end;
    { This needs more work. Basically copy all the samples to the output file, even if not needed }
    { changed gen01 read from 0 4 0 to 0 0 0 so that csound would detect the correct format for sample files }
  For SampleIndex := 0 to McGillDescIndex-1 do
    If McGillDesc[SampleIndex].Used then
          with McGillDesc[SampleIndex] do
          Writeln(sco,'f',McGillDesc[SampleIndex].FunctionTableNum,' 0 0 1 "',
                McGillDesc[SampleIndex].FTable, '" 0 0 0')
    Else
          Writeln(sco,'f',McGillDesc[SampleIndex].FunctionTableNum,' 0 0 1 "',
                McGillDesc[SampleIndex].FTable,
                '" 0 0 0 ; should not be required - uncomment if needed 2-28-2009');
  (*
  For SampleIndex := 0 to McGillDescIndex-1 do
          with McGillDesc[SampleIndex] do
          Writeln(xref,'McGillDesc[',SampleIndex,'].BaseNote = ',BaseNote,
                ' FunctionTableNum = ',FunctionTableNum,' SampleNumber = ',SampleNumber);
  *)
end; { WriteSampleFiles }

Begin
  Writeln;
  Randomize;
  Init;
  { Begin a string of notes to play }
  {     stat  mfgid  subst   node  }
  writeln('Root is ',Root);
  Repeat
    ReadValues(Input);
    ParseValues(Input);
  Until Eof(Music);
  WriteSampleFiles;
  ShowNotes;
  PlayNotes;
  Close(Music);
  Close(sco);
  Close(Csv);
  Close(Ovf);
  Close(AudNoteFile);
  Close(ChannelFile);
  Close(xref);
end.
