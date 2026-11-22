import assert from "node:assert/strict";

const origin = new URL(process.argv[2] || "http://127.0.0.1:8081");
const pages = ["index.html", "collections.html", "membership.html", "services.html", "contact.html"];
const stylesheets = new Set();

function attributes(tag) {
  const values = {};
  for (const match of tag.matchAll(/([a-z][\w-]*)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>]+))/gi)) {
    values[match[1].toLowerCase()] = match[2] ?? match[3] ?? match[4];
  }
  return values;
}

async function read(url) {
  const response = await fetch(url, { signal: AbortSignal.timeout(5000) });
  assert.equal(response.status, 200, "Expected HTTP 200 for " + url);
  return response.text();
}

let ready = false;
for (let attempt = 0; attempt < 30; attempt++) {
  try {
    await read(new URL("index.html", origin));
    ready = true;
    break;
  } catch {
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}
assert.ok(ready, "The website did not become ready at " + origin);

for (const page of pages) {
  const body = await read(new URL(page, origin));
  assert.match(body, /<h1\b[^>]*>[\s\S]+?<\/h1>/i, "Missing page heading: " + page);
  assert.ok(body.includes("Readers"), "Unexpected page content: " + page);
  assert.ok(!body.includes("Welcome to nginx!"), "Default Nginx page served: " + page);
  const nav = body.match(/<nav\b[^>]*>[\s\S]*?<\/nav>/i)?.[0];
  assert.ok(nav, "Missing navigation: " + page);
  const links = [...nav.matchAll(/<a\b[^>]*>/gi)].map(match => attributes(match[0]).href);
  for (const required of pages) assert.ok(links.includes(required), "Missing " + required + " link on " + page);
  for (const match of body.matchAll(/<link\b[^>]*>/gi)) {
    const attrs = attributes(match[0]);
    if (attrs.rel === "stylesheet" && attrs.href) stylesheets.add(new URL(attrs.href, new URL(page, origin)).href);
  }
  console.log("PASS " + page + ": HTTP 200, heading, content and five navigation links");
}

assert.ok(stylesheets.size > 0, "No stylesheets were linked");
let css = "";
for (const url of stylesheets) css += await read(url);
for (const selector of [":root", ".page-home", ".page-collections", ".page-membership", ".page-services", ".page-contact"]) {
  assert.ok(css.includes(selector), "Missing shared or page styles: " + selector);
}
console.log("PASS linked CSS: HTTP 200, shared variables and all five page styles");
