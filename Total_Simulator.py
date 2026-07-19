from simulation import SystolicArray
from skew import skew_inputs
from scheduler import Scheduler

import numpy as np

A = np.random.randint(1, 100, size=(8, 100))
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
C_simulated = np.zeros((100, 8))


for k in range(100):
    for j in range(8):
        C_simulated[k, j] = raw_outputs[k + array.rows - 1 + j][j]
       #C_simulated[k, j] = raw_outputs[k + j][j]
total_pes = array.rows * array.cols
total_pe_cycles = total_pes * cycles

peak_macs = max(array.active_per_cycle)
avg_macs = array.total_mac / cycles
utilization = (array.total_mac / total_pe_cycles) * 100

C_expected = np.dot(A.T, W)

print(f"Cycles                : {cycles}")
print(f"Array Size            : {array.rows} x {array.cols}")
print(f"Total PEs             : {total_pes}\n")

print(f"Useful MACs           : {array.total_mac}")
print(f"Peak MACs/cycle       : {peak_macs}")
print(f"Average MACs/cycle    : {avg_macs:.2f}\n")

print(f"PE Utilization        : {utilization:.2f}%\n")

print("Per-cycle activity\n")
for i, active in enumerate(array.active_per_cycle):
    print(f"Cycle {i:<2}: {active}")
print("Simulated Output:\n", C_simulated)
print("\nExpected Output (A @ W):\n", C_expected)
print("\nMatches Expected?", np.array_equal(C_simulated, C_expected))