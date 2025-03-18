const express = require('express');
const router = express.Router();
const Topic = require('../models/Topic'); // Import Topic model

// Fetch all topics
router.get('/', async (req, res) => {
  try {
    const topics = await Topic.find();
    res.json(topics);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add a new topic
router.post('/', async (req, res) => {
  const { topicName } = req.body;
  try {
    const newTopic = new Topic({ topicName });
    await newTopic.save();
    res.status(201).json(newTopic);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update topic progress
router.put('/:topicName', async (req, res) => {
  const { topicName } = req.params;
  const { progress, isCompleted } = req.body;
  try {
    const updatedTopic = await Topic.findOneAndUpdate(
      { topicName },
      { progress, isCompleted },
      { new: true }
    );
    if (updatedTopic) {
      res.json(updatedTopic);
    } else {
      res.status(404).send('Topic not found');
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete a topic (NEW)
router.delete('/:topicName', async (req, res) => {
  const { topicName } = req.params;
  try {
    const deletedTopic = await Topic.findOneAndDelete({ topicName });
    if (deletedTopic) {
      res.json({ message: 'Topic deleted successfully' });
    } else {
      res.status(404).send('Topic not found');
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
