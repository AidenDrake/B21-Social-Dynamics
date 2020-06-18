## Differential Eqn Testing -- won't be our final result
import numpy as np
import matplotlib.pyplot as plt
import csv

##Globals
M = [1,]
P = [2,]
E = [3,]

def diffrun(M_0=1, P_0=498, E_0=1, diff_delta_t= 0.7,
            params:tuple=(0.01, 0.01, 0.1, 0.1, 0.1, 0.1), final_t=150,
            should_print=False):
    """Runs the differential eqn approximation. Uses finite difference method.
    Returns 3 lists of values.
    [M, P, E]_0 = starting values
    _delta_t = change in t per round for approx algorithm
    params: (k, g, alpha, beta, c, phi) OR (a, b, c, phi)
    final_t = the last value for t. (t always starts from 0)

    Note: Some modifications have been made from Hedstrom's eqns. d -> k
    and delta -> phi. I did this to avoid confusing myself."""
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
        
def plot(delta_t, final_t):
    global P, E, M

    tScale = np.arange(0, final_t, delta_t)
    
    PotsArr = np.asarray(P)
    ExArr = np.asarray(E)
    MemArr = np.asarray(M)
    
    fig, ax = plt.subplots()
    
    ax.plot(tScale, PotsArr, label='Pots')
    ax.plot(tScale, ExArr, label='Ex-mems')
    ax.plot(tScale, MemArr, label='Mem')
    ax.legend()
    plt.show()
    
        
        
    
def recordToCsv(record):
    with open('diffeqn.csv', 'wt',) as csvfile:
        w = csv.writer(csvfile, delimiter=';')
        for lst in record:
            w.writerow(lst)
            
