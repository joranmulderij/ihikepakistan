from geopy.distance import geodesic
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage
import json
from requests import get
from base64 import b64decode

# Use a service account
cred = credentials.Certificate('ihike-pak-firebase-adminsdk-xqa8m-d9b2ccca7b.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'ihike-pak.appspot.com'
})

db = firestore.client()
fs = storage.bucket()



hikesdoc = db.collection('hikes').get()


def getfromscript(path, name):
    p = path.copy()
    while len(p) > 400:
        del p[0::4]
        del p[0::3]
    url = f'https://script.google.com/macros/s/AKfycbxqX6BM9i5QGWuaisLyQYfwckSOh29K9Xi4oTyUNgY1N6Vcai4WEzAn/exec?path={",".join(str(i) for i in p)}&name={name}'
    e = get(url).text
    l = e.split('<break>')
    return l[0], float(l[1]), l[2]

def getLength(path):
    p = [(i.latitude, i.longitude) for i in path]
    return geodesic(*p).kilometers


number_of_hikes = 0
number_of_segments = 0

hikes = []
for hike in hikesdoc:
    hikedict = hike.to_dict()
    db.collection('hikes_lock').document(hike.id).set(hikedict)
    path = []
    for p in hikedict['path']:
        path.append(p.latitude)
        path.append(p.longitude)
    mapImage, climb, graphImage = getfromscript(path, hikedict['name'])

    map_blob = fs.blob(f'maps/{hike.id}.png')
    map_file = open(f'../maps/{hike.id}.png', 'wb')
    map_file.write(b64decode(mapImage.replace('data:image/png;base64,', '')))
    map_blob.upload_from_filename(f'../maps/{hike.id}.png')

    graph_blob = fs.blob(f'graphs/{hike.id}.png')
    graph_file = open(f'../graphs/{hike.id}.png', 'wb')
    graph_file.write(b64decode(graphImage.replace('data:image/png;base64,', '')))
    graph_blob.upload_from_filename(f'../graphs/{hike.id}.png')

    hikedict['images'].insert(0, f'https://firebasestorage.googleapis.com/v0/b/ihike-pak.appspot.com/o/graphs%2F{hike.id}.png?alt=media')
    length = getLength(hikedict['path'])
    hours = (length / 5 + climb / 600)

    hikejson = {
        "name": hikedict['name'],
        "story": hikedict['description'],
        "storyshort": hikedict['description'][:100] + '...',
        "data": path,
        "difficulty": hikedict['difficulty'],
        "photos": hikedict['images'],
        "photo": f'https://firebasestorage.googleapis.com/v0/b/ihike-pak.appspot.com/o/maps%2F{hike.id}.png?alt=media',
        "time": str(int(hours)) + ':' + str(round((hours%1)*60)),
        "climb": str(round(climb)),
        "length": str(round(length, 2)),
        "unlisted": hikedict.get('unlisted') is True,
    }
    if len(path) > 20 and not hikedict['difficulty'] is None:
        if hikedict.get('unlisted') is True:
            print('Segment:  ', hikedict['name'])
            number_of_segments += 1
        else:
            print('  Valid:  ', hikedict['name'])
            number_of_hikes += 1
        hikes.append(hikejson)
    else:
        print('Invalid:  ', hikedict['name'])

# print(json.dumps(hikes))
print("Number of Hikes:", number_of_hikes)
print("Number of Segments:", number_of_segments)

with open("sample.json", "w+") as outfile:
    json.dump(hikes, outfile)
