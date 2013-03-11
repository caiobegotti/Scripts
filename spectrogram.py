#!/usr/bin/env python
# python scriptlet to generate spectrograms, inspired by:
# http://dsp.stackexchange.com/questions/1593/improving-spectrogram-resolution-in-python

import sys

from scipy.io.wavfile import read
from pylab import plot, show, subplot, specgram, cm

def showspec(speech):
    rate, data = read(speech)

    subplot(410)
    plot(range(len(data)),data)

    subplot(411)
    specgram(data, NFFT=256, noverlap=128, pad_to=None, scale_by_freq=None, cmap=cm.ocean)

    subplot(412)
    specgram(data, NFFT=256, noverlap=128, pad_to=None, scale_by_freq=None, cmap=cm.hsv)

    subplot(413)
    specgram(data, NFFT=256, noverlap=128, pad_to=None, scale_by_freq=None, cmap=cm.spectral)

    show()

file = sys.argv[1]
showspec(file)
