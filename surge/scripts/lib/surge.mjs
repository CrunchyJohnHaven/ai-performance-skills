import fs from "node:fs";
import path from "node:path";

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) continue;
    const key = token.slice(2);
    const next = argv[i + 1];
    if (next && !next.startsWith("--")) {
      out[key] = next;
      i += 1;
    } else {
      out[key] = "true";
    }
  }
  return out;
}

function resolveWithinCwd(filePath) {
  return path.isAbsolute(filePath)
    ? filePath
    : path.join(process.cwd(), filePath);
}

function ensureParent(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function readJson(filePath, fallback) {
  if (!fs.existsSync(filePath)) return fallback;
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return fallback;
  }
}

function writeJson(filePath, value) {
  ensureParent(filePath);
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

function writeText(filePath, value) {
  ensureParent(filePath);
  fs.writeFileSync(filePath, value, "utf8");
}

function normalizeText(value) {
  return typeof value === "string" ? value.trim() : "";
}

function canonicalField(value) {
  const text = normalizeText(value);
  return text.length > 0 ? text : "TBD";
}

function optionalField(value) {
  const text = normalizeText(value);
  return text.length > 0 ? text : "";
}

function slugify(value) {
  return normalizeText(value)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80) || "deliverable";
}

function priorityWeight(priority) {
  const match = /^P(\d+)$/i.exec(normalizeText(priority));
  return match ? Number(match[1]) : 9;
}

function sortItems(items) {
  return [...items].sort((a, b) => {
    const priorityDelta = priorityWeight(a.priority) - priorityWeight(b.priority);
    if (priorityDelta !== 0) return priorityDelta;
    return a.what.localeCompare(b.what);
  });
}

function mdCell(value) {
  return canonicalField(value).replace(/\|/g, "\\|");
}

function renderTrackerMarkdown(data) {
  const items = sortItems(Array.isArray(data.items) ? data.items : []);
  const missingRows = [];

  const lines = [
    "# SURGE Deliverables Tracker",
    "",
    `**Last updated:** ${data.updatedAt ?? "TBD"}`,
    "**Canonical fields:** what, by when, pages, audience, format",
    `**Active rows:** ${items.length}`,
    "",
    "| Priority | What | By when | Pages | Audience | Format | Owner | Status |",
    "|---|---|---|---|---|---|---|---|",
  ];

  for (const item of items) {
    lines.push(
      `| ${mdCell(item.priority)} | ${mdCell(item.what)} | ${mdCell(item.byWhen)} | ${mdCell(item.pages)} | ${mdCell(item.audience)} | ${mdCell(item.format)} | ${mdCell(item.owner)} | ${mdCell(item.status)} |`,
    );

    const missing = [];
    for (const key of ["byWhen", "pages", "audience", "format"]) {
      if (canonicalField(item[key]) === "TBD") {
        missing.push(key === "byWhen" ? "by when" : key);
      }
    }
    if (missing.length > 0) {
      missingRows.push({ what: item.what, missing });
    }
  }

  lines.push("", "## Missing-field queue", "");

  if (missingRows.length === 0) {
    lines.push("None", "");
  } else {
    lines.push("| What | Missing |", "|---|---|");
    for (const row of missingRows) {
      lines.push(`| ${mdCell(row.what)} | ${row.missing.map((entry) => entry.replace(/\|/g, "\\|")).join(", ")} |`);
    }
    lines.push("");
  }

  lines.push("## Details", "");
  if (items.length === 0) {
    lines.push("None", "");
  } else {
    for (const item of items) {
      lines.push(`### ${item.priority} — ${item.what}`, "");
      lines.push(`- By when: ${canonicalField(item.byWhen)}`);
      lines.push(`- Pages: ${canonicalField(item.pages)}`);
      lines.push(`- Audience: ${canonicalField(item.audience)}`);
      lines.push(`- Format: ${canonicalField(item.format)}`);
      lines.push(`- Owner: ${canonicalField(item.owner)}`);
      lines.push(`- Status: ${canonicalField(item.status)}`);
      if (optionalField(item.source)) {
        lines.push(`- Source: ${item.source}`);
      }
      if (optionalField(item.notes)) {
        lines.push(`- Notes: ${item.notes}`);
      }
      lines.push("");
    }
  }

  return `${lines.join("\n").trimEnd()}\n`;
}

