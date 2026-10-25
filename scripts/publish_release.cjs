const fs = require('node:fs');
const { environment, adminHeaders } = require('./env.cjs');

(async () => {
  const config = environment(), manifest = JSON.parse(fs.readFileSync('build/release-manifest.json'));
  if (!manifest.windows || Object.keys(manifest.android || {}).length !== 3) throw new Error('Build and upload every platform before publishing metadata.');
  const urls = {}, hashes = {};
  for (const [abi, item] of Object.entries(manifest.android)) { urls[abi] = item.url; hashes[abi] = item.sha256; }
  const body = {
    latest_version: manifest.version,
    release_notes: 'Interfaz Liquid Glass unificada: navegación flotante, tarjetas translúcidas, filtros y diálogos de calidad compactos. Estética Apple TV conservando navegación con mando y carga diferida.',
    windows_exe_url: manifest.windows.url, windows_sha256: manifest.windows.sha256,
    apk_url: urls['arm64-v8a'], apk_sha256: hashes['arm64-v8a'], apk_urls: urls, apk_sha256s: hashes,
  };
  const response = await fetch(`${config.SUPABASE_URL}/rest/v1/app_settings?id=eq.1`, {
    method: 'PATCH', headers: { ...adminHeaders(config), 'Content-Type': 'application/json', Prefer: 'return=representation' },
    body: JSON.stringify(body),
  });
  if (!response.ok) throw new Error(`Publishing metadata failed (${response.status}).`);
  const rows = await response.json();
  if (rows.length !== 1 || rows[0].latest_version !== manifest.version) throw new Error('Release metadata did not persist.');
  console.log(`Published APEX ${manifest.version} with hashes for Windows and all three Android ABIs.`);
})().catch(error => { console.error(error.message); process.exitCode = 1; });
