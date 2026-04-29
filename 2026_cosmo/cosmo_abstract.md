# Understanding stochastic gravitational wave backgrounds by exploring the parameter space of first-order phase transitions with the Sound Shell Model
Mika Mäki, Doctoral Researcher, Computational Field Theory group, University of Helsinki<br>
In collaboration with David Weir, Mark Hindmarsh, Deanna Hooper & Lorenzo Giombi

Cosmological first-order phase transitions in the early universe can generate stochastic gravitational wave backgrounds
that persist to the present day.
This provides a window into the early universe at the electroweak scale,
and a probe of physics beyond the Standard Model (BSM).

In the Standard Model, the electroweak phase transition (Higgs transition) is a crossover,
but extending the Standard Model to account for matter-antimatter asymmetry or dark matter
can convert it to a first-order phase transition, producing gravitational waves.
Therefore, stochastic gravitational wave backgrounds provide an experimental window into BSM physics
at energy scales that are difficult to probe at colliders alone.

The upcoming Laser Interferometer Space Antenna (LISA)
will be sensitive to the mHz frequency band of cosmological phase transitions,
opening a new frequency window inaccessible to current detectors.
Extracting the phase transition parameters such as
the transition strength $\alpha_n$, nucleation rate $\beta$ and wall speed $v_\text{wall}$ from LISA data,
and consequently inferring the underlying particle physics theory beyond the Standard Model,
is a challenging task,
as it requires comparing observations to theoretical predictions across a high-dimensional parameter space.
However, running a full lattice simulation for each parameter point is prohibitively expensive.

We address this challenge using the
[Sound Shell Model](https://arxiv.org/abs/1909.10040),
a computationally efficient semi-analytical framework
that reproduces the results of lattice simulations for intermediate-strength transitions.
Our group has extended the Sound Shell Model by incorporating additional key physical effects, including
[variations in the sound speed](https://arxiv.org/abs/2511.20436)
that change the underlying bubble hydrodynamics, and
[thermal suppression of bubble nucleation](https://arxiv.org/abs/2205.04097)
and
[the finite lifetime of the acoustic source](https://arxiv.org/abs/2409.01426),
which broaden the validity of the model across the parameter space.

These developments provide a fast and flexible framework
for modeling stochastic gravitational wave signals from phase transitions.
We have implemented these in the open-source utilities
[PTtools](https://github.com/CFT-HY/pttools)
and
[PTPlot](https://www.ptplot.org/ptplot/).
This enables likelihood-based parameter inference with LISA,
and direct experimental tests of BSM scenarios at the electroweak scale.
