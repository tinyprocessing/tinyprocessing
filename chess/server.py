import subprocess
import threading
import time

active_process = None
active_process_lock = threading.Lock()

import os
import signal

def kill_process(process):
    if process.poll() is None:
        try:
            process.terminate()
            try:
                process.wait(timeout=2)
            except Exception:
                # If still not dead, force kill
                process.kill()
        except Exception:
            pass
    # Additionally, kill by PGID (if needed, for child processes)
    try:
        os.killpg(os.getpgid(process.pid), signal.SIGKILL)
    except Exception:
        pass

import subprocess
import time
import shutil

def analyze_stockfish(
    fen, multipv=1, depth=20, threads=2, hash_mb=128, path="/opt/homebrew/bin/stockfish",
    timeout=40, retries=2
):
    print("Stockfish path for subprocess:", shutil.which(path))
    last_error = None

    for attempt in range(retries):
        process = None
        try:
            process = subprocess.Popen(
                [path],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True,
                bufsize=1
            )
            def send(cmd):
                if process.poll() is not None:
                    raise RuntimeError("Stockfish process died unexpectedly")
                process.stdin.write(cmd + "\n")
                process.stdin.flush()

            send("uci")
            send(f"setoption name Threads value {threads}")
            send(f"setoption name Hash value {hash_mb}")
            send(f"setoption name MultiPV value {multipv}")
            send("setoption name Contempt value 100")
            send("setoption name UCI_LimitStrength value false")
            send("setoption name UCI_Elo value 3190")
            send("isready")
            while True:
                line = process.stdout.readline()
                if "readyok" in line:
                    break

            send(f"position fen {fen}")
            send("isready")
            while True:
                line = process.stdout.readline()
                if "readyok" in line:
                    break

            send(f"go depth {depth}")

            lines = []
            t_start = time.time()
            while True:
                if (time.time() - t_start) > timeout:
                    raise TimeoutError("Stockfish timed out")
                line = process.stdout.readline()
                if not line:
                    break
                lines.append(line.strip())
                if line.startswith("bestmove"):
                    break

            send("quit")
            try:
                process.wait(timeout=2)
            except Exception:
                process.terminate()
            return lines

        except Exception as e:
            last_error = str(e)
            if process is not None:
                kill_process(process)
                try:
                    process.terminate()
                except Exception:
                    pass
                try:
                    err = process.stderr.read()
                    print("Stockfish stderr:", err)
                except Exception:
                    print("Could not read Stockfish stderr")

            if "Broken pipe" in last_error or "Stockfish process died" in last_error:
                if attempt < retries - 1:
                    print(f"Retrying Stockfish due to error: {last_error}")
                    time.sleep(0.5)  # short pause before retry
                    continue

            if attempt == retries - 1:
                raise Exception(f"Stockfish failed after {retries} attempts: {last_error}")

from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/analyze", methods=["POST"])
def analyze():
    data = request.json
    fen = data.get("fen")
    multipv = int(data.get("multipv", 1))
    depth = 19

    if not fen:
        return jsonify({"error": "No FEN given"}), 400

    print("start process", fen)
    try:
        lines = analyze_stockfish(fen, multipv=multipv, depth=depth)
    except Exception as e:
        print(e)
        return jsonify({"error": str(e)}), 500

    # parse lines as before ...

    # Same parsing logic as before...
    analysis = []
    for line in lines:
        if line.startswith("info") and " pv " in line and ("score cp" in line or "score mate" in line):
            pv_data = {}
            if "score mate" in line:
                try:
                    score = "#" + line.split("score mate")[1].split()[0]
                    pv_data['score'] = score
                except: pass
            elif "score cp" in line:
                try:
                    cp = int(line.split("score cp")[1].split()[0])
                    pv_data['score'] = f"{cp/100:.2f}"
                except: pass
            pv_moves = line.split(" pv ")[1].strip().split()
            pv_data['pv'] = pv_moves
            analysis.append(pv_data)
    bestmove = None
    for line in lines:
        if line.startswith("bestmove"):
            bestmove = line.split()[1]

    return jsonify({
        "bestmove": bestmove,
        "analysis": analysis,
        "raw": lines
    })

if __name__ == "__main__":
    port = 5005
    app.run(port=port, debug=False)
