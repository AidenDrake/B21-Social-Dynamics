from random import randint, random
import csv

## This is NOT running right now and I don't know why :(

tc = mc = fc = pc = 0
agents = []

IOGT_fitted_values={'mems':60, 'pots':2430, 'forms':10,
                    'params':(0.0003, 0.009, 0.08, 0.68),
                    'steps':100,}
## The values for the independant order of good templars model

def simulation(mems:int=1, pots:int=498, forms:int=1,
               params:tuple=(0.01, 0.01, 0.1, 0.1, 0.1, 0.1),
               export:bool=True, steps:int=200) -> list:
    """Runs the simulation. Default values represent the dummy trial
    from Hedstrom Chapter, Fig.2
    
    simulation(**kwargs)

    
    mems: the number of staring MEMBERS, pots: POTENTIALS, forms: FORMERS
    params: (d, g, alpha, beta, c, delta) OR (a, b, c, delta)
    Export: write to csv?
    steps=how many steps to run"""
    global agents

    record =[]

    init(mems, pots, forms)

    updateCounts()

    print('starting values:', 'members:', mc, 'potentials:',
              pc, 'formers:', fc)

    l = len(params)

    for i in range(steps):
        record.append([mc, pc, fc])
        ## Not thrilled about this,
        ## it splits the stepping based on the number of args
        ## given in the tuple
        if (l == 6):
            step(*params)
        elif (l == 4):
            simpleStep(*params)
        else:
            raise Exception('Param should have 4 or 6 values')
        updateCounts()
        print('members:', mc, 'potentials:',
             pc, 'formers:', fc)
        
    record.append([mc, pc, fc]) ## for the final update
    
    if (export == True):
        recordToCsv(record)

    return record
        
        
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




def init(mems, pots, forms):
    global agents
    
    members = ['member']*mems
    formers = ['former']*forms
    potentials = ['potential']*pots

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
    global tc, mc, pc, fc
    tc = len(agents)
    mc = agents.count('member')
    pc = agents.count('potential')
    fc = agents.count('former')

def recordToCsv(record):
    with open('Hedstrom.csv', 'wt',) as csvfile:
        w = csv.writer(csvfile, delimiter=';')
        for lst in record:
            w.writerow(lst)



    
    
