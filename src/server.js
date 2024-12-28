const WebSocket = require('ws');
const net = require('net');
const { Decimal } = require('decimal.js');

// Common trading pairs
const TRADING_PAIRS = [
  'btcusdt', 'ethusdt', 'bnbusdt', 'xrpusdt', 'adausdt',
  'dogeusdt', 'dotusdt', 'uniusdt', 'ltcusdt', 'linkusdt',
  'solusdt', 'maticusdt', 'atomusdt', 'avaxusdt', 'etcusdt'
];

// Store latest prices
const prices = new Map();

// Binance WebSocket connection
const binanceWs = new WebSocket('wss://stream.binance.com:9443/ws/!miniTicker@arr');

binanceWs.on('message', (data) => {
  const tickers = JSON.parse(data);
  tickers.forEach(ticker => {
    const symbol = ticker.s.toLowerCase();
    if (TRADING_PAIRS.includes(symbol)) {
      prices.set(symbol, {
        bid: new Decimal(ticker.c).toFixed(8),
        ask: new Decimal(ticker.c).mul(1.0001).toFixed(8), // Simulated ask price
        timestamp: Date.now()
      });
    }
  });
});

// TCP Server for MT4
const server = net.createServer((socket) => {
  console.log('MT4 Client connected');

  // Send prices every second
  const intervalId = setInterval(() => {
    const priceData = [];
    prices.forEach((price, symbol) => {
      priceData.push(`${symbol.toUpperCase()},${price.bid},${price.ask}`);
    });
    
    if (priceData.length > 0) {
      socket.write(priceData.join('|') + '\n');
    }
  }, 1000);

  socket.on('error', (err) => {
    console.error('Socket error:', err);
    clearInterval(intervalId);
  });

  socket.on('close', () => {
    console.log('Client disconnected');
    clearInterval(intervalId);
  });
});

const PORT = 5555;
server.listen(PORT, () => {
  console.log(`Market data server listening on port ${PORT}`);
});