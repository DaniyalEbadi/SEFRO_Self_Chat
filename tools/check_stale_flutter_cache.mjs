import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const repoRoot = process.cwd();
const chromeUserDataRoot =
  process.env.LOCALAPPDATA &&
  path.join(process.env.LOCALAPPDATA, 'Google', 'Chrome', 'User Data');

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function findActiveProfile(userDataRoot) {
  const localStatePath = path.join(userDataRoot, 'Local State');
  const localState = readJson(localStatePath);
  const profile = localState.profile ?? {};
  return (
    profile.last_used ||
    profile.last_active_profiles?.[0] ||
    'Default'
  );
}

function runSearch(pattern, targetPath) {
  const result = spawnSync(
    'rg',
    ['-a', '-n', '-m', '20', pattern, targetPath],
    { encoding: 'utf8' },
  );

  return {
    status: result.status ?? 1,
    stdout: result.stdout.trim(),
    stderr: result.stderr.trim(),
  };
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

try {
  assert(chromeUserDataRoot && fs.existsSync(chromeUserDataRoot), 'Chrome user data root not found.');

  const activeProfile = findActiveProfile(chromeUserDataRoot);
  const cacheStorageRoot = path.join(
    chromeUserDataRoot,
    activeProfile,
    'Service Worker',
    'CacheStorage',
  );
  const buildIndex = fs.readFileSync(path.join(repoRoot, 'build', 'web', 'index.html'), 'utf8');
  const sourceIndex = fs.readFileSync(path.join(repoRoot, 'web', 'index.html'), 'utf8');

  assert(
    buildIndex.includes('flutter_bootstrap.js?nocache=1'),
    'build/web/index.html is not using the cache-busting bootstrap URL.',
  );
  assert(
    sourceIndex.includes('flutter_bootstrap.js?nocache=1'),
    'web/index.html is not using the cache-busting bootstrap URL.',
  );
  assert(fs.existsSync(cacheStorageRoot), `CacheStorage folder not found for profile ${activeProfile}.`);

  const staleIndex = runSearch('<script src="flutter_bootstrap.js" async></script>', cacheStorageRoot);
  const cachedBootstrap = runSearch('flutter_service_worker.js?v=', cacheStorageRoot);
  const cachedOrigin = runSearch('http://localhost:8000/', cacheStorageRoot);

  const hasStaleIndex = staleIndex.status === 0 && staleIndex.stdout.length > 0;
  const hasCachedBootstrap = cachedBootstrap.status === 0 && cachedBootstrap.stdout.length > 0;
  const hasLocalhostCache = cachedOrigin.status === 0 && cachedOrigin.stdout.length > 0;

  console.log(`Active Chrome profile: ${activeProfile}`);
  console.log(`build/web/index.html uses cache-busted bootstrap: yes`);
  console.log(`Stale cached index.html snippet found: ${hasStaleIndex ? 'yes' : 'no'}`);
  console.log(`Cached flutter_service_worker reference found: ${hasCachedBootstrap ? 'yes' : 'no'}`);
  console.log(`Cached localhost:8000 entries found: ${hasLocalhostCache ? 'yes' : 'no'}`);

  if (hasStaleIndex || hasCachedBootstrap || hasLocalhostCache) {
    console.error('');
    console.error('Stale Chrome cache detected for localhost:8000.');
    if (hasStaleIndex) {
      console.error('Cached index.html still contains the old bootstrap tag.');
      console.error(staleIndex.stdout.split(/\r?\n/).slice(0, 5).join('\n'));
    }
    if (hasCachedBootstrap) {
      console.error('Cached bootstrap/service-worker bundle still exists in CacheStorage.');
      console.error(cachedBootstrap.stdout.split(/\r?\n/).slice(0, 5).join('\n'));
    }
    process.exit(1);
  }

  console.log('No stale localhost:8000 service-worker cache detected.');
} catch (error) {
  console.error(error.message || String(error));
  process.exit(1);
}