function renderDiscoveryMarkdown({ root, candidates, dueHints }) {
  const lines = [
    "# SURGE Discovery Inbox",
    "",
    `**Workspace root:** ${root}`,
    "**Purpose:** candidate deliverables and due/status hints to reconcile into the canonical tracker",
    "",
    "## Build-packet and deliverable candidates",
    "",
  ];

  if (candidates.length === 0) {
    lines.push("None", "");
  } else {
    lines.push("| What | Pages | Audience | Format | Source |", "|---|---|---|---|---|");
    for (const item of candidates) {
      lines.push(
        `| ${mdCell(item.what)} | ${mdCell(item.pages)} | ${mdCell(item.audience)} | ${mdCell(item.format)} | ${item.source.replace(/\|/g, "\\|")} |`,
      );
    }
    lines.push("");
  }

  lines.push("## Due and status hints", "");
  if (dueHints.length === 0) {
    lines.push("None", "");
  } else {
    lines.push("| What | By when | Status | Source |", "|---|---|---|---|");
    for (const item of dueHints) {
      lines.push(
        `| ${mdCell(item.what)} | ${mdCell(item.byWhen)} | ${mdCell(item.status)} | ${item.source.replace(/\|/g, "\\|")} |`,
      );
    }
    lines.push("");
  }

  lines.push("## Merge rule", "");
  lines.push("Promote only confirmed rows into `deliverables/SURGE_TRACKER.md` with `scripts/surge.sh`.");
  lines.push("If a field is unclear, carry `TBD` into the canonical tracker instead of guessing.");

  return `${lines.join("\n").trimEnd()}\n`;
}

function renderEmptyDiscovery(root) {
  return renderDiscoveryMarkdown({ root, candidates: [], dueHints: [] });
}

function initialTracker() {
  return {
    version: 1,
    updatedAt: new Date().toISOString(),
    items: [],
  };
}

function initFiles(args) {
  const trackerJson = resolveWithinCwd(args["tracker-json"]);
  const trackerMd = resolveWithinCwd(args["tracker-md"]);
  const discoveryMd = resolveWithinCwd(args["discovery-md"]);
  const tracker = readJson(trackerJson, initialTracker());
  tracker.updatedAt = tracker.updatedAt ?? new Date().toISOString();

  if (!fs.existsSync(trackerJson)) {
    writeJson(trackerJson, tracker);
  }
  if (!fs.existsSync(trackerMd)) {
    writeText(trackerMd, renderTrackerMarkdown(tracker));
  }
  if (!fs.existsSync(discoveryMd)) {
    writeText(discoveryMd, renderEmptyDiscovery(process.cwd()));
  }
}

function upsertItem(args) {
  const trackerJson = resolveWithinCwd(args["tracker-json"]);
  const trackerMd = resolveWithinCwd(args["tracker-md"]);
  const tracker = readJson(trackerJson, initialTracker());
  const what = canonicalField(args.what);
  const now = new Date().toISOString();
  const item = {
    id: slugify(what),
    priority: canonicalField(args.priority || "P2"),
    what,
    byWhen: canonicalField(args.by),
    pages: canonicalField(args.pages),
    audience: canonicalField(args.audience),
    format: canonicalField(args.format),
    owner: canonicalField(args.owner),
    status: canonicalField(args.status),
    source: optionalField(args.source),
    notes: optionalField(args.notes),
    updatedAt: now,
  };

  const items = Array.isArray(tracker.items) ? [...tracker.items] : [];
  const existingIndex = items.findIndex((entry) => entry.id === item.id);
  if (existingIndex >= 0) {
    items[existingIndex] = {
      ...items[existingIndex],
      ...item,
    };
  } else {
    items.push(item);
  }

  const next = {
    version: 1,
    updatedAt: now,
    items,
  };
  writeJson(trackerJson, next);
  writeText(trackerMd, renderTrackerMarkdown(next));
}

function listMarkdownFiles(root) {
  const out = [];
  const seen = new Set();

  const visit = (dir) => {
    if (!fs.existsSync(dir)) return;
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if ([".git", "node_modules", "dist", "evidence"].includes(entry.name)) {
        continue;
      }
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        visit(fullPath);
        continue;
      }
      if (!entry.isFile() || !entry.name.endsWith(".md")) continue;
      if (seen.has(fullPath)) continue;
      seen.add(fullPath);
      out.push(fullPath);
    }
  };

  visit(path.join(root, "deliverables"));
  visit(path.join(root, "projects"));

  return out.sort();
}

function rel(root, filePath) {
  return path.relative(root, filePath).split(path.sep).join("/");
}

