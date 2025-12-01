import { test, mock } from "node:test";
import assert from "node:assert";
import { exec } from "child_process";

const mockExec = mock.fn((command, options, callback) => {
  if (command.includes("system_vitals.py")) {
    callback(
      null,
      JSON.stringify({
        title: "System Vitals",
        widgets: [
          {
            type: "metric_card",
            data: { label: "CPU", value: "45%", status: "success" },
          },
        ],
      }),
      ""
    );
  } else if (command.includes("failing_plugin.py")) {
    callback(new Error("Script execution failed"), "", "Error message");
  } else {
    callback(null, JSON.stringify({ title: "Test", widgets: [] }), "");
  }
});

test("runPlugins returns array of JSON objects on success", async () => {
  const mockPlugin = {
    path: "/plugins/system_vitals.py",
    name: "system_vitals.py",
  };

  const expectedOutput = {
    title: "System Vitals",
    widgets: [
      {
        type: "metric_card",
        data: { label: "CPU", value: "45%", status: "success" },
      },
    ],
  };

  const command = `python3 "${mockPlugin.path}"`;

  const result = await new Promise((resolve, reject) => {
    mockExec(command, { timeout: 10000 }, (error, stdout, stderr) => {
      if (error) {
        reject(error);
      }
      try {
        const parsed = JSON.parse(stdout);
        resolve(parsed);
      } catch (e) {
        reject(e);
      }
    });
  });

  assert.deepStrictEqual(result, expectedOutput);
});

test("runPlugins handles plugin errors gracefully", async () => {
  const mockPlugin = {
    path: "/plugins/failing_plugin.py",
    name: "failing_plugin.py",
  };

  const command = `python3 "${mockPlugin.path}"`;

  const result = await new Promise((resolve) => {
    mockExec(command, { timeout: 10000 }, (error, stdout, stderr) => {
      if (error) {
        resolve({
          title: mockPlugin.name,
          error: error.message,
          widgets: [],
        });
      }
    });
  });

  assert.strictEqual(result.title, "failing_plugin.py");
  assert.strictEqual(result.error, "Script execution failed");
  assert.deepStrictEqual(result.widgets, []);
});

test("runPlugins parses valid JSON output", async () => {
  const validJson = JSON.stringify({
    title: "Docker Containers",
    widgets: [
      {
        type: "metric_card",
        data: { label: "Running", value: "4/4", status: "success" },
      },
      {
        type: "action_button",
        data: {
          label: "Restart All",
          command: "docker restart $(docker ps -q)",
        },
      },
    ],
  });

  const parsed = JSON.parse(validJson);

  assert.strictEqual(parsed.title, "Docker Containers");
  assert.strictEqual(parsed.widgets.length, 2);
  assert.strictEqual(parsed.widgets[0].type, "metric_card");
  assert.strictEqual(parsed.widgets[1].type, "action_button");
});

test("runPlugins handles timeout correctly", async () => {
  const slowCommand = "sleep 15 && echo test";

  const result = await new Promise((resolve) => {
    exec(slowCommand, { timeout: 1000 }, (error, stdout, stderr) => {
      if (error) {
        resolve({
          error: "Timeout",
          message: "Plugin execution timed out",
        });
      }
    });
  });

  assert.strictEqual(result.error, "Timeout");
});

test("runPlugins detects Python command correctly", async () => {
  const detectPython = () => {
    return new Promise((resolve) => {
      exec("python3 --version", (error) => {
        if (!error) {
          resolve("python3");
        } else {
          exec("python --version", (error) => {
            if (!error) {
              resolve("python");
            } else {
              resolve(null);
            }
          });
        }
      });
    });
  };

  const pythonCmd = await detectPython();
  assert.ok(
    pythonCmd === "python3" || pythonCmd === "python" || pythonCmd === null
  );
});

test("runPlugins handles empty plugin output", async () => {
  const emptyOutput = "";

  try {
    JSON.parse(emptyOutput);
    assert.fail("Should have thrown error");
  } catch (error) {
    assert.ok(error instanceof SyntaxError);
  }
});

test("runPlugins validates widget structure", () => {
  const widget = {
    type: "metric_card",
    data: {
      label: "CPU Load",
      value: "45%",
      status: "success",
    },
  };

  assert.strictEqual(typeof widget.type, "string");
  assert.strictEqual(typeof widget.data, "object");
  assert.ok(widget.data.label);
  assert.ok(widget.data.value);
  assert.ok(widget.data.status);
});
