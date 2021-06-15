This is a repository for samples, a front-end to Csound that is designed for several purposes:
1. Sample based synthesis, and especially simplifying the process of matching notes to the proper sample file based on the octave and note number desired.
2. Microtonal synthesis, where the tuning is other than 12 tone equal temperment.
3. The use of glissandos is desired, and including multiple different glissandos applied to the same note at the same time.
4. Indeterminacy is encouraged. There are several simple randomization methodologies that can be used.
5. The syntax uses the concept of a channel with notes as the primary musical element. Each channel has many notes, and there can be up to 16 or so channels. Each note has many characteristics, including pitch (t), octave (o), loudness (v), stereo position (s), envelopes for the right (e) and left (w) channel, duration (d) until the next note, hold (h) duration, and others. All the supported commands are listed in the file commands.txt.

My use of the program is primarily to create lists of lists of lists of notes, and switch between lists using one of several different random algorithms. 

The program takes an input text file and outputs a text file that Csound recognizes as a .csd file, including both an orchestra and a score. It also writes a .csv file for input to analytical tools to confirm that the desired tuning is being used. 

To be effective, the program needs sample files. This repository includes sample files that I've created over the years, in directories called 'Partition I', and 'Partition K'. The file called McGill.dat contains a mapping between the sample files and MIDI note numbers. There are may sample files that are not included in this repository because they are proprietary. All of mine in the I & K partitions are open source. These include finger piano, balloon drums, many different guitar strings, and some odd percussion instruments.

The code has been modified over the years to support my compositional directions. I've been the only user since I started some time in 1990. Error handling is not good. I hope to put up an example file that will successfully produce some music, but that's not available today. 

Examples of what the program can produce are available on my web site <a href="http://ripnread.com/sample-page/code/">here.</a> 