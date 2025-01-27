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

const getNextId = () => {
  if (TestEntities.length === 0) return 1;
  const maxId = Math.max(...TestEntities.map(entity => entity.id));
  return maxId + 1;
};

app.post('/entities', (req, res) => {
   const { name } = req.body;

   // Validation
   if (!name) {
     return res.status(400).json({ message: 'Name is required' });
   }

   // Generate new ID automatically
   const newId = getNextId();

   // Create new entity
   const newEntity = {
     id: newId,
     name: name
   };

   // Add to array
   TestEntities.push(newEntity);

   // Broadcast the new entity to all connected clients
   broadcast({ type: 'entityAdded', entity: newEntity });

   // Return success response
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
