from yaml import load, dump, Loader, Dumper
import sys
import csv
import uuid
import copy

def index(component):
  result = {}
  implemented_requirements = component['component-definition']['components'][0]['control-implementations'][0]['implemented-requirements']
  for requirement in implemented_requirements:
    result[requirement['control-id']] = requirement
  return result

def load_csv_row(row):
  result = {}
  result['control_id'] = row[0].replace('(', '.').replace(')', '').lower()
  result['description'] = row[3] 
  if row[8] != '':
    result['rules'] = load(row[8], Loader)['rules']
  return result

def load_csv(csv_reader):
  csv_reader.__next__()
  csv_reader.__next__()
  to_insert = []
  for row in csv_reader:
    implemented = load_csv_row(row)
    if 'rules' in implemented:
      to_insert.append(implemented)
  return to_insert

metadata_file = sys.argv[1]
with open(metadata_file, 'r') as stream:
  metadata = load(stream, Loader)
component = copy.deepcopy(metadata)
component['component-definition']['components'][0]['control-implementations'][0]['implemented-requirements'] = []

csv_file = sys.argv[2]
with open(csv_file, 'r') as stream:
  to_insert = load_csv(csv.reader(stream))

for control in to_insert:
  id = control['control_id']
  new_uuid = str(uuid.uuid4())
  req_obj = {}
  req_obj['uuid'] = new_uuid
  req_obj['description'] = control['description']
  req_obj['rules'] = control['rules']
  req_obj['control-id'] = id
  component['component-definition']['components'][0]['control-implementations'][0]['implemented-requirements'].append(req_obj)

print(dump(component, Dumper=Dumper))
