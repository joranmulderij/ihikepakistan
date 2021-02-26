from geopy.distance import geodesic
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json
from requests import get

# Use a service account
cred = credentials.Certificate('ihike-pak-firebase-adminsdk-n2qxs-11fede33d4.json')
firebase_admin.initialize_app(cred)

db = firestore.client()
hikesdoc = db.collection('hikes').get()


def getfromscript(path, name):
    p = path.copy()
    while len(p) > 500:
        del p[0::4]
        del p[0::3]
    url = f'https://script.google.com/macros/s/AKfycbxqX6BM9i5QGWuaisLyQYfwckSOh29K9Xi4oTyUNgY1N6Vcai4WEzAn/exec?path={",".join(str(i) for i in p)}&name={name}'
    e = get(url).text
    l = e.split('<break>')
    return l[0], float(l[1]), l[2]

def getLength(path):
    p = [(i.latitude, i.longitude) for i in path]
    return geodesic(*p).kilometers


hikes = []
for hike in hikesdoc:
    hikedict = hike.to_dict()
    db.collection('hikes_lock').document(hike.id).set(hikedict)
    path = []
    for p in hikedict['path']:
        path.append(p.latitude)
        path.append(p.longitude)
    mapImage, climb, graphImage = getfromscript(path, hikedict['name'])
    hikedict['images'].insert(0, graphImage)
    length = getLength(hikedict['path'])
    hours = (length / 5 + climb / 600)

    hikejson = {
        "name": hikedict['name'],
        "story": hikedict['description'],
        "storyshort": hikedict['description'][:100] + '...',
        "data": path,
        "difficulty": hikedict['difficulty'],
        "photos": hikedict['images'],
        "photo": mapImage,
        "time": str(int(hours)) + ':' + str(round((hours%1)*60)),
        "climb": str(round(climb)),
        "length": str(round(length, 2)),
    }
    if len(path) > 20 and not hikedict['difficulty'] is None:
        print('  Valid:  ', hikedict['name'])
        hikes.append(hikejson)
    else:
        print('Invalid:  ', hikedict['name'])

# print(json.dumps(hikes))

with open("sample.json", "w+") as outfile:
    json.dump(hikes, outfile)
