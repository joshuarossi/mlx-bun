"""Exercise real child startup, one recovery, completion resume and port ownership."""
import json
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import unittest

SERVER = '''
import json,sys
from pathlib import Path
from http.server import HTTPServer,BaseHTTPRequestHandler
counter=Path(sys.argv[2])
class Handler(BaseHTTPRequestHandler):
 def log_message(self,*args):pass
 def do_GET(self):
  self.send_response(200);self.end_headers();self.wfile.write(b'{}')
 def do_POST(self):
  self.rfile.read(int(self.headers['Content-Length']))
  n=int(counter.read_text()) if counter.exists() else 0
  counter.write_text(str(n+1))
  if n==0:
   self.send_error(503,'one deliberate infrastructure failure');return
  self.send_response(200);self.end_headers()
  values=[{'choices':[{'delta':{'content':'#### 42'},'finish_reason':'stop'}]}, {'usage':{'completion_tokens':3,'prompt_tokens':2}}, '[DONE]']
  for v in values:self.wfile.write(('data: '+(v if isinstance(v,str) else json.dumps(v))+'\\n\\n').encode())
HTTPServer(('127.0.0.1',int(sys.argv[1])),Handler).serve_forever()
'''


class CampaignTests(unittest.TestCase):
    def test_recovers_once_and_does_not_regenerate_completed_job(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp)
            server=root/'server.py';server.write_text(SERVER)
            with socket.socket() as s:
                s.bind(('127.0.0.1',0));port=s.getsockname()[1]
            items=root/'items.jsonl';items.write_text(json.dumps({'id':'gsm8k/test','suite':'gsm8k','answer':'42','messages':[{'role':'user','content':'fixture'}]})+'\n')
            counter=root/'counter'
            job={'id':'fixture','command':[sys.executable,str(server),str(port),str(counter)],
                 'healthUrl':f'http://127.0.0.1:{port}/health','items':str(items),
                 'config':{'baseUrl':f'http://127.0.0.1:{port}/v1','request':{'model':'fixture'},'timeoutSeconds':5}}
            plan=root/'plan.json';plan.write_text(json.dumps({'jobs':[job]}))
            out=root/'results'
            command=[sys.executable,str(Path(__file__).with_name('run-http-campaign.py').resolve()),'--plan',str(plan),'--out',str(out)]
            run=subprocess.run(command,capture_output=True,text=True,timeout=30)
            self.assertEqual(run.returncode,0,run.stdout+run.stderr)
            self.assertEqual(counter.read_text(),'2')
            self.assertEqual(json.loads((out/'fixture/exit.json').read_text())['attempts'],2)
            generation=next((out/'fixture/generations').glob('*.result.json'))
            self.assertTrue(json.loads(generation.read_text())['score']['correct'])
            first=next((out/'fixture/generations/attempts').rglob('*.result.json'))
            self.assertEqual(json.loads(first.read_text())['status'],'error')
            resumed=subprocess.run(command,capture_output=True,text=True,timeout=10)
            self.assertEqual(resumed.returncode,0,resumed.stderr)
            self.assertEqual(counter.read_text(),'2')
            # Successful cleanup leaves the server port available.
            with socket.socket() as s:
                s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
                s.bind(('127.0.0.1',port))


if __name__=='__main__':unittest.main()
