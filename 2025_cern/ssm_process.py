import matplotlib.pyplot as plt

from pttools.bubble import Bubble
from pttools.models import ConstCSModel
from pttools.ssmtools import NucType
from pttools.omgw0 import Spectrum


def main():
    # Create the equation of state.
    # If you don't specify a_s and a_b or g_s and g_b,
    # you have to specify a minimum alpha_n for which the model will be valid.
    model = ConstCSModel(css2=1/4, csb2=1/4, alpha_n_min=0.1)

    # Create and simulate the fluid profile of a bubble.
    bubble = Bubble(model, v_wall=0.6, alpha_n=0.1)
    # bubble_fig = bubble.plot()
    # bubble_fig.savefig("bubble.svg")

    # Compute the gravitational wave spectrum for the bubble.
    spectrum = Spectrum(bubble, nuc_type=NucType.EXPONENTIAL, r_star=0.1, low_k=False)
    spectrum.plot_multi_flat(path="ssm.svg")


if __name__ == "__main__":
    main()
    plt.show()
