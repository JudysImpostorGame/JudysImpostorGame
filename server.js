import express from 'express';
import http from 'http';
import { Server } from 'socket.io';

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

const rooms = {};

function generateCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 4; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
}

io.on('connection', socket => {
  socket.on('createRoom', ({ name }, cb) => {
    let code;
    do { code = generateCode(); } while (rooms[code]);
    rooms[code] = { host: socket.id, players: [{ id: socket.id, name }] };
    socket.join(code);
    cb({ code });
    io.to(code).emit('playerList', rooms[code].players.map(p => p.name));
  });

  socket.on('joinRoom', ({ code, name }, cb) => {
    const room = rooms[code];
    if (!room) return cb({ error: 'Room not found' });
    room.players.push({ id: socket.id, name });
    socket.join(code);
    cb({});
    io.to(code).emit('playerList', room.players.map(p => p.name));
  });

  socket.on('startGame', ({ code, assignments }) => {
    const room = rooms[code];
    if (!room || room.host !== socket.id) return;
    room.players.forEach(p => {
      const word = assignments[p.name];
      if (word) io.to(p.id).emit('wordAssignment', { word });
    });
    io.to(code).emit('gameStarted');
  });

  socket.on('disconnect', () => {
    for (const [code, room] of Object.entries(rooms)) {
      const idx = room.players.findIndex(p => p.id === socket.id);
      if (idx >= 0) {
        room.players.splice(idx, 1);
        io.to(code).emit('playerList', room.players.map(p => p.name));
        if (room.players.length === 0) delete rooms[code];
      }
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log('Server running on ' + PORT));
