
class PE:
    def __init__(self):
        self.weight = 0
        self.activation_reg = 0
        self.partialSum_reg = 0
    #systolic array operation in each cycle will be broken in 2 stages, Update ,MAC
    def MAC(self, act_in, psum_in):
        next_psum = psum_in + (act_in*self.weight)
        next_act = act_in
        return next_act, next_psum
    def update_regs(self, next_psum, next_act):
        self.activation_reg = next_act
        self.partialSum_reg = next_psum

class SystolicArray:
    def __init__(self, rows = 8, cols = 8):
        self.rows = rows
        self.cols = cols
        self.grid = [[PE() for _ in range(cols)] for _ in range(rows)]
    
    def load_weights(self, weight_matrix):
        for i in range(self.rows):
            for j in range(self.cols):
                self.grid[i][j].weight = weight_matrix[i][j]
    
    

        