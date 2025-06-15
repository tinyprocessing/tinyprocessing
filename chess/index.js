(async () => {
  const url = "https://lichess.org/assets/npm/@lichess-org/stockfish-web/sf171-79.js";
  const module = await import(url);
  const stockfish = await module.default();
  window.sf = stockfish;

  let currentFEN = "";
  let evalText = "Eval: ?";
  let bestMoveText = "Best: ?";

  const label = document.createElement("div");
  label.style.position = "absolute";
  label.style.top = "10px";
  label.style.left = "10px";
  label.style.zIndex = "9999";
  label.style.background = "rgba(0, 0, 0, 0.7)";
  label.style.color = "#fff";
  label.style.padding = "6px 10px";
  label.style.borderRadius = "4px";
  label.style.fontFamily = "monospace";
  label.style.fontSize = "14px";
  label.style.pointerEvents = "none";
  label.textContent = "Waiting for Stockfish...";
  document.body.appendChild(label);

  function updateLabel() {
    label.textContent = `${evalText} | ${bestMoveText}`;
  }

  function flipXYInFEN(fen) {
    if (typeof fen !== 'string' || !fen.includes('/')) {
      throw new Error("Invalid FEN input");
    }

    const [position, turn = 'w', castling = '-', enPassant = '-', halfmove = '0', fullmove = '1'] = fen.trim().split(/\s+/);

    const ranks = position.split('/').reverse();
    const flippedRanks = ranks.map(rank => {
      const expanded = rank.replace(/\d/g, d => ' '.repeat(parseInt(d)));
      const reversed = expanded.split('').reverse().join('');
      const compressed = reversed.replace(/ +/g, s => s.length);
      return compressed;
    });

    const flipCastleMap = { K: 'Q', Q: 'K', k: 'q', q: 'k' };
    const flippedCastling = castling
      .split('')
      .map(c => flipCastleMap[c] || c)
      .join('')
      .replace(/[^KQkq]/g, '') || '-';

    let flippedEnPassant = '-';
    if (enPassant !== '-') {
      const fileMap = { a: 'h', b: 'g', c: 'f', d: 'e', e: 'd', f: 'c', g: 'b', h: 'a' };
      const file = fileMap[enPassant[0]];
      const rank = 9 - parseInt(enPassant[1]);
      flippedEnPassant = file + rank;
    }

    return [
      flippedRanks.join('/'),
      turn,
      flippedCastling,
      flippedEnPassant,
      halfmove,
      fullmove
    ].join(' ');
  }

  sf.uci("uci");
  sf.uci("ucinewgame");

  sf.listen = (line) => {
    console.log("Overridden listen:", line);

    if (line.startsWith("info")) {
      const scoreMatch = line.match(/score (cp|mate) (-?\d+)/);
      const pvMatch = line.match(/\spv\s([a-h][1-8][a-h][1-8](?:\s[a-h][1-8][a-h][1-8])*)/);

      if (scoreMatch) {
        const [, type, value] = scoreMatch;
        const evalStr = type === "cp"
          ? `Eval: ${(parseInt(value, 10) / 100).toFixed(2)}`
          : `Eval: #${value}`;
        evalText = evalStr;
      }

      if (pvMatch && pvMatch[1]) {
        const pvMoves = pvMatch[1].trim().split(/\s+/);
        bestMoveText = pvMoves.length > 0 ? `Best: ${pvMoves[0]}` : `Best: ?`;
      }

      updateLabel();
    }

    if (line.startsWith("bestmove")) {
      const bestMatch = line.match(/bestmove\s([a-h][1-8][a-h][1-8])/);
      if (bestMatch) {
        bestMoveText = `Best: ${bestMatch[1]}`;
        updateLabel();
      }
    }
  };

  function evaluateFEN(fen) {
    sf.uci("stop");
    const sideToMove = fen.split(" ")[1];
    const correctedFEN = sideToMove === 'b' ? flipXYInFEN(fen) : fen;
    currentFEN = correctedFEN;
    sf.uci(`position fen ${correctedFEN}`);
    sf.uci("d");
    sf.uci("go depth 30");
  }

  const board = document.querySelector("cg-container");
  const observer = new MutationObserver(() => {
    const fen = lichessTools.getPositionFromBoard(board, true);
    if (fen && fen !== currentFEN) {
      evaluateFEN(fen);
    }
  });

  observer.observe(board, {
    childList: true,
    subtree: true,
  });
})();
