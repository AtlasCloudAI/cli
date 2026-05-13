const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

function detectPackageManager() {
  const ua = process.env.npm_config_user_agent || "";
  if (ua.startsWith("pnpm/")) return "pnpm";
  if (ua.startsWith("yarn/")) return "yarn";
  if (ua.startsWith("bun/")) return "bun";
  if (ua.startsWith("npm/")) return "npm";
  return "";
}

function readInstallMetadata(vendorDir) {
  const metadataPath = path.join(vendorDir, "install.json");
  if (!fs.existsSync(metadataPath)) {
    return {};
  }
  return JSON.parse(fs.readFileSync(metadataPath, "utf8"));
}

module.exports = function run(binaryName) {
  const vendorDir = path.join(__dirname, "..", "vendor");
  const bin = path.join(vendorDir, binaryName);

  if (!fs.existsSync(bin)) {
    console.error(
      `@atlascloud/cli: binary not found at ${bin}. Reinstall: npm i -g @atlascloud/cli`
    );
    process.exit(1);
  }

  const metadata = readInstallMetadata(vendorDir);
  const child = spawn(bin, process.argv.slice(2), {
    stdio: "inherit",
    env: {
      ...process.env,
      ATLAS_INSTALL_METHOD: "npm",
      ATLAS_PACKAGE_MANAGER:
        metadata.package_manager || detectPackageManager() || "npm"
    }
  });

  child.on("exit", (code, signal) => {
    if (signal) {
      process.kill(process.pid, signal);
      return;
    }
    process.exit(code == null ? 0 : code);
  });

  child.on("error", (err) => {
    console.error("@atlascloud/cli: failed to exec:", err.message);
    process.exit(1);
  });
};
