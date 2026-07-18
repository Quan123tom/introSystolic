from simulation import SystolicArray
from skew import skew_inputs
from scheduler import Scheduler

import numpy as np

A = np.random.randint(1, 100, size=(8, 8))
W = np.random.randint(1, 100, size=(8, 8))

A_skew = skew_inputs(A)

scheduler = Scheduler(A_skew)
array = SystolicArray()
array.load_weights(W)
cycles = 0
raw_outputs = []
while not scheduler.done():
    cycles += 1
    left = scheduler.get_inputs()
    east, south = array.tick(left, np.zeros(array.cols))
    raw_outputs.append(south)




raw_outputs = np.array(raw_outputs)
C_simulated = np.zeros((8, 8))


for k in range(8):
    for j in range(8):
        C_simulated[k, j] = raw_outputs[k + array.rows - 1 + j][j]
total_pe_cycles = array.rows * array.cols * len(array.active_per_cycle)
C_expected = np.dot(A.T, W)
print("It run for: ", scheduler.cycle, "\n")
print("MAC operations:", array.total_mac)
utilization = 100 * array.total_mac / total_pe_cycles
print(f"PE utilization: {utilization:.2f}%")
print("Simulated Output:\n", C_simulated)
print("\nExpected Output (A @ W):\n", C_expected)
print("\nMatches Expected?", np.array_equal(C_simulated, C_expected))