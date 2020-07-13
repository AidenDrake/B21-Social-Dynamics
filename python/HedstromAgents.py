"""Implementation of an extremely basic Agent-Based Model, (ABM) to
create similar behaviour to the differential eqaution model given in
Hedstrom, 2006. Can also plot the ABM, alone or vs the differential eqn
model. This module is set up to create similar behaviour to either the
six-parameter system or the four-parameter "effective transition parameter"
system described later in Hedstrom.

The agent based simulation is implemented using a list of strings, with
correspondances to the equations as follows. M(t) -> # of 'member'
strings, P(t) -> # of 'potential' strings, and E(t) -> # of 'potential'
strings. Note that E (for "ex-member") and F are both used as an
abbreviation for the number of former members of the simulated group.

See:
P Hedstrom, Explaining the growth patterns of social movements,
Understanding Choice, Explaining Behavior (Oslo University Press,
Norway, 2006).

Note: Some modifications have been made from Hedstrom's original
equations. d -> k and delta -> phi. I did this to avoid confusing
myself, since "d" and "delta" are commonly used in the context of
differential equations.
"""
from random import randint, random
import numpy as np
import matplotlib.pyplot as plt
import csv
import DiffEqn

tc = mc = fc = pc = 0
## tc -- total count, mc -- member count, fc -- former count,
## pc -- potential cout.

agents = []

IOGT_fitted_values={'M_0':60, 'P_0':2430, 'E_0':10,
                    'params':(0.0003, 0.009, 0.08, 0.68),
                    'final_t':100,}
## The parameters for the Independant Order of Good Templars model,
## that is, as given by Hedstrom after fitting to historical data.

## Note: E for "ex-member" is used for "former" agents

agent_rec = []


def simvsdiff(M_0:int=1, P_0:int=498, E_0:int=1,
               params:tuple=(0.01, 0.01, 0.1, 0.1, 0.1, 0.1),
               final_t:int=200, _delta_t:float=0.7, should_print=False):
    """Runs the ABM and the differential equation models, and plots
    the outcome.

    Keyword arguments:
    M_0 -- the number of staring MEMBERS, P_0 -- POTENTIALS, E_0 -- FORMERS
    params -- Parameters which will be "fed" to both the diff eqn model
    and the ABM model. Format is (d, g, alpha, beta, c, delta) OR
    (a, b, c, delta)
    final_t -- the final t value for both models
    _delta_t -- the stepping value for the diff eqn model.
    If the diff eqn model does not work, set this lower.
    should_print -- generate printed output if True
    """
    
    agent_rec = simulation(M_0, P_0, E_0, params, False, final_t, should_print)

    diff_rec = DiffEqn.diffrun(M_0, P_0, E_0, _delta_t, params, final_t)

    vsplot(agent_rec, diff_rec, 1, _delta_t, final_t)


def simulation(M_0:int=1, P_0:int=498, E_0:int=1,
               params:tuple=(0.01, 0.01, 0.1, 0.1, 0.1, 0.1),
               export:bool=False, steps:int=200, should_print=False):
    """Runs the simulation. Default values represent the dummy trial
    from Hedstrom paper, Fig.2
    
    simulation(**kwargs)

    Keyword arguements:
    M_0 -- the number of staring MEMBERS, P_0 -- POTENTIALS, E_0 -- FORMERS
    params -- (d, g, alpha, beta, c, delta) OR (a, b, c, delta)
    Export -- write to csv?
    steps -- how many steps to run
    should_print -- generate printed output if True
    """
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
        
        
def step(k, g, alpha, beta, c, phi):
    """Runs one step of the simulation.
    This is a version for the 4-parameter version of the model
    """
    global agents
    updateCounts()

    ## recruitment
    mp_edges = (int) (round(k*mc*pc))#note that this is a simplification of sorts ideally
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
            if (random() <= phi):
                agents[i] = 'potential'


def simpleStep(a, b, c, phi):
    """Preforms one step of the simulation.
    This is a version for the (computationally) simplified model
    which uses "effective transition parameters"
    """
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

    
    ## Updating for c and phi.(Passive dropouts)
    for i, agent in enumerate(agents):
        if (agent == 'member'):
            if (random() <= c):
                agents[i] = 'former'
        if (agent == 'former'):
            if (random() <= phi):
                agents[i] = 'potential'


def init(M_0, P_0, E_0):
    """Makes the agent list with given initial values"""
    global agents
    
    members = ['member']*M_0
    formers = ['former']*E_0
    potentials = ['potential']*P_0

    agents = members + formers + potentials


def convertAgent(pre: str, post: str)-> 'None':
    """Switches an agent from one group (pre) to another (post).
    At the implementation level, this means switching the string at the
    list index of the first occurance of the (pre) stirng.
    """
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


def recordToCsv(rec):
    """Writes the previous trial to diffeqn.csv.
    Format is  "<M>; <P>; <E>", the same order as used in the record"""
    with open('Hedstrom.csv', 'wt',) as csvfile:
        w = csv.writer(csvfile, delimiter=';')
        for lst in rec:
            w.writerow(lst)


def record_to_lists(agent_rec):
    """Helper function that takes a record list of lists
    and breaks it into "columns". Returns 3 lists, in the column order
    """
    M_a = [lst[0] for lst in agent_rec]
    P_a = [lst[1] for lst in agent_rec]
    E_a = [lst[2] for lst in agent_rec]

    return M_a, P_a, E_a
    

def plot(delta_t, final_t):
    """Plots the ABM results on a matplotlib chart"""
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
    """Plots the ABM results and differential eqn results for comparison"""

    ## change record's list of lists to numpy arrays
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

    ax.plot(agent_scale, agent_potsArr, label='Potential - Agents', color='xkcd:goldenrod', )
    ax.plot(agent_scale, agent_exArr, label='Former - Agents', color='xkcd:dark blue')
    ax.plot(agent_scale, agent_memArr, label='Mems - Agents', color='xkcd:brick red')

    ## Plot diff eqns
    diff_scale=np.arange(0, final_t, delta_t) 
    diff_potsArr = np.asarray(P_d)
    diff_exArr = np.asarray(E_d)
    diff_memArr = np.asarray(M_d)
    
    ax.plot(diff_scale, diff_potsArr, label='Potential - ODE', color = 'xkcd:light yellow')
    ax.plot(diff_scale, diff_exArr, label='Fromer - ODE', color='xkcd:baby blue')
    ax.plot(diff_scale, diff_memArr, label='Member - ODE', color='xkcd:pink')

    ## matplotlib setup
    ax.set_xlabel('time')
    ax.set_ylabel('population')
    ax.set_title('Group membership over time, in ODE and ABM')
    ax.legend()
    plt.show()



    
    
