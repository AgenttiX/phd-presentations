import matplotlib.pyplot as plt
import numpy as np

from pttools.analysis import ModelPlot
from pttools.models import ConstCSModel

figsize = (3, 5)
csb = 1 / np.sqrt(3) - 0.01
model = ConstCSModel(a_s=1.5, a_b=1, css2=1/3, csb2=csb**2, V_s=1)
plot = ModelPlot(model, t_log=False, y_log=False)

fig = plt.figure(figsize=figsize)
axs = fig.subplots(2, 1)
plot.plot(axs[0], model.p_temp, "p", y_log=False, ticks=False)
plot.plot(axs[1], model.w, "w", y_log=False, ticks=False)
fig.tight_layout()

fig.savefig("model.svg")
plt.show()
