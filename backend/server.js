import "dotenv/config";
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import crypto from "crypto";
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

// Rate limiting to prevent brute force attacks
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW = 60000; // 1 minute
const MAX_ATTEMPTS = 20;

const rateLimitMiddleware = (req, res, next) => {
  const clientIp = req.ip || req.connection.remoteAddress;
  const now = Date.now();
  
  if (!rateLimitMap.has(clientIp)) {
    rateLimitMap.set(clientIp, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
    return next();
  }
  
  const record = rateLimitMap.get(clientIp);
  
  if (now > record.resetTime) {
    record.count = 1;
    record.resetTime = now + RATE_LIMIT_WINDOW;
    return next();
  }
  
  if (record.count >= MAX_ATTEMPTS) {
    return res.status(429).json({ error: "Too many requests" });
  }
  
  record.count++;
  next();
};

const authMiddleware = (req, res, next) => {
  const clientSecret = req.headers["x-agent-secret"];

  if (!clientSecret || typeof clientSecret !== 'string') {
    return res.status(401).json({ error: "Unauthorized" });
  }

  // Constant-time comparison to prevent timing attacks
  try {
    const clientBuffer = Buffer.from(clientSecret);
    const serverBuffer = Buffer.from(AGENT_SECRET);
    
    // Only compare if lengths match (constant-time length check)
    if (clientBuffer.length !== serverBuffer.length) {
      return res.status(401).json({ error: "Unauthorized" });
    }
    
    if (!crypto.timingSafeEqual(clientBuffer, serverBuffer)) {
      return res.status(401).json({ error: "Unauthorized" });
    }
  } catch (error) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  next();
};

app.get("/api/status", rateLimitMiddleware, authMiddleware, async (req, res) => {
  try {
    const pluginResults = await runPlugins();
    const { getMetricsHistory } = await import(
      "./src/services/metricsCollector.js"
    );
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
