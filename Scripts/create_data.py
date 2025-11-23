# create test data to ensure the same data for all test programmes

# import required packages
from scipy.integrate import odeint
import numpy as np

# data file
filename = '../Libs/roessler.csv'

# data length, transient length, and sampling time
N = 1000000
N_trans = 1000
dt = 0.05

rng = np.random.default_rng(seed=42)

# the Roessler ODE
def roessler(x,t):
   return [-(x[1] + x[2]), x[0] + 0.25 * x[1], 0.25 + (x[0] - 4) * x[2]]

# solve the ODE
x_ = odeint(roessler, rng.random(3), np.arange(0, dt*(N_trans+N), .05))
x = x_[1000:,0]

# save x-component into data file
np.savetxt(filename, x, delimiter=",")
