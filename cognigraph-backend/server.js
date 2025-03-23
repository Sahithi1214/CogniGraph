const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();
const language = require('@google-cloud/language');

const app = express();
const port = 3000;

const client = new language.LanguageServiceClient();

app.use(cors());
app.use(bodyParser.json());
app.use(express.json());
// Connect to MongoDB Atlas
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected successfully'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Import routes
const topicsRoutes = require('./routes/topics');
app.use('/api/topics', topicsRoutes);

// Default route
app.get('/', (req, res) => {
  res.send('Welcome to CogniGraph Backend API 🚀');
});

// Start server
app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});

app.post('/api/parse-content', async (req, res) => {
    try {
        const { text } = req.body;
        if (!text) {
            return res.status(400).json({ error: 'Text content is required' });
        }

        // Prepare request for NLP API
        const document = {
            content: text,
            type: 'PLAIN_TEXT',
        };

        // Analyze entities (extract topics)
        const [result] = await client.analyzeEntities({ document });
        const topics = result.entities
            .filter(entity => entity.salience > 0.01) // Filter out less relevant entities
            .map(entity => entity.name);

        res.json({ topics });
    } catch (error) {
        console.error('Error parsing content:', error);
        res.status(500).json({ error: 'Failed to analyze text' });
    }
});
