const fs = require('node:fs');

function environment() {
  const config = { ...process.env };
  if (fs.existsSync('.env.local')) {
    for (const line of fs.readFileSync('.env.local', 'utf8').split(/\r?\n/)) {
      const split = line.indexOf('=');
      if (split > 0 && !config[line.slice(0, split)]) config[line.slice(0, split)] = line.slice(split + 1);
    }
  }
  return config;
}
function adminHeaders(config) {
  if (!config.SUPABASE_URL || !config.SUPABASE_SECRET_KEY) throw new Error('Set SUPABASE_URL and SUPABASE_SECRET_KEY in .env.local.');
  return { apikey: config.SUPABASE_SECRET_KEY, Authorization: `Bearer ${config.SUPABASE_SECRET_KEY}` };
}
module.exports = { environment, adminHeaders };
