## Differential Eqn Testing -- won't be our final result
import numpy as np
import csv
import matplotlib.pyplot as plt

P = [498,]
E = [1,]
M = [1,]
delta_t = 0.7

def main():
    global P, M, E, delta_t
    
    phi = c = 0.1
    alpha = beta = 0.1
    k = g = 0.01

    rec = [[M[0], P[0], E[0]],]
    
    i = 1
    for t in np.arange(delta_t,150,delta_t):
        newP = (E[i-1]*phi-M[i-1]*P[i-1]*k*alpha)*delta_t+P[i-1]
        P.append(newP) ##P[i] = newP

        newE = (E[i-1]*M[i-1]*g*beta+M[i-1]*c-E[i-1]*phi)*delta_t+E[i-1]
        E.append(newE)

        newM = (M[i-1]*P[i-1]*k*alpha-E[i-1]*M[i-1]*g*beta-M[i-1]*c)*delta_t+M[i-1]
        M.append(newM)

        ##print(M[i], P[i], E[i])

        rec.append([M[i], P[i], E[i]])

        i+=1

    ##recordToCsv(rec)
    plot()
        
def plot():
    global P, E, M, delta_t

    tScale = np.arange(0, 150, delta_t)
    
    PotsArr = np.asarray(P)
    ExArr = np.asarray(E)
    MemArr = np.asarray(M)
    
    fig, ax = plt.subplots()
    
    ax.plot(tScale, PotsArr, label='Pots')
    ax.plot(tScale, ExArr, label='Ex-mems')
    ax.plot(tScale, MemArr, label='Mems')
    ax.legend()
    plt.show()
    
        
        
    
def recordToCsv(record):
    with open('diffeqn.csv', 'wt',) as csvfile:
        w = csv.writer(csvfile, delimiter=';')
        for lst in record:
            w.writerow(lst)
            
if __name__=='__main__':
    main()
