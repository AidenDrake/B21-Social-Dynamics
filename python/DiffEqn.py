"""Implements the finite difference method to approximate and plot
the solution to a set of differential equations, specifically a model
of social movements, given by Peter Hedstrom in a 2006 paper. This
module is capable of simulating parameters using the original inputs
Hedstrom describes, as well as the "effective transition parameter"
version given later in the paper.

See:
P Hedstrom, Explaining the growth patterns of social movements,
Understanding Choice, Explaining Behavior (Oslo University Press,
Norway, 2006).

Note: Some modifications have been made from Hedstrom's original
equations. d -> k and delta -> phi. I did this to avoid confusing
myself, since "d" and "delta" are commonly used in the context of
differential equations.
"""
import numpy as np
import matplotlib.pyplot as plt
import csv


def diffrun(M_0=1, P_0=498, E_0=1, diff_delta_t:float= 0.7,
            params:tuple=(0.01, 0.01, 0.1, 0.1, 0.1, 0.1),
            final_t:int=150, should_print=False):
    """Runs approximation of Hedstrom's equations. Uses
    finite difference method. Default values represent the dummy trial
    from Hedstrom paper, Fig.2. Returns a list of lists. 

    Keyword arguments:
    M_0, P_0, E_0 -- starting values for members, potential, and former
    agents respectively.
    diff_delta_t -- change in t per round for approximation algorithm
    params -- (k, g, alpha, beta, c, phi) OR (a, b, c, phi)
    final_t -- the last value for t. (t always starts from 0)
    """
    global M, P, E

    M = [M_0,]
    P = [P_0,]
    E = [E_0,]

    delta_t = diff_delta_t

    ## A little bit of rodeoing to make sure that this model can handle the
    ## 4 and 6 parameter versions of the Hedstrom Model. 
    pl = len(params)
    if (pl == 6):
        k = params[0]
        g = params[1]
        alpha = params[2]
        beta = params[3]
        c = params [4]
        phi = params [5]

        a = k * alpha
        b = g * beta
        
    if (pl == 4):
        a = params[0]
        b = params[1]
        c = params[2]
        phi = params[3]

    rec = [[M[0], P[0], E[0]],]
    
    i = 1
    for t in np.arange(delta_t, final_t,delta_t):
        newP = (E[i-1]*phi-M[i-1]*P[i-1]*a)*delta_t+P[i-1]
        P.append(newP) ##P[i] = newP

        newE = (E[i-1]*M[i-1]*b+M[i-1]*c-E[i-1]*phi)*delta_t+E[i-1]
        E.append(newE)

        newM = (M[i-1]*P[i-1]*a-E[i-1]*M[i-1]*b-M[i-1]*c)*delta_t+M[i-1]
        M.append(newM)

        if should_print:
            print('M:', M[i], 'P:', P[i],'E:', E[i])

        rec.append([M[i], P[i], E[i]])

        i+=1

    return rec

        
def plot(delta_t, final_t, M, P, E):
    """Puts data from a previous trial on a matplotlib graph"""

    tScale = np.arange(0, final_t, delta_t)

    MemArr = np.asarray(M)
    PotsArr = np.asarray(P)
    ExArr = np.asarray(E)
    
    fig, ax = plt.subplots()
    
    ax.plot(tScale, PotsArr, label='Pots')
    ax.plot(tScale, ExArr, label='Ex-mems')
    ax.plot(tScale, MemArr, label='Mem')
    ax.legend()
    plt.show()
    
            
