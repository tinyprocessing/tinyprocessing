#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver   import ThreadingMixIn
import json, sys, time
import subprocess, os, signal, platform

class _LogHandler(BaseHTTPRequestHandler):
    server_version = ''            # silence banner

    def do_POST(self):
        length = int(self.headers.get('content-length', 0))
        data   = self.rfile.read(length).decode('utf‑8', 'replace')
        try:
            payload = json.loads(data)
            msg     = payload.get('m', '')
        except json.JSONDecodeError:
            msg = data
        ts = time.strftime('%H:%M:%S')
        print(f'[{ts}] {msg}', flush=True)
        self.send_response(204)     # no‑content

    def log_message(self, *_):      # silence default access log
        pass

class _Threaded(ThreadingMixIn, HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

def _free_port(port: int):
     if platform.system() not in {'Darwin', 'Linux'}:  # keep it POSIX‑only
         return
     try:
         pids = subprocess.check_output(['lsof', '-ti', f'tcp:{port}']) \
                       .decode().split()
         for pid in pids:
             os.kill(int(pid), signal.SIGTERM)        # graceful first
         time.sleep(0.2)                              # small grace period
     except subprocess.CalledProcessError:
         pass

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 7331
    _free_port(port)
    try:
        srv = _Threaded(('', port), _LogHandler)
    except OSError as e:
        print(f'port {port} busy: {e.strerror}', file=sys.stderr)
        sys.exit(1)

    print(f'⇡ listening on http://localhost:{port}', file=sys.stderr)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        srv.server_close()

