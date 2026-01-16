# Generating gravitational wave spectra from equations of state for phase transitions in the early universe
Mika Mäki, Doctoral Researcher, Computational Field Theory group, University of Helsinki<br>
In collaboration with David Weir, Mark Hindmarsh, Deanna Hooper & Lorenzo Giombi

Cosmological first-order phase transitions are an active area of research,
as they provide experimental tests for many theories beyond the Standard Model.
This is thanks to the upcoming Laser Interferometer Space Antenna (LISA),
which will be sensitive to the frequency range of the gravitational waves
that the phase transitions may generate.

Determining the phase transition parameters will be done
by comparing observed gravitational wave spectra to theoretical predictions
from a wide range of phase transition parameters.
However, full lattice simulations of phase transitions are computationally expensive.

As a solution, the
[Sound Shell Model](https://doi.org/10.1088/1475-7516/2019/12/062)
provides a computationally efficient way of calculating the gravitational wave spectra,
reproducing the results of lattice simulations for intermediate-strength transitions.
The Sound Shell Model has been encapsulated in the Python-based simulation framework
[PTtools](https://github.com/CFT-HY/pttools),
which enables easy and fast generation of the gravitational wave spectra,
making it possible to chart the full parameter space.

The most of the existing simulations have been based on the bag model equation of state,
which assumes the ultrarelativistic sound speed $c_s = \frac{1}{\sqrt{3}}$..
In turn,
[PTtools includes support for arbitrary equations of state](https://arxiv.org/abs/2511.20436),
and therefore for a temperature- and phase-dependent sound speed $c_s(T,\phi)$.
PTtools also the low-frequency tail of the spectrum.

In addition to PTtools, we have developed the web-based plotting utility
[PTPlot](https://www.ptplot.org/ptplot/).
Integrating PTtools with PTPlot enables easy access to the full Sound Shell Model for the research community.
