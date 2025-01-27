const express = require('express');
const bodyParser = require('body-parser');
const http = require('http');
// const { Server } = require('socket.io');
const WebSocket = require('ws');

const app = express();
const port = 3000;

// In-memory list to store entities
let TestEntities = [
    { id: 1, name: 'Entity 1' },
    { id: 2, name: 'Entity 2' },
    { id: 3, name: 'Entity 3' }];

// Middleware to parse JSON requests
app.use(bodyParser.json());

// Create HTTP server and WebSocket server
const server = http.createServer(app);
// const io = new Server(server);

// // WebSocket connection handler
// io.on('connection', (socket) => {
//   console.log('A user connected');

//   socket.on('disconnect', () => {
//     console.log('A user disconnected');
//   });
// });

const wss = new WebSocket.Server({ server });
const broadcast = (data) =>
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });


// Routes

// GET: Fetch all entities
app.get('/entities', (req, res) => {
  res.status(200).json(TestEntities);
});

// POST: Add a new entity
app.post('/entities', (req, res) => {
  const { id, name } = req.body;

  // Validation
  if (!id || !name) {
    return res.status(400).json({ message: 'ID and name are required' });
  }

  // Check for duplicate id
  if (TestEntities.some((TestEntity) => TestEntity.id === id)) {
    return res.status(409).json({ message: 'Entity with this ID already exists' });
  }

  // Add to the list
  const newEntity = { id, name };
  TestEntities.push(newEntity);

  // Notify connected users
  // io.emit('entityAdded', newEntity);
  broadcast('add')

  res.status(201).json(newEntity);
});

// PUT: Update an entity by id
app.put('/entities/:id', (req, res) => {
  const id = req.params.id;
  const { name } = req.body;

  // Validation
  if (!name) {
    return res.status(400).json({ message: 'Name is required' });
  }

  // Find the entity
  const TestEntity = TestEntities.find((TestEntity) => TestEntity.id == id);
  if (!TestEntity) {
    return res.status(404).json({ message: 'Entity not found' });
  }

  // Update the name
  TestEntity.name = name;
  res.status(200).json({ TestEntity });
});

// DELETE: Delete an entity by id
app.delete('/entities/:id', (req, res) => {
  const id = req.params.id;

  // Find the index of the entity
  const index = TestEntities.findIndex((TestEntity) => TestEntity.id == id);
  if (index === -1) {
    return res.status(404).json({ message: 'Entity not found' });
  }

  // Remove from the list
  TestEntities.splice(index, 1);
  res.status(200).json({ message: 'Entity deleted' });
});

// Start the server
server.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
  broadcast('UwU');
});
