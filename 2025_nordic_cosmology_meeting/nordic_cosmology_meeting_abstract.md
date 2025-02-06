# Generating gravitational wave spectra from equations of state for phase transitions in the early universe
Mika Mäki, Doctoral Researcher, Computational Field Theory group, University of Helsinki

The frequency range of gravitational waves from first-order cosmological phase transitions will be investigated
by the upcoming space-based gravitational wave observatory LISA.
If we see a signal of cosmological origin,
we need to be able to deduce the parameters of the phase transition
from the gravitational wave signal to understand the physics behind it.
This requires simulations of the gravitational wave spectra with various parameters.
Many of the existing simulations have been based on 3D lattices,
which is computationally expensive and therefore infeasible for a large parameter space.
A significantly faster alternative is provided by the Sound Shell Model,
which provides a computationally efficient way of calculating the gravitational wave spectra,
reproducing the results of numerical simulations for intermediate strength transitions.
The Sound Shell Model is encapsulated in the simulation framework
[PTtools](https://github.com/CFT-HY/pttools)
developed by our research group.
We have also developed the web-based plotting utility
[PTPlot](https://www.ptplot.org/ptplot/)
to visualise these gravitational wave spectra.

The vast majority of existing simulations have been based on the bag model equation of state,
which assumes the ultrarelativistic sound speed $c_s = \frac{1}{\sqrt{3}}$.
As the latest addition,
[PTtools has been extended](http://hdl.handle.net/10138/591514)
to include support for arbitrary equations of state and
therefore for a temperature- and phase-dependent sound speed $c_s(T,\phi)$,
extending the simulations beyond the ultrarelativistic assumption of the bag model.
