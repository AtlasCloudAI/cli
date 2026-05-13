#!/usr/bin/env node
const crypto = require("crypto");
const fs = require("fs");
const https = require("https");
const path = require("path");
const { execFileSync } = require("child_process");

const pkg = require("./package.json");

const REPO = process.env.ATLAS_RELEASE_REPO || "AtlasCloudAI/cli";
const VERSION = process.env.ATLAS_CLI_VERSION || pkg.version;

const PLATFORM_MAP = {
  darwin: "darwin",
  linux: "linux"
};
const ARCH_MAP = {
  x64: "amd64",
  arm64: "arm64"
};

const platform = PLATFORM_MAP[process.platform];
const arch = ARCH_MAP[process.arch];

if (!platform || !arch) {
  console.error(
    `@atlascloud/cli: unsupported platform ${process.platform}/${process.arch}`
  );
  console.error("Supported: darwin|linux x x64|arm64");
  process.exit(1);
}

if (VERSION === "0.0.0") {
  console.error(
    "@atlascloud/cli: package version is 0.0.0; publish with the release tag version"
  );
  process.exit(1);
}

const tag = `v${VERSION}`;
const archiveName = `cli_${VERSION}_${platform}_${arch}.tar.gz`;
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
    if (redirects > 5) {
      reject(new Error("too many redirects"));
      return;
    }

    const file = fs.createWriteStream(dest);
    https
      .get(url, (res) => {
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          file.close(() => {
            fs.rmSync(dest, { force: true });
            download(res.headers.location, dest, redirects + 1)
              .then(resolve)
              .catch(reject);
          });
          return;
        }

        if (res.statusCode !== 200) {
          file.close(() => {
            fs.rmSync(dest, { force: true });
            reject(new Error(`HTTP ${res.statusCode} for ${url}`));
          });
          return;
        }

        res.pipe(file);
        file.on("finish", () => file.close(resolve));
      })
      .on("error", (err) => {
        file.close(() => {
          fs.rmSync(dest, { force: true });
          reject(err);
        });
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

(async () => {
  fs.mkdirSync(vendorDir, { recursive: true });

  console.log(`@atlascloud/cli: downloading ${archiveURL}`);
  await download(archiveURL, archivePath);
  await download(checksumsURL, checksumsPath);
  verifyChecksum();

  execFileSync("tar", ["-xzf", archivePath, "-C", vendorDir], {
    stdio: "inherit"
  });
  fs.chmodSync(path.join(vendorDir, "atlas"), 0o755);
  fs.chmodSync(path.join(vendorDir, "atlas-mcp"), 0o755);

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
  console.log("@atlascloud/cli: installed atlas and atlas-mcp");
})().catch((err) => {
  console.error("@atlascloud/cli: install failed:", err.message);
  process.exit(1);
});
