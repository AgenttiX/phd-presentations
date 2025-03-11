from pttools.analysis import plot_spectra_omgw0, plot_bubbles_v
from pttools.bubble import Bubble
from pttools.models import ConstCSModel
from pttools.omgw0 import Spectrum


def main():
    alpha_n = 0.2
    model = ConstCSModel(css2=1/3, csb2=1/4, alpha_n_min=alpha_n)
    bubbles = [
        Bubble(model, v_wall=0.3, alpha_n=alpha_n),
        Bubble(model, v_wall=0.6, alpha_n=alpha_n),
        Bubble(model, v_wall=0.9, alpha_n=alpha_n)
    ]
    spectra = [Spectrum(bubble, r_star=0.1, Tn=200) for bubble in bubbles]

    plot_bubbles_v(bubbles, path="bubbles.svg", v_max=0.5)
    plot_spectra_omgw0(spectra, path="spectra.svg")

if __name__ == "__main__":
    main()
