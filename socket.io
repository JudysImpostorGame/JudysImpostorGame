// Impostor Game Setup using socket.io
// This file outlines the server and client setup for an online version of the game using socket.io.

/\* --------------------------- Server Setup (Node.js) --------------------------- \*/

// Required modules:
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

const PORT = 3000;

// Serve static files
app.use(express.static('public'));

// In-memory room data
const rooms = {};

io.on('connection', (socket) => {
console.log('A user connected:', socket.id);

socket.on('createRoom', ({ playerName }) => {
const roomCode = generateRoomCode();
rooms\[roomCode] = {
host: socket.id,
players: \[{ id: socket.id, name: playerName }],
started: false,
assignedWords: {}
};
socket.join(roomCode);
socket.emit('roomCreated', { roomCode });
io.to(roomCode).emit('updatePlayers', rooms\[roomCode].players);
});

socket.on('joinRoom', ({ roomCode, playerName }) => {
if (rooms\[roomCode]) {
rooms\[roomCode].players.push({ id: socket.id, name: playerName });
socket.join(roomCode);
io.to(roomCode).emit('updatePlayers', rooms\[roomCode].players);
} else {
socket.emit('error', 'Room not found');
}
});

socket.on('startGame', ({ roomCode, word, impostorCount }) => {
const room = rooms\[roomCode];
if (room && socket.id === room.host) {
const players = room.players;
const shuffled = \[...players].sort(() => Math.random() - 0.5);
const impostors = shuffled.slice(0, impostorCount);
players.forEach(p => {
const wordAssignment = impostors.includes(p) ? 'IMPOSTOR' : word;
room.assignedWords\[p.id] = wordAssignment;
io.to(p.id).emit('assignWord', wordAssignment);
});
room.started = true;
io.to(roomCode).emit('gameStarted');
}
});

socket.on('disconnect', () => {
for (const roomCode in rooms) {
const room = rooms\[roomCode];
room.players = room.players.filter(p => p.id !== socket.id);
if (room.players.length === 0) delete rooms\[roomCode];
else io.to(roomCode).emit('updatePlayers', room.players);
}
console.log('User disconnected:', socket.id);
});
});

function generateRoomCode() {
const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
let code = '';
for (let i = 0; i < 4; i++) code += chars.charAt(Math.floor(Math.random() \* chars.length));
return code;
}

server.listen(PORT, () => {
console.log(`Server listening on http://localhost:${PORT}`);
});

/\* --------------------------- Client Events (index.html) --------------------------- \*/

// Socket.io client setup
const socket = io();

function createRoom() {
const playerName = document.getElementById('playerName').value.trim();
socket.emit('createRoom', { playerName });
}

function joinRoom() {
const roomCode = document.getElementById('roomCodeInput').value.trim().toUpperCase();
const playerName = document.getElementById('playerName').value.trim();
socket.emit('joinRoom', { roomCode, playerName });
}

function startGame() {
const impostorCount = parseInt(document.getElementById('impostorCount').value);
const word = selectedGameWord(); // Replace with real word logic
socket.emit('startGame', { roomCode: currentRoomCode, word, impostorCount });
}

socket.on('roomCreated', ({ roomCode }) => {
currentRoomCode = roomCode;
console.log('Room created:', roomCode);
});

socket.on('updatePlayers', (players) => {
displayPlayers(players);
});

socket.on('assignWord', (word) => {
alert('Dein Wort: ' + word);
});

socket.on('gameStarted', () => {
console.log('Spiel gestartet!');
});
