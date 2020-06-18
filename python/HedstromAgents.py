from random import randint, random
import numpy as np
import matplotlib.pyplot as plt
import csv
import DiffEqn

tc = mc = fc = pc = 0
agents = []

IOGT_fitted_values={'M_0':60, 'P_0':2430, 'E_0':10,
                    'params':(0.0003, 0.009, 0.08, 0.68),
                    'steps':100,}
## The values for the independant order of good templars model

## Note: E for "ex-member" is used for "former" agents

agent_rec = []


def simvsdiff(M_0:int=1, P_0:int=498, E_0:int=1,
               params:tuple=(0.01, 0.01, 0.1, 0.1, 0.1, 0.1),
               final_t:int=200, _delta_t:float=0.7, should_print=False):
    
    agent_rec = simulation(M_0, P_0, E_0, params, False, final_t, should_print)

    diff_rec = DiffEqn.diffrun(M_0, P_0, E_0, _delta_t, params, 200)

    vsplot(agent_rec, diff_rec, 1, _delta_t, final_t)

def simulation(M_0:int=1, P_0:int=498, E_0:int=1,
               params:tuple=(0.01, 0.01, 0.1, 0.1, 0.1, 0.1),
               export:bool=False, steps:int=200, should_print=False):
    """Runs the simulation. Default values represent the dummy trial
    from Hedstrom Chapter, Fig.2
    
    simulation(**kwargs)

    
    M_0: the number of staring MEMBERS, P_0: POTENTIALS, E_0: FORMERS
    params: (d, g, alpha, beta, c, delta) OR (a, b, c, delta)
    Export: write to csv?
    steps=how many steps to run"""
    global agents, agent_rec

    agent_rec =[]

    init(M_0, P_0, E_0)

    updateCounts()

    print('starting values:', 'members:', mc, 'potentials:',
              pc, 'formers:', fc)

    pl = len(params)

    for i in range(steps):
        agent_rec.append([mc, pc, fc])
        ## Not thrilled about this,
        ## it splits the stepping based on the number of args
        ## given in the tuple
        if (pl == 6):
            step(*params)
        elif (pl == 4):
            simpleStep(*params)
        else:
            raise Exception('Param should have 4 or 6 values')
        updateCounts()
        
        if should_print:
            print('members:', mc, 'potentials:', pc, 'formers:', fc)
        
    agent_rec.append([mc, pc, fc]) ## for the final update
    
    if (export == True):
        recordToCsv(record)

    return agent_rec
        
        
def step(d, g, alpha, beta, c, delta):
    """One step of the simulation
    this is a version for the more complex model"""
    global agents
    updateCounts()

    ## recruitment
    mp_edges = (int) (round(d*mc*pc))#note that this is a simplification of sorts ideally
    # we would randomly select edges
    # I did it for efficiency's sake ... Maybe better to handle with LIST INTERPRETATION
    for i in range(mp_edges):
        if (random() <= alpha):
            convertAgent('potential', 'member')

    ## mirror process for contact induced loss (i.e., recruitment to former)
    mf_edges = (int) (round(g*mc*fc))
    for i in range(mf_edges):
        if (random() <= beta):
            convertAgent('member', 'former')

    
    ## Updating for c and delta.(Passive dropouts)
    for i, agent in enumerate(agents):
        if (agent == 'member'):
            if (random() <= c):
                agents[i] = 'former'
        if (agent == 'former'):
            if (random() <= delta):
                agents[i] = 'potential'


def simpleStep(a, b, c, delta):
    """Preforms one step of the simulation
    this is a version for the (computationally) simplified model
    which uses "effective transition parameters" """
    global agents
    updateCounts()

    ## recruitment
    for i in range(mc*pc):
        if (random() <= a):
            ## For a given random pair what is the probability of
            ## Edge AND successful attack
            convertAgent('potential', 'member')

    ## mirror process for contact induced loss (i.e., recruitment to former)
    for i in range(mc*fc):
        if (random() <= b):
            convertAgent('member', 'former')

    
    ## Updating for c and delta.(Passive dropouts)
    for i, agent in enumerate(agents):
        if (agent == 'member'):
            if (random() <= c):
                agents[i] = 'former'
        if (agent == 'former'):
            if (random() <= delta):
                agents[i] = 'potential'



def init(M_0, P_0, E_0):
    global agents
    
    members = ['member']*M_0
    formers = ['former']*E_0
    potentials = ['potential']*P_0

    agents = members + formers + potentials

def convertAgent(pre: str, post: str)-> 'None':
    global agents
    
    try:
        agents[agents.index(pre)] = post
        
    except ValueError as e:
        pass

    
def randomAgent()-> int:
    return randint(0, len(agents) - 1)


def updateCounts():
    global tc, mc, pc, fc, agents
    tc = len(agents)
    mc = agents.count('member')
    pc = agents.count('potential')
    fc = agents.count('former')


def recordToCsv(agent_rec):
    with open('Hedstrom.csv', 'wt',) as csvfile:
        w = csv.writer(csvfile, delimiter=';')
        for lst in agent_rec:
            w.writerow(lst)


def record_to_lists(agent_rec):
    """Helper function that takes a record list of lists
    and breaks it into "columns". Returns 3 lists, in the column order"""
    M_a = [lst[0] for lst in agent_rec]
    P_a = [lst[1] for lst in agent_rec]
    E_a = [lst[2] for lst in agent_rec]

    return M_a, P_a, E_a
    

def plot(delta_t, final_t):
    global agent_rec

    M_a, P_a, E_a = record_to_lists(agent_rec)
    
    tScale = np.arange(0, final_t+delta_t, delta_t) ## Not sure why this works

    PotsArr = np.asarray(P_a)
    ExArr = np.asarray(E_a)
    MemArr = np.asarray(M_a)
    
    fig, ax = plt.subplots()
    
    ax.plot(tScale, PotsArr, label='Pots')
    ax.plot(tScale, ExArr, label='Ex-mems')
    ax.plot(tScale, MemArr, label='Mems')
    ax.legend()
    plt.show()


def vsplot(agent_rec, diff_rec, agent_step, delta_t, final_t):
    ## record list of lists to numpy arrays

    ## NEED TO TEST ALL OF THIS
    M_a, P_a, E_a = record_to_lists(agent_rec)

    M_d, P_d, E_d = record_to_lists(diff_rec)

    ## get agent based stuff on the graph
    agent_scale = np.arange(0, final_t+agent_step, agent_step)
    ## Not sure why this works or is different from
    ## the code for diff_scale, below

    agent_potsArr = np.asarray(P_a)
    agent_exArr = np.asarray(E_a)
    agent_memArr = np.asarray(M_a)

    fig, ax = plt.subplots()

    ax.plot(agent_scale, agent_potsArr, label='Pots Agents')
    ax.plot(agent_scale, agent_exArr, label='Ex-mems Agents')
    ax.plot(agent_scale, agent_memArr, label='Mems Agents')

    ## Plot diff eqns
    diff_scale=np.arange(0, final_t, delta_t) 
    diff_potsArr = np.asarray(P_d)
    diff_exArr = np.asarray(E_d)
    diff_memArr = np.asarray(M_d)
    
    ax.plot(diff_scale, diff_potsArr, label='Pots Diff')
    ax.plot(diff_scale, diff_exArr, label='Ex-mems Diff')
    ax.plot(diff_scale, diff_memArr, label='Mems Diff')

    ax.legend()
    plt.show()



    
    
