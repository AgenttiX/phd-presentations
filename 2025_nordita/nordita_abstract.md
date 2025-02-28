# Generating gravitational wave spectra from equations of state for phase transitions in the early universe
Mika Mäki, Doctoral Researcher, Computational Field Theory group, University of Helsinki

The
[Sound Shell Model](https://doi.org/10.1088/1475-7516/2019/12/062)
provides a computationally efficient way of calculating the gravitational wave spectra
of first-order cosmological phase transitions,
reproducing the results of lattice simulations for intermediate strength transitions.
The Sound Shell Model has been encapsulated in the Python-based simulation framework
[PTtools](https://github.com/CFT-HY/pttools),
which enables easy generation of the gravitational wave spectra.
Using PTtools one can simulate hundreds of spectra in a matter of minutes on a laptop.
This enables charting the full parameter space.

The vast majority of existing simulations have been based on the bag model equation of state,
which assumes the ultrarelativistic sound speed $c_s = \frac{1}{\sqrt{3}}$.
As the latest addition,
[PTtools has been extended](http://hdl.handle.net/10138/591514)
to include support for arbitrary equations of state and
therefore for a temperature- and phase-dependent sound speed $c_s(T,\phi)$,
extending the simulations beyond the ultrarelativistic assumption of the bag model.

In addition to PTtools, we have developed the web-based plotting utility
[PTPlot](https://www.ptplot.org/ptplot/),
which makes generating the gravitational wave spectra possible through a web browser.
Integrating PTtools with PTPlot enables easy access to the full Sound Shell Model for the research community.
