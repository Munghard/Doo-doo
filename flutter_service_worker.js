'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "182fbce5329f7569262ee51ed19b75dc",
".git/config": "8a60cd09212227366d47576cdb69070b",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "9eb04ef576379198859fe24283f51c87",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "8deb4dc9537d3bb52c206888560cd1ad",
".git/logs/refs/heads/gh-pages": "8deb4dc9537d3bb52c206888560cd1ad",
".git/logs/refs/remotes/origin/gh-pages": "5c66001e2df3d6650c59244b5b72ed5a",
".git/objects/0a/dbb036732a7e40fd538e3ab41688b965faeb65": "c051cb3bf25f965db1708b79d05ce751",
".git/objects/11/6b326b4507147c536b362014be30370263622b": "7d7b8e9d9816a8c07d8bcd8f556e2aba",
".git/objects/19/5cf3f8f8b8165044ce57e31a571d03d2965d7b": "7eb96debb16e37dea29aeb87e77908ef",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/1b/a3e7c01283eb9b6fff39ee2f0ea04851916a74": "42504a7bae802bd0bb5de23f52fcfd15",
".git/objects/1b/f3ac6288fdd830beadf4f52064231ee98f4274": "a743ba8e5c4f9777dd7f234efb1c56bf",
".git/objects/1d/7ec556cf1fb15040234e8cd5f6a7b2c4905126": "a596a4ee2ea20cfdee35133a72229419",
".git/objects/21/7e19b7998cd68a818b045eb76e1ad428ab60cd": "6d40ff4a1a1883e1d8824b2826247b7e",
".git/objects/23/3448dcd45b2a7971d492e1219e410bf26451a4": "136d2ab2cdf1605bfaae795eb5933059",
".git/objects/34/ea78864af647c388145c4c76203cb1e15cd661": "03044db43ebbe9be583a57bd7a10b59a",
".git/objects/3d/234bcefd9520f45bdcdf0e25c22b2357dee325": "50ddbbf4b5706ffb094bbcbd27bb9df9",
".git/objects/3d/647a1ab454cbd28204933a27ce37535d96d059": "0ae2b720988efbe3d742b00fbded3840",
".git/objects/3e/d14c6d63daeea8f637bc8fb3fab96cbd5af061": "909f3c11bdf5c65206f7bc8e8f7b9111",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4c/51fb2d35630595c50f37c2bf5e1ceaf14c1a1e": "a20985c22880b353a0e347c2c6382997",
".git/objects/52/1ba170e9502a07fc65c66ea31fa9a114cf4979": "93f386e6af3a3dbeb8ac1ca66ae3dac1",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/59/92f1c4ce9782eae4377eaab69c8acfecff83c9": "7baafed477a481692b7b625831804bc6",
".git/objects/5d/6b4fcff7857f3f40410f99b1204099d3f7bb38": "b6923df603cf26cc3143e883f98457e7",
".git/objects/5f/7c3163fed0119297185144ae8a990846ef1ddb": "e2197ece194eedbb84923b77b6482ca9",
".git/objects/64/c7166ec35479e439b0a610e1840e3123f4e501": "3f1647a1ac27351dcd059cc0f3a395fb",
".git/objects/65/09685776669f2e0411ef64b6792d97bfc94433": "608d112cc399e3b0b395985844ddae27",
".git/objects/65/09ec34ddd5a1e42ee84663583a56a4060390a0": "b867847cd1db6b1a999ce66f14583c6d",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/76/447e0304d29d3a824243d6f4b203d5157d36ec": "c1d349a3b202b2b34cd54f53b5003da0",
".git/objects/7c/e44d67e0650a44ff5be8af7939e45e0ddfe5bb": "273ea3869801267dea5ae3fa24cff576",
".git/objects/7d/53d2807105fb4b01e7e2d4f8d235c101836a31": "0457b15c88ed9f643efc619b2f53afa5",
".git/objects/84/8b86681e50eee7bcbf732882f567f07578e3fb": "1f99c38647322b845044dd74172ea6b8",
".git/objects/87/b6dc525151ca9dd30a9e0bfa6f8699632d6eb5": "aef44ba72b14be4580a4b28eb03f1140",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8e/3c7d6bbbef6e7cefcdd4df877e7ed0ee4af46e": "025a3d8b84f839de674cd3567fdb7b1b",
".git/objects/94/befce1c79b379803584e829063b86f215eb532": "98777d524629b7d5f45ded2701410a4d",
".git/objects/96/2ae1ba6c946c224caa8ce58ce3b51e9f21c19d": "31982c878f5049a4b93f6338224b2200",
".git/objects/98/3dd18a1528d3b057674e520f6132b32167d080": "dd57ac3668758a37609360191bf5f281",
".git/objects/9b/8ed71663c5387d7ec23f38ac3aed9117f19f4c": "d6bb3f6b189936bdf1238986704db5c9",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/9d/2770f30b1e8b8912bcc5ed35602967c6b4e529": "1d446f2697407aceba864d9c15e9bb42",
".git/objects/9f/4d6bc555326b054f20f828e2b32545f3c837d8": "58617c7df51ba87a6537f36f8b90322a",
".git/objects/a2/6abe7e7b89a7f0bd8866b682b5ad23390e3317": "5c3203a948781264d4578ae0a338f52a",
".git/objects/a4/2c2ec1aa1d684770777de7a60f29f4c1fcdd78": "c650481a8a5267ecd57a94869047eba0",
".git/objects/a5/e03873ea65a19200c5978137f052c9460947e8": "7f449947f9ae3822d7684fd886cb2d52",
".git/objects/ae/bed6be55ea5fa4e9b888efca3f5bfc643f939f": "711b9391103eecca976343edb03a6c70",
".git/objects/b4/0263e9c62a9a5c9c060a3b4f0a18d7113bb31b": "5b2720848d818e05feb2210360734075",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/cd/4bb744d7c0d038689f195312dd973cab7288c0": "60b67ade7b8e0f00f845d13ef79cc94a",
".git/objects/d2/ad7a36bd271c84b6ad36af59126b2af23cf68b": "fea0e13269140340590a81d95826221e",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/df/03de0b8bb542379536897a62771e9b8d274348": "30d9c11839ab6a86f564e1b823f3137e",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/ea/b6e607518eef59724cbb4bd54a753a62b1ff69": "072c8c69a1977216b0bc0fced16c8d52",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ef/dce6320217ec52951abceef91e4f6ddc89a174": "d4020ab44f483d3d0d12683505bba75c",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/fa/585244252a0ea528febbc3f771f985c0e23717": "6424527d778bfaddb3125738aed7cfa3",
".git/objects/fb/7d97ac358671ae6f3646357aca1ba36bcf61cc": "840ff1c61e25c708352288bf61c35992",
".git/objects/fe/c4b934fc27a0244c7edde51db91a065b421546": "9ed7ac8624519bfa3499d5ddbfbd691c",
".git/refs/heads/gh-pages": "f0fafd3ef05143e27972433b6e5188c8",
".git/refs/remotes/origin/gh-pages": "f0fafd3ef05143e27972433b6e5188c8",
"assets/AssetManifest.bin": "cf712bf23e0bb7bc0e08c81b88acdf14",
"assets/AssetManifest.bin.json": "9866f4c1dd9e314e78b8a5b6b0e00bf7",
"assets/AssetManifest.json": "549aebd1fc96c006bf9ea7587da00375",
"assets/assets/images/default-user.jpg": "a4bea315a6795e0008177dff17c8d86b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "bcfed7db8cb3c43b4ed4fada6bb2c3f2",
"assets/NOTICES": "e530244d2eee1080bd742813cd820ae2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "d2fcbfcee65cb54ffc82e2ea62d684af",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "4552c2fc6257c0003e81f222f5f496d3",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "9191775a51a96fde3e543955ccb7c98e",
"/": "9191775a51a96fde3e543955ccb7c98e",
"main.dart.js": "19907b66b22e0aba914df4c19d2b55d0",
"manifest.json": "18579c97ff06b493eed216d7209c475d",
"version.json": "342be48f7474339d07cdd993267a2caa"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
