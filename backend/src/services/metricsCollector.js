import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

const MAX_HISTORY = 60;
const metricsHistory = {
  cpu: [],
  memory: [],
  timestamps: [],
};

async function collectCurrentMetrics() {
  try {
    const { stdout } = await execAsync(
      "python3 -c \"import psutil; import json; print(json.dumps({'cpu': psutil.cpu_percent(interval=0.5), 'memory': psutil.virtual_memory().percent}))\""
    );
    const metrics = JSON.parse(stdout.trim());

    const timestamp = Date.now();

    metricsHistory.cpu.push(metrics.cpu);
    metricsHistory.memory.push(metrics.memory);
    metricsHistory.timestamps.push(timestamp);

    if (metricsHistory.cpu.length > MAX_HISTORY) {
      metricsHistory.cpu.shift();
      metricsHistory.memory.shift();
      metricsHistory.timestamps.shift();
    }
  } catch (error) {
    console.error("Failed to collect metrics:", error.message);
  }
}

export function collectMetrics() {
  collectCurrentMetrics();
  setInterval(collectCurrentMetrics, 1000);
  console.log("Metrics collection started (1 second interval)");
}

export function getMetricsHistory() {
  return {
    cpu: [...metricsHistory.cpu],
    memory: [...metricsHistory.memory],
    timestamps: [...metricsHistory.timestamps],
  };
}
