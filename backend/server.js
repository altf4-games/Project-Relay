import "dotenv/config";
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { runPlugins } from "./src/services/pluginRunner.js";
import { collectMetrics } from "./src/services/metricsCollector.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const AGENT_SECRET = process.env.AGENT_SECRET;

if (!AGENT_SECRET) {
  console.error("ERROR: AGENT_SECRET environment variable is required");
  process.exit(1);
}

collectMetrics();

app.use(express.json());

const authMiddleware = (req, res, next) => {
  const clientSecret = req.headers["x-agent-secret"];

  if (!clientSecret || clientSecret !== AGENT_SECRET) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  next();
};

app.get("/api/status", authMiddleware, async (req, res) => {
  try {
    const pluginResults = await runPlugins();
    const { getMetricsHistory } = await import("./src/services/metricsCollector.js");
    const history = getMetricsHistory();
    
    res.json({
      status: "alive",
      data: pluginResults,
      history: history,
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      error: error.message,
    });
  }
});

app.listen(PORT, "127.0.0.1", () => {
  console.log(`Relay Agent listening on port ${PORT}`);
});
