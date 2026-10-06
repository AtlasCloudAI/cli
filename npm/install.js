#!/usr/bin/env node
const crypto = require("crypto");
const fs = require("fs");
const https = require("https");
const path = require("path");
const { pipeline } = require("stream");
const { HttpsProxyAgent } = require("https-proxy-agent");
const { getProxyForUrl } = require("proxy-from-env");
const { execFileSync } = require("child_process");

const pkg = require("./package.json");

const REPO = process.env.ATLAS_RELEASE_REPO || "AtlasCloudAI/cli";
const VERSION = process.env.ATLAS_CLI_VERSION || pkg.version;

const PLATFORM_MAP = {
  darwin: "darwin",
  linux: "linux",
  win32: "windows"
};
const ARCH_MAP = {
  x64: "amd64",
  arm64: "arm64"
};

const platform = PLATFORM_MAP[process.platform];
const arch = ARCH_MAP[process.arch];

if (!platform || !arch) {
  console.error(
    `atlascloud-cli: unsupported platform ${process.platform}/${process.arch}`
  );
  console.error("Supported: darwin|linux|win32 x x64|arm64");
  process.exit(1);
}

if (VERSION === "0.0.0") {
  console.error(
    "atlascloud-cli: package version is 0.0.0; publish with the release tag version"
  );
  process.exit(1);
}

const tag = `v${VERSION}`;
const archiveExt = platform === "windows" ? "zip" : "tar.gz";
const archiveName = `cli_${VERSION}_${platform}_${arch}.${archiveExt}`;
const binaryName = platform === "windows" ? "atlas.exe" : "atlas";
const releaseBase = `https://github.com/${REPO}/releases/download/${tag}`;
const archiveURL = `${releaseBase}/${archiveName}`;
const checksumsURL = `${releaseBase}/checksums.txt`;

const vendorDir = path.join(__dirname, "vendor");
const archivePath = path.join(vendorDir, archiveName);
const checksumsPath = path.join(vendorDir, "checksums.txt");
const metadataPath = path.join(vendorDir, "install.json");

function detectPackageManager() {
  const ua = process.env.npm_config_user_agent || "";
  if (ua.startsWith("pnpm/")) return "pnpm";
  if (ua.startsWith("yarn/")) return "yarn";
  if (ua.startsWith("bun/")) return "bun";
  if (ua.startsWith("npm/")) return "npm";
  return "npm";
}

function download(url, dest, redirects = 0) {
  return new Promise((resolve, reject) => {
    if (redirects > 5) return reject(new Error("too many redirects"));
    const target = new URL(url);
    if (target.protocol !== "https:") return reject(new Error("release downloads require HTTPS"));
    const proxy = getProxyForUrl(url);
    const agent = proxy ? new HttpsProxyAgent(proxy) : undefined;
    let settled = false;
    let responseBody;
    const finish = (err) => {
      if (settled) return;
      settled = true;
      clearTimeout(deadline);
      if (agent) agent.destroy();
      if (err) {
        fs.rm(dest, { force: true }, () => reject(err));
      } else {
        resolve();
      }
    };
    const request = https.get(url, { agent }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        res.resume();
        settled = true;
        clearTimeout(deadline);
        if (agent) agent.destroy();
        download(new URL(res.headers.location, url).href, dest, redirects + 1).then(resolve, reject);
        return;
      }
      if (res.statusCode !== 200) {
        res.resume();
        finish(new Error(`HTTP ${res.statusCode} for ${target.hostname}`));
        return;
      }
      responseBody = res;
      pipeline(res, fs.createWriteStream(dest), finish);
    });
    const deadline = setTimeout(() => request.destroy(new Error("download exceeded 120s")), 120000);
    request.setTimeout(30000, () => request.destroy(new Error("download stalled for 30s")));
    request.on("error", (err) => {
      // The pipeline callback runs after the file handle closes. Windows
      // cannot remove an open output file, so defer cleanup to that callback.
      if (responseBody) responseBody.destroy(err);
      else finish(err);
    });
  });
}

function expectedChecksum(checksumsText, fileName) {
  const line = checksumsText
    .split(/\r?\n/)
    .find((entry) => entry.trim().split(/\s+/).slice(-1)[0] === fileName);

  if (!line) {
    throw new Error(`checksum for ${fileName} not found`);
  }
  return line.trim().split(/\s+/)[0];
}

function actualChecksum(filePath) {
  return crypto
    .createHash("sha256")
    .update(fs.readFileSync(filePath))
    .digest("hex");
}

function verifyChecksum() {
  const expected = expectedChecksum(fs.readFileSync(checksumsPath, "utf8"), archiveName);
  const actual = actualChecksum(archivePath);
  if (actual !== expected) {
    throw new Error(
      `checksum mismatch for ${archiveName}: expected ${expected}, got ${actual}`
    );
  }
}

function extractArchive() {
  if (platform === "windows") {
    execFileSync(
      "powershell.exe",
      [
        "-NoLogo",
        "-NoProfile",
        "-NonInteractive",
        "-ExecutionPolicy",
        "Bypass",
        "-Command",
        "Expand-Archive -LiteralPath $env:ATLAS_ARCHIVE -DestinationPath $env:ATLAS_VENDOR -Force"
      ],
      {
        stdio: "inherit",
        env: {
          ...process.env,
          ATLAS_ARCHIVE: archivePath,
          ATLAS_VENDOR: vendorDir
        }
      }
    );
    return;
  }

  execFileSync("tar", ["-xzf", archivePath, "-C", vendorDir], {
    stdio: "inherit"
  });
}

if (require.main === module) (async () => {
  fs.mkdirSync(vendorDir, { recursive: true });

  console.log(`atlascloud-cli: downloading ${archiveURL}`);
  await download(archiveURL, archivePath);
  await download(checksumsURL, checksumsPath);
  verifyChecksum();

  extractArchive();
  if (platform !== "windows") {
    fs.chmodSync(path.join(vendorDir, binaryName), 0o755);
  }

  fs.writeFileSync(
    metadataPath,
    JSON.stringify(
      {
        install_method: "npm",
        package_manager: detectPackageManager(),
        package_name: pkg.name,
        release_repo: REPO,
        version: VERSION
      },
      null,
      2
    ) + "\n"
  );
  fs.rmSync(archivePath, { force: true });
  fs.rmSync(checksumsPath, { force: true });
  console.log("atlascloud-cli: installed atlas");
})().catch((err) => {
  console.error("atlascloud-cli: install failed:", err.message);
  process.exit(1);
});

module.exports = { download };
