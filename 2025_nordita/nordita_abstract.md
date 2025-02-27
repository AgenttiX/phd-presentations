Determining the parameters of a first-order phase transition from the LISA signal
requires simulations of the phase transition with various parameters.
Due to the size of the parameter space, this can become computationally very expensive
and therefore infeasible with full 3D lattice simulations.
Therefore, more efficient models are needed.

To solve this, our research group has developed the
[Sound Shell Model](https://doi.org/10.1088/1475-7516/2019/12/062),
which provides a computationally efficient way of calculating the gravitational wave spectra
from the parameters of the phase transition,
reproducing the results of numerical simulations for intermediate strength transitions.
The Sound Shell Model has been encapsulated in the Python-based simulation framework
[PTtools](https://github.com/CFT-HY/pttools),
which enables easy generation of the gravitational wave spectra.
Using PTtools one can simulate hundreds of parameter combinations in a matter of minutes on a laptop.
This enables charting the full parameter space.
PTtools achieves this by taking advantage of parallelism and the Numba JIT compiler.

The vast majority of existing simulations have been based on the bag model equation of state,
which assumes the ultrarelativistic sound speed $c_s = \frac{1}{\sqrt{3}}$.
As the latest addition,
[PTtools has been extended](http://hdl.handle.net/10138/591514)
to include support for arbitrary equations of state and
therefore for a temperature- and phase-dependent sound speed $c_s(T,\phi)$,
extending the simulations beyond the ultrarelativistic assumption of the bag model.
In the background this is achieved by compiling the user-provided functions
for the degrees of freedom with Numba
before they are provided to the underlying algorithms such as ODE solvers.

In addition to PTtools, our research group has developed the web-based plotting utility
[PTPlot](https://www.ptplot.org/ptplot/),
which makes generating the gravitational wave spectra possible through a web browser.
Work is ongoing to integrate PTtools with PTPlot,
which will result in the full Sound Shell Model being available through a web browser.
