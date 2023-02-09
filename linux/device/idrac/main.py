import json
with open('./input.json', 'r') as a,open('./output.csv', 'w') as b:
  data = json.load(a)
  b.write('host,elementname,version\n')
  hosts = data['plays'][0]['tasks']
  _hosts = next((i for i in hosts if i['task']['name']== 'Show'),None)
  for x,y in _hosts['hosts'].items():
    components = [ {'elementname': i['ElementName'].replace(',','.'), 'version': i['VersionString'].replace(',','.')} for i in y['msg'] ]
    for z in components:
      b.write('{},{},{}\n'.format(x,z['elementname'],z['version']))