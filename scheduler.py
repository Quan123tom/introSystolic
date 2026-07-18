import numpy as np

class Scheduler:
    def __init__(self, A):
        #inputs will be skewed beforehabd
        self.A = A
        self.cycle = 0
        self.total_cycles = self.A.shape[1] + self.A.shape[0] - 1
    
    def get_inputs(self):
        if self.cycle < self.A.shape[1]:
            left = self.A[:, self.cycle]
        else:
            left = np.zeros(self.A.shape[0], dtype=self.A.dtype)

        self.cycle += 1
        return left
    def done(self):
        return (self.cycle >= self.total_cycles)

 