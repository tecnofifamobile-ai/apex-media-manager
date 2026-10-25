// Local-only IPTV fixture for device testing. No provider credentials required.
const http = require('node:http');
const { Readable } = require('node:stream');
const sample = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
let screen = 'channels';
http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://127.0.0.1:8765');
  if (url.pathname === '/qa-command') {
    if (url.searchParams.has('screen')) screen = url.searchParams.get('screen');
    res.setHeader('Content-Type', 'application/json'); res.end(JSON.stringify({ screen }));
  } else if (url.pathname === '/playlist.m3u') {
    res.setHeader('Content-Type', 'audio/x-mpegurl');
    res.end('#EXTM3U\n' + Array.from({ length: 10000 }, (_, i) =>
      `#EXTINF:-1 group-title="Pruebas",Demo ${i}\nhttp://127.0.0.1:8765/live/u/p/${i}.ts\n`).join(''));
  } else if (url.pathname === '/player_api.php') {
    const actions = {
      get_live_categories: [{ category_id: '1', category_name: 'Pruebas' }],
      get_live_streams: [{ stream_id: 1, name: 'Demo TV', category_id: '1' }],
      get_vod_streams: [{ stream_id: 2, name: 'Demo Movie', container_extension: 'mp4' }],
      get_series: [{ series_id: 3, name: 'Demo Series' }],
      get_series_info: { episodes: { '1': [{ id: 4, title: 'Demo Episode', container_extension: 'mp4' }] } },
    };
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(actions[url.searchParams.get('action')] ?? {}));
  } else if (/^\/(live|movie|series)\//.test(url.pathname)) {
    try {
      const upstream = await fetch(sample, { headers: req.headers.range ? { Range: req.headers.range } : {} });
      res.writeHead(upstream.status, Object.fromEntries([...upstream.headers].filter(([key]) =>
        ['content-type', 'content-length', 'content-range', 'accept-ranges'].includes(key))));
      if (req.method === 'HEAD') { res.end(); return; }
      const stream = Readable.fromWeb(upstream.body);
      res.on('close', () => stream.destroy());
      stream.pipe(res);
    } catch { res.writeHead(502); res.end(); }
  } else { res.writeHead(404); res.end(); }
}).listen(8765, '127.0.0.1', () => console.log('Local IPTV fixture listening on 127.0.0.1:8765; use adb reverse tcp:8765 tcp:8765.'));
