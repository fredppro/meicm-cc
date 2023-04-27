const express = require("express");
const Video = require("./models/video_model");
const app = express();
const bodyParser = require("body-parser");
var cors = require('cors');
app.use(cors());

app.use(bodyParser.json());

app.get("/", (req, res) => {
  res.json({ msg: "videos" });
});

app.get("/api/v1/videos", async (req, res) => {
  const videos = await Video.find({});
  res.json(videos);
});

app.post("/api/v1/videos", async (req, res) => {
  const video = new Video({ name: req.body.name });
  const savedVideo = await video.save();
  res.json(savedVideo);
});

app.delete("/api/v1/videos", async (req, res) => {
  await Video.deleteMany({});
});

module.exports = app;
