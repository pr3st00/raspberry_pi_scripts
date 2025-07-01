# record noise
rec -q -r 48000 -c 1 -e signed-integer -b 16 -t wav /tmp/audio.wav

# in.ext out.ext trim {start: s.ms} {duration: s.ms}
sox /tmp/audio.wav /tmp/noise-audio.wav trim 0 0.900

#Generate a noise profile in sox:
sox /tmp/noise-audio.wav -n noiseprof noise.prof

#Clean the noise from the audio
#sox audio.wav audio-clean.wav noisered noise.prof 0.21

