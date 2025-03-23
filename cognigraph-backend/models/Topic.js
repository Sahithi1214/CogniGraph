const mongoose = require('mongoose');

const topicSchema = new mongoose.Schema({
  topicName: { type: String, required: true, unique: true },
  progress: { type: Number, default: 0 },
  isCompleted: { type: Boolean, default: false },
  relatedTopics: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Topic' }] 
});

module.exports = mongoose.model('Topic', topicSchema);
