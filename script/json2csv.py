#!/usr/bin/env python3
'''
Convert a json file into a csv file using pandas.

Givin researcher.json as


[
    {
	"first_name": "Pieter",
	"last_name": "Abbeel",
	"homepage":"https://people.eecs.berkeley.edu/~pabbeel",
	"linkedin":"https://www.linkedin.com/in/pieterabbeel",
	"fields": ["deep-learning","reinforcement-learning","robotics"]
    },
    {
	"first_name": "Geoffrey",
	"last_name": "Hinton",
	"homepage":"https://www.cs.toronto.edu/~hinton",
	"wikipedia":"https://www.cs.toronto.edu/~hinton",
	"fields": ["deep-learning"]
    }    
]

will output researcher.csv as

first_name,last_name,homepage,linkedin,fields,wikipedia
Pieter,Abbeel,https://people.eecs.berkeley.edu/~pabbeel,https://www.linkedin.com/in/pieterabbeel,"['deep-learning', 'reinforcement-learning', 'robotics']",
Geoffrey,Hinton,https://www.cs.toronto.edu/~hinton,,['deep-learning'],https://www.cs.toronto.edu/~hinton

'''
import sys
import pandas as pd
pin = sys.argv[1]
pout = pin.replace('.json', '.csv')
df = pd.read_json(pin)
df.to_csv(pout, index=False)    
