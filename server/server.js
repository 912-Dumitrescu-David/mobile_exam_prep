const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// In-memory list to store entities
let TestEntities = [];

// Middleware to parse JSON requests
app.use(bodyParser.json());

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
    return res.status(400).json({  });
  }

  // Check for duplicate id
  if (TestEntities.some((TestEntity) => TestEntity.id === id)) {
    return res.status(409).json({  });
  }

  // Add to the list
  TestEntities.push({ id, name });
  res.status(201).json({ id, name  });
});

// PUT: Update an entity by id
app.put('/entities/:id', (req, res) => {
  const id = req.params.id;
  const { name } = req.body;

  // Validation
  if (!name) {
    return res.status(400).json({  });
  }

  // Find the entity
  const TestEntity = TestEntities.find((TestEntity) => TestEntity.id === id);
  if (!TestEntity) {
    return res.status(404).json({  });
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
    return res.status(404).json({message: "balls"  });
  }

  // Remove from the list
  TestEntities.splice(index, 1);
  res.status(200).json({  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
