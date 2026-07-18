import numpy as np

class Scheduler:
    def __init__(self, A, W):
        #inputs will be skewed beforehabd
        self.cycle = 0
    
    def get_inputs(self):
        left = self.A[:, self.cycle]
        self.cycle += 1
        return left
    def done(self):
        return self.cycle >= self.A.shape[1]

 