import json
import ConfigParser

def load_json_file(file_path):
  with open(file_path, 'r') as f:
    datastore = json.load(f)
    return datastore

def test_random_start():
  file_contents = load_json_file('/tmp/glances-init')
  print file_contents

def test_http_flush():
  file_contents = load_json_file('/tmp/glances-init')
  print file_contents

def test_config_file():
  config = ConfigParser.ConfigParser()
  config.read('/etc/cloudadmin/cloudadmin.conf')
  assert config.get('CloudAdmin','APIKey') == "abcd1234"
  assert config.get('CloudAdmin','URL') == "https://metrics.cloudadmin.io"
