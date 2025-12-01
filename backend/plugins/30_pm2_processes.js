#!/usr/bin/env node
import { execSync } from "child_process";

try {
  const output = execSync("pm2 jlist", { encoding: "utf-8" });
  const processes = JSON.parse(output);

  const onlineProcesses = processes.filter(
    (p) => p.pm2_env.status === "online"
  ).length;
  const totalProcesses = processes.length;

  const totalRestarts = processes.reduce(
    (sum, p) => sum + (p.pm2_env.restart_time || 0),
    0
  );

  let status = "success";
  if (onlineProcesses === 0 && totalProcesses > 0) {
    status = "error";
  } else if (onlineProcesses < totalProcesses) {
    status = "warning";
  }

  let restartStatus = "success";
  if (totalRestarts > 100) {
    restartStatus = "warning";
  }
  if (totalRestarts > 500) {
    restartStatus = "error";
  }

  const result = {
    title: "PM2 Processes",
    widgets: [
      {
        type: "metric_card",
        data: {
          label: "Node.js Apps",
          value: `${onlineProcesses} Online`,
          status: status,
        },
      },
      {
        type: "metric_card",
        data: {
          label: "App Restarts",
          value: totalRestarts.toString(),
          status: restartStatus,
        },
      },
      {
        type: "action_button",
        data: {
          label: "PM2 Reload All",
          command:
            "bash -l -c 'pm2 reload all'",
        },
      },
    ],
  };

  console.log(JSON.stringify(result));
} catch (error) {
  const errorResult = {
    title: "PM2 Processes",
    error: error.message.includes("pm2: not found")
      ? "PM2 not installed"
      : error.message,
    widgets: [],
  };
  console.log(JSON.stringify(errorResult));
}
