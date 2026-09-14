// server.js
const express = require("express");
const app = express();
app.use(express.json());

// userId -> lastSeen (ms)
const online = new Map();
const TTL = 60 * 1000; // 60s sin heartbeat = offline

function cleanup() {
  const now = Date.now();
  for (const [id, t] of online) {
    if (now - t > TTL) online.delete(id);
  }
}

function count() {
  cleanup();
  return online.size;
}

app.get("/", (req, res) => {
  res.send("Drip-client API is running!");
});

app.post("/heartbeat", (req, res) => {
  const id = String(
    req.body.userId ?? req.body.id ?? req.body.userid ?? "anon"
  );
  online.set(id, Date.now());
  res.json({ status: "ok", online: count() });
});

app.get("/online", (req, res) => {
  res.json({ status: "ok", online: count() });
});

app.get("/ping", (req, res) => {
  res.json({ status: "ok", online: count() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("API on", PORT));
