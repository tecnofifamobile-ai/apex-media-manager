const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient('https://amyownwbukcoiuldhozx.supabase.co', 'sb_publishable_G0A4-he7nul_Lg6AJ-kbIw_Iyv8V6v4');

async function upload() {
  console.log('Starting upload of ARM64 APK...');
  const fileBuffer = fs.readFileSync('build/app/outputs/flutter-apk/app-arm64-v8a-release.apk');
  
  const { data, error } = await supabase
    .storage
    .from('releases')
    .upload('app-release.apk', fileBuffer, {
      upsert: true,
      contentType: 'application/vnd.android.package-archive'
    });

  if (error) {
    console.error('Upload failed:', error);
  } else {
    console.log('Upload successful:', data);
  }
}

upload();
