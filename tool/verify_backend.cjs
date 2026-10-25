const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const { environment, adminHeaders } = require('../scripts/env.cjs');

(async () => {
  const config = environment(), admin = adminHeaders(config), users = [];
  async function request(path, method = 'GET', body, token) {
    const headers = token ? { apikey: config.SUPABASE_PUBLISHABLE_KEY, Authorization: `Bearer ${token}` } : admin;
    const response = await fetch(config.SUPABASE_URL + path, {
      method, headers: { ...headers, 'Content-Type': 'application/json', Prefer: 'return=representation' },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const text = await response.text();
    return { status: response.status, body: text ? JSON.parse(text) : null };
  }
  try {
    for (let i = 0; i < 2; i++) {
      const email = `apex-verification-${crypto.randomUUID()}@example.invalid`;
      const password = crypto.randomBytes(24).toString('base64url');
      const created = await request('/auth/v1/admin/users', 'POST', { email, password, email_confirm: true });
      assert.equal(created.status, 200, 'test account creation');
      users.push({ id: created.body.id });
      const signed = await request('/auth/v1/token?grant_type=password', 'POST', { email, password });
      assert.equal(signed.status, 200, 'test account login');
      users.at(-1).token = signed.body.access_token;
    }
    const [owner, stranger] = users;
    const inserted = await request('/rest/v1/profiles', 'POST', {
      user_id: owner.id, name: 'Verification only', type: 'm3u',
      m3u_url: 'https://example.invalid/list.m3u', epg_url: 'https://example.invalid/guide.xml', color_code: 4284110808,
    }, owner.token);
    assert.equal(inserted.status, 201, 'owner inserts own profile');
    const row = inserted.body[0];
    const own = await request(`/rest/v1/profiles?id=eq.${row.id}`, 'GET', undefined, owner.token);
    assert.equal(own.body.length, 1, 'owner reads own profile');
    const other = await request(`/rest/v1/profiles?id=eq.${row.id}`, 'GET', undefined, stranger.token);
    assert.deepEqual(other.body, [], 'another account cannot read the profile');
    const reassigned = await request(`/rest/v1/profiles?id=eq.${row.id}`, 'PATCH', { user_id: stranger.id }, owner.token);
    assert.ok([401, 403].includes(reassigned.status), 'owner cannot reassign profile to another account');
    const anonymous = await fetch(`${config.SUPABASE_URL}/rest/v1/profiles`, { headers: { apikey: config.SUPABASE_PUBLISHABLE_KEY } });
    assert.ok([401, 403].includes(anonymous.status), 'anonymous users cannot read profiles');
    const settings = await fetch(`${config.SUPABASE_URL}/rest/v1/app_settings?select=id`, { headers: { apikey: config.SUPABASE_PUBLISHABLE_KEY } });
    assert.equal(settings.status, 200, 'anonymous clients can read update metadata');
    console.log('PASS: authentication, own-profile insert/read, cross-account isolation, ownership immutability, anonymous restrictions and update metadata.');
  } finally {
    for (const user of users) {
      const deleted = await request(`/auth/v1/admin/users/${user.id}`, 'DELETE');
      assert.equal(deleted.status, 200, 'temporary test account cleanup');
    }
    console.log('Temporary verification accounts removed.');
  }
})().catch(error => { console.error(error.message); process.exitCode = 1; });
