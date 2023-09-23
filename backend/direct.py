from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse
from flask_cors import CORS
import os
import csv
import json
import networkx as nx
import matplotlib.pyplot as plt
from collections import deque

# Create an empty graph
G = nx.Graph()

coordinates = {
    "entrance": (0, 0),
    "Intersection_01": (0, 5),
    "Intersection_02": (0, 10),
    "Intersection_03": (-5, 10),
    "Intersection_04": (-5, 15),
    "Intersection_05": (-5, 20),
    "Intersection_06": (0, 20),
    "Intersection_07": (5, 20),
    "Intersection_08": (5, 15),
    "Intersection_09": (5, 10),
    "lift 01": (2, 5),
    "lift 02": (0, 21),
    "tpo": (-6, 10),
    "washroom": (-6, 20),
    "classroom 01": (-6, 15),
    "classroom 02": (-6, 21),
    "classroom 03": (5, 21),
    "classroom 04": (6, 20),
    "classroom 05": (6, 15),
    "classroom 06": (6, 10),
}

edges = [
    ("entrance", "Intersection_01"),
    ("Intersection_01", "lift 01"),
    ("Intersection_01", "Intersection_02"),
    ("Intersection_02", "Intersection_03"),
    ("Intersection_02", "Intersection_09"),
    ("Intersection_03", "Intersection_04"),
    ("Intersection_04", "Intersection_05"),
    ("Intersection_05", "Intersection_06"),
    ("Intersection_06", "Intersection_07"),
    ("Intersection_07", "Intersection_08"),
    ("Intersection_08", "Intersection_09"),
    ("Intersection_03", "tpo"),
    ("Intersection_05", "washroom"),
    ("Intersection_06", "lift 02"),
    ("Intersection_04", "classroom 01"),
    ("Intersection_05", "classroom 02"),
    ("Intersection_07", "classroom 03"),
    ("Intersection_07", "classroom 04"),
    ("Intersection_08", "classroom 05"),
    ("Intersection_09", "classroom 06"),
]


# Add nodes and edges to the graph
G.add_nodes_from(coordinates.keys())
G.add_edges_from(edges)

# Function to calculate distance between two nodes (coordinates)
def calculate_distance(node1, node2):
    x1, y1 = coordinates[node1]
    x2, y2 = coordinates[node2]
    return ((x1 - x2) ** 2 + (y1 - y2) ** 2) ** 0.5

# Function to calculate direction between two nodes
def calculate_direction(node1, node2):
    x1, y1 = coordinates[node1]
    x2, y2 = coordinates[node2]
    
    if x2 > x1:
        return "Go right"
    elif x2 < x1:
        return "Go left"
    elif y2 > y1:
        return "Go straight"
    elif y2 < y1:
        return "Turn around and go straight"
    else:
        return "Stay in place"

# Perform BFS to find the shortest path and calculate distances and directions
def bfs_shortest_path(graph, start, goal):
    queue = deque([(start, [start], 0)])  # Include distance in the queue
    visited = set()

    while queue:
        node, path, total_distance = queue.popleft()

        if node == goal:
            return path, total_distance

        if node not in visited:
            visited.add(node)
            neighbors = list(graph.neighbors(node))
            for neighbor in neighbors:
                edge_distance = calculate_distance(node, neighbor)
                direction = calculate_direction(node, neighbor)
                queue.append((neighbor, path + [neighbor], total_distance + edge_distance))

    return None, None

def determine_direction(node1, node2):
    x1, y1 = coordinates[node1]
    x2, y2 = coordinates[node2]
    dx = x2 - x1
    dy = y2 - y1
    if(dx == 0 and dy >0):
        return "N"
    elif(dx >0 and dy == 0):
        return "E"
    elif(dx == 0 and dy <0): 
        return "S"
    elif (dx <0 and dy == 0):
        return "W"
    else:
        return "unknown direction"
    

def move_ins(curr,next):
    dict = {'N':1,'E':2,'S':3,'W':4}
    if(dict[next]-dict[curr]==1 or dict[next]-dict[curr]==-3):
        return "Go right"
    elif(dict[next]-dict[curr]==-1 or dict[next]-dict[curr]==3):
        return "Go left"
    elif(dict[next]-dict[curr]==0):
        return "Go straight"
    elif(abs(dict[next]-dict[curr])==2):
        return "Turn around and go straight"
    else:
        return "unknow move"

parser = reqparse.RequestParser()
app = Flask(__name__)
api = Api(app)
app.config.from_object(__name__)
CORS(app, resources={r'/*': {'origins': '*'}})
nodes_list=list(G.nodes())
print(json.dumps({'nodes':nodes_list}))

class navapi(Resource):
    def get(self):
        nodes_list=list(G.nodes())
        return jsonify(nodes_list)
    def post(self):
        parser.add_argument('start', type=str)
        parser.add_argument('goal', type=str)
        args = parser.parse_args()
        
        if args['start'] not in G.nodes() or args['goal'] not in G.nodes():
            # Return an error response with a 500 status code
            return jsonify({'error': 'Internal Server Error'}), 500
        
        shortest_path, total_distance = bfs_shortest_path(G,args["start"],args["goal"])
        if shortest_path:
            dist=[]
            dirc=[]
            for i in range(len(shortest_path) - 1):
                node1, node2 = shortest_path[i], shortest_path[i + 1]
                currdist = calculate_distance(node1, node2)
                currdirc = determine_direction(node1, node2)
                dist.append(currdist)
                dirc.append(currdirc)
            dirc = ['N']+dirc
            dircfinal=[]
            inst=[]
            for i in range(len(dirc)-1):
                dircfinal.append(move_ins(dirc[i], dirc[i + 1]))
                inst.append((dist[i],dircfinal[i]))
            return jsonify(Path=shortest_path,Instructions=inst)
        else:
            return jsonify(Path=shortest_path)
        

api.add_resource(navapi, '/navapi')
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)