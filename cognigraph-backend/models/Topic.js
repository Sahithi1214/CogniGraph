const mongoose = require('mongoose');

const topicSchema = new mongoose.Schema({
  topicName: { type: String, required: true, unique: true },
  progress: { type: Number, default: 0 },
  isCompleted: { type: Boolean, default: false }
});

module.exports = mongoose.model('Topic', topicSchema);
