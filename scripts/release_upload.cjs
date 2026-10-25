const fs = require('node:fs');
const crypto = require('node:crypto');
const { environment, adminHeaders } = require('./env.cjs');

async function uploadPlatform(platform) {
  const config = environment(), headers = adminHeaders(config);
  const version = fs.readFileSync('pubspec.yaml', 'utf8').match(/^version:\s*([^+\s]+)/m)[1];
  const bucket = await fetch(`${config.SUPABASE_URL}/storage/v1/bucket/releases`, { headers });
  if (bucket.status === 404 || bucket.status === 400) {
    const created = await fetch(`${config.SUPABASE_URL}/storage/v1/bucket`, {
      method: 'POST', headers: { ...headers, 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: 'releases', name: 'releases', public: true,
        file_size_limit: 50 * 1024 * 1024, allowed_mime_types: ['application/vnd.android.package-archive', 'application/x-msdownload', 'image/png'] }),
    });
    if (!created.ok) throw new Error(`Bucket creation failed (${created.status}).`);
  } else if (!bucket.ok) throw new Error(`Bucket lookup failed (${bucket.status}).`);
  const manifestPath = 'build/release-manifest.json';
  const manifest = fs.existsSync(manifestPath) ? JSON.parse(fs.readFileSync(manifestPath)) : {};
  manifest.version = version;
  async function upload(localPath, object, type) {
    const bytes = fs.readFileSync(localPath);
    const uploaded = await fetch(`${config.SUPABASE_URL}/storage/v1/object/releases/${object}`, {
      method: 'POST', headers: { ...headers, 'Content-Type': type, 'x-upsert': 'true' }, body: bytes,
    });
    if (!uploaded.ok) throw new Error(`Upload failed for ${object} (${uploaded.status}).`);
    console.log(`Uploaded ${object} (${bytes.length} bytes)`);
    return { url: `${config.SUPABASE_URL}/storage/v1/object/public/releases/${object}`,
      sha256: crypto.createHash('sha256').update(bytes).digest('hex') };
  }
  if (platform === 'android') {
    manifest.android = {};
    for (const abi of ['arm64-v8a', 'armeabi-v7a', 'x86_64']) {
      manifest.android[abi] = await upload(`build/app/outputs/flutter-apk/app-${abi}-release.apk`,
        `${version}/app-${abi}-release.apk`, 'application/vnd.android.package-archive');
    }
    for (const [source, target] of [['motogp-logo-centered.png','motogp-logo-v2.png'], ['acb-logo-centered.png','acb-logo-v2.png']]) {
      if (fs.existsSync(source)) await upload(source, target, 'image/png');
    }
  } else {
    manifest.windows = await upload('build/windows/installer/APEX_Media_Manager_Setup.exe',
      `${version}/APEX_Media_Manager_Setup.exe`, 'application/x-msdownload');
  }
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
}
module.exports = { uploadPlatform };
