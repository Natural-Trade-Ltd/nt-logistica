// Portal de Logística — service worker (HTML siempre de red; las actualizaciones llegan solas)
const CACHE='lg-v3';
const SHELL=['./','index.html','manifest.webmanifest','icon.svg'];
self.addEventListener('install',e=>{ self.skipWaiting(); e.waitUntil(caches.open(CACHE).then(c=>c.addAll(SHELL)).catch(()=>{})); });
self.addEventListener('activate',e=>{ e.waitUntil((async()=>{ const ks=await caches.keys();
  await Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k))); await self.clients.claim(); })()); });
self.addEventListener('fetch',e=>{ const url=new URL(e.request.url);
  if(e.request.method!=='GET'||url.origin!==location.origin) return;   // Supabase / esm.sh -> red directa
  const isHTML=e.request.mode==='navigate'||url.pathname.endsWith('/')||url.pathname.endsWith('index.html');
  if(isHTML){ e.respondWith(fetch(new Request(url.href,{cache:'reload'}))
      .then(r=>{const cp=r.clone();caches.open(CACHE).then(c=>c.put('index.html',cp)).catch(()=>{});return r;})
      .catch(()=>caches.match('index.html'))); return; }
  e.respondWith(fetch(e.request).then(r=>{const cp=r.clone();caches.open(CACHE).then(c=>c.put(e.request,cp)).catch(()=>{});return r;}).catch(()=>caches.match(e.request)));
});