function extractHeading(text) {
  return text.match(/^#\s+(.+)$/m)?.[1]?.trim() ?? "";
}

function extractPathDate(relativePath) {
  return relativePath.match(/20\d{2}-\d{2}-\d{2}/)?.[0] ?? "TBD";
}

function firstMatch(text, patterns) {
  for (const pattern of patterns) {
    const match = pattern.exec(text);
    if (match?.[1]) {
      return match[1].replace(/`/g, "").trim();
    }
  }
  return "";
}

function extractCandidate(root, filePath, text) {
  const heading = extractHeading(text);
  const requested = firstMatch(text, [
    /\*\*Requested deliverable:\*\*\s*(.+)$/im,
    /\*\*Project name:\*\*\s*(.+)$/im,
    /^Objective:\s*(.+)$/im,
  ]);
  const pages = firstMatch(text, [
    /\*\*Target page count:\*\*\s*`?([^`\n]+)`?/im,
    /Document target:\s*~?([0-9]+(?:\s*pages?|pp))/im,
    /\b([0-9]+-pager)\b/im,
  ]);
  const audience = firstMatch(text, [
    /\*\*Audience:\*\*\s*(.+)$/im,
    /^Audience:\s*(.+)$/im,
    /^Recipient:\s*(.+)$/im,
    /\*\*Core audience shape:\*\*\s*(.+)$/im,
  ]);
  let format = firstMatch(text, [
    /\*\*Format:\*\*\s*`?([^`\n]+)`?/im,
  ]);

  if (!format) {
    if (/\.pptx/i.test(text) && /\.pdf/i.test(text)) {
      format = "deck / PPTX+PDF";
    } else if (/\.docx/i.test(text) && /\.pdf/i.test(text)) {
      format = "brief / DOCX+PDF";
    } else if (/\b2-pager\b/i.test(text)) {
      format = "2-page brief";
    }
  }

  const looksUseful =
    /Build Packet/i.test(text) ||
    /\*\*Requested deliverable:\*\*/i.test(text) ||
    /\*\*Target page count:\*\*/i.test(text) ||
    /^Recipient:\s+/im.test(text) ||
    /\b(?:1|2|3|4|5|6|7|8)-pager\b/i.test(text);

  if (!looksUseful) return null;

  return {
    what: canonicalField(requested || heading),
    pages: canonicalField(pages),
    audience: canonicalField(audience),
    format: canonicalField(format),
    source: rel(root, filePath),
  };
}

function parseMarkdownTable(lines, startIndex) {
  const rows = [];
  for (let i = startIndex; i < lines.length; i += 1) {
    const line = lines[i].trim();
    if (!line.startsWith("|")) break;
    rows.push(line);
  }
  return rows;
}

function splitRow(row) {
  return row
    .split("|")
    .slice(1, -1)
    .map((cell) => cell.trim());
}

function extractDueHints(root, filePath, text) {
  const lines = text.split("\n");
  const out = [];
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i].trim();
    if (!line.startsWith("|")) continue;
    const rows = parseMarkdownTable(lines, i);
    if (rows.length < 2) continue;
    const header = splitRow(rows[0]).map((cell) => cell.toLowerCase());
    const divider = rows[1];
    if (!/^\|(?:\s*:?-+:?\s*\|)+$/.test(divider)) continue;

    const itemIndex = header.findIndex((cell) => cell === "item" || cell === "folder");
    const dueIndex = header.findIndex((cell) => cell === "due");
    const statusIndex = header.findIndex((cell) => cell === "status");
    if (itemIndex === -1 || statusIndex === -1) continue;

    for (const row of rows.slice(2)) {
      const cells = splitRow(row);
      if (cells.length <= Math.max(itemIndex, statusIndex, dueIndex)) continue;
      const what = cells[itemIndex];
      if (!what || what === "---") continue;
      out.push({
        what,
        byWhen: dueIndex === -1 ? extractPathDate(rel(root, filePath)) : canonicalField(cells[dueIndex]),
        status: canonicalField(cells[statusIndex]),
        source: rel(root, filePath),
      });
    }
    i += rows.length - 1;
  }
  return out;
}

function dedupeRows(rows, keyFn) {
  const seen = new Set();
  const out = [];
  for (const row of rows) {
    const key = keyFn(row);
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(row);
  }
  return out;
}

function scanWorkspace(args) {
  const root = path.resolve(args.root || process.cwd());
  const outPath = path.isAbsolute(args.out) ? args.out : path.join(root, args.out);
  const candidates = [];
  const dueHints = [];

  for (const filePath of listMarkdownFiles(root)) {
    const text = fs.readFileSync(filePath, "utf8");
    const candidate = extractCandidate(root, filePath, text);
    if (candidate) candidates.push(candidate);
    dueHints.push(...extractDueHints(root, filePath, text));
  }

  const next = renderDiscoveryMarkdown({
    root,
    candidates: dedupeRows(candidates, (row) => `${row.what}|${row.source}`),
    dueHints: dedupeRows(dueHints, (row) => `${row.what}|${row.byWhen}|${row.source}`),
  });
  writeText(outPath, next);
}

const [command, ...rest] = process.argv.slice(2);
const args = parseArgs(rest);

switch (command) {
  case "init":
    initFiles(args);
    break;
  case "upsert":
    upsertItem(args);
    break;
  case "scan":
    scanWorkspace(args);
    break;
  default:
    console.error(`unknown command: ${command || "(none)"}`);
    process.exit(1);
}
