import { exec } from "child_process";
import { promises as fs } from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PLUGINS_DIR = path.join(__dirname, "../../plugins");

const executeScript = (scriptPath) => {
  return new Promise((resolve, reject) => {
    const ext = path.extname(scriptPath);
    let command;

    if (ext === ".py") {
      command = `python "${scriptPath}"`;
    } else if (ext === ".sh") {
      command = `bash "${scriptPath}"`;
    } else if (ext === ".js") {
      command = `node "${scriptPath}"`;
    } else {
      return resolve(null);
    }

    exec(command, { timeout: 10000 }, (error, stdout, stderr) => {
      if (error) {
        console.error(
          `Plugin error (${path.basename(scriptPath)}):`,
          error.message
        );
        return resolve({
          title: path.basename(scriptPath, ext),
          error: error.message,
          widgets: [],
        });
      }

      if (stderr) {
        console.warn(`Plugin stderr (${path.basename(scriptPath)}):`, stderr);
      }

      try {
        const result = JSON.parse(stdout);
        resolve(result);
      } catch (parseError) {
        console.error(
          `JSON parse error (${path.basename(scriptPath)}):`,
          parseError.message
        );
        resolve({
          title: path.basename(scriptPath, ext),
          error: "Invalid JSON output",
          widgets: [],
        });
      }
    });
  });
};

export const runPlugins = async () => {
  try {
    await fs.access(PLUGINS_DIR);
  } catch {
    console.warn("Plugins directory does not exist, creating it...");
    await fs.mkdir(PLUGINS_DIR, { recursive: true });
    return [];
  }

  const files = await fs.readdir(PLUGINS_DIR);
  const scriptFiles = files.filter((file) => {
    const ext = path.extname(file);
    return [".py", ".sh", ".js"].includes(ext);
  });

  if (scriptFiles.length === 0) {
    return [];
  }

  const pluginPromises = scriptFiles.map((file) => {
    const scriptPath = path.join(PLUGINS_DIR, file);
    return executeScript(scriptPath);
  });

  const results = await Promise.all(pluginPromises);
  return results.filter((result) => result !== null);
};
