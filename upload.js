const { uploadPlatform } = require('./scripts/release_upload.cjs');
uploadPlatform('android').catch(error => { console.error(error.message); process.exitCode = 1; });
