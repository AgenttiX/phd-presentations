# Understanding stochastic gravitational wave backgrounds by exploring the parameter space of first-order phase transitions with the Sound Shell Model
Mika Mäki, Doctoral Researcher, Computational Field Theory group, University of Helsinki<br>
In collaboration with David Weir, Mark Hindmarsh, Deanna Hooper & Lorenzo Giombi

Cosmological first-order phase transitions can generate stochastic gravitational wave backgrounds observable by LISA,
offering a probe of physics beyond the Standard Model.
Extracting phase transition parameters from LISA observations requires
comparing observations to theoretical predictions across a high-dimensional parameter space.
However, running a full lattice simulation for each parameter point is prohibitively expensive.

We address this challenge using the
[Sound Shell Model](https://arxiv.org/abs/1909.10040),
a computationally efficient framework
that reproduces the results of lattice simulations for intermediate-strength transitions.
We have implemented the Sound Shell Model in the Python-based simulation library
[PTtools](https://github.com/CFT-HY/pttools),
enabling systematic large-scale exploration of the parameter space.
Our implementation incorporates key physical effects, including
[variations in the sound speed](https://arxiv.org/abs/2511.20436),
[thermal suppression of bubble nucleation](https://arxiv.org/abs/2205.04097),
and
[the finite lifetime of the acoustic source](https://arxiv.org/abs/2409.01426).

In addition, we extend the web-based tool
[PTPlot](https://www.ptplot.org/ptplot/)
to support double broken power law (DBPL) fits and
Sound Shell Model spectra,
providing more accurate alternatives to the standard broken power law (BPL) approximations.
These developments provide a fast and flexible framework
for modeling stochastic gravitational wave signals from phase transitions,
enabling likelihood-based parameter inference with LISA.
