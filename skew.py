import numpy as np

def skew_inputs(matrix):
    #this will apply the shift in the input matrix so that each row gets in the grid
    #in the correct order 
    N, M = matrix.shape
    matrix_skewed = np.zeros((N, M+ N -1))
    for i in range(N):
        matrix_skewed[i, i:i+M] = matrix[i]
    return matrix_skewed


