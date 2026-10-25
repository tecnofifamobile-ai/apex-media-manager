const { uploadPlatform } = require('./scripts/release_upload.cjs');
uploadPlatform('windows').catch(error => { console.error(error.message); process.exitCode = 1; });
