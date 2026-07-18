import numpy as np

class PE:
    def __init__(self):
        self.weight = 0
        self.activation_reg = 0
        self.partialSum_reg = 0
    #systolic array operation in each cycle will be broken in 2 stages, Update ,MAC
    def MAC(self, act_in, psum_in):
        active = (act_in != 0)
        next_psum = psum_in + (act_in*self.weight)
        next_act = act_in
        return next_act, next_psum, active
    def update_regs(self, next_psum, next_act):
        self.activation_reg = next_act
        self.partialSum_reg = next_psum

class SystolicArray:
    def __init__(self, rows = 8, cols = 8):
        self.rows = rows
        self.cols = cols
        self.grid = [[PE() for _ in range(cols)] for _ in range(rows)]
        self.total_mac = 0
        self.active_per_cycle = []
    
    def load_weights(self, weight_matrix):
        for i in range(self.rows):
            for j in range(self.cols):
                self.grid[i][j].weight = weight_matrix[i][j]
    def tick(self, left_inputs, up_inputs):
        next_acts = [[0]*self.cols for _ in range(self.rows)]
        next_psums = [[0] * self.cols for _ in range (self.rows)] #intialize acts and partial sums
        active_this_cycle = 0
        #with 0s
        for i in range(self.rows):
            for j in range(self.cols):
                if j == 0:
                    act_in = left_inputs[i]
                else:
                    act_in = self.grid[i][j-1].activation_reg
                psum_in = up_inputs[j] if i == 0 else self.grid[i-1][j].partialSum_reg
                next_acts[i][j], next_psums[i][j], active = self.grid[i][j].MAC(act_in, psum_in)
                #the above computes the next steps
                if active:
                    active_this_cycle += 1
        for r in range(self.rows):
            for c in range(self.cols):
                self.grid[r][c].update_regs(next_psums[r][c], next_acts[r][c])
        #define the final results(what comes from the bottom as a result)
        self.total_mac += active_this_cycle
        self.active_per_cycle.append(active_this_cycle)
        east_outputs = [self.grid[r][self.cols-1].activation_reg for r in range(self.rows)]
        south_outputs = [self.grid[self.rows-1][c].partialSum_reg for c in range(self.cols)]
        return east_outputs, south_outputs
    

