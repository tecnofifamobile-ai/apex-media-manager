const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient('https://amyownwbukcoiuldhozx.supabase.co', 'sb_publishable_G0A4-he7nul_Lg6AJ-kbIw_Iyv8V6v4');

async function upload() {
  console.log('Starting upload of Windows Setup...');
  const fileBuffer = fs.readFileSync('build/windows/installer/APEX_Media_Manager_Setup.exe');
  
  const { data, error } = await supabase
    .storage
    .from('releases')
    .upload('APEX_Media_Manager_Setup.exe', fileBuffer, {
      upsert: true,
      contentType: 'application/x-msdownload'
    });

  if (error) {
    console.error('Upload failed:', error);
  } else {
    console.log('Upload successful:', data);
  }
}

upload();
