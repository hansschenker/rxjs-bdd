#!/usr/bin/env node
// Validates the machine-readable operator catalog.
//
//   npm run validate
//
// Checks, in order:
//   1. spec/operators.json conforms to spec/operator-catalog.schema.json (JSON Schema 2020-12 via Ajv),
//      and spec/machine-semantic-model.schema.json compiles as a schema.
//   2. Catalog invariants documented in docs/machine-readable-spec.md: operators are unique and
//      alphabetical, every operator carries each lifecycle rule kind, and rule kinds appear in
//      lifecycle order.
//   3. docs/operators.md is an exact mirror of the JSON: same operators, same rules in the same
//      order, same notes, and a matching operator count in its footer.
//
// Exit code 0 when everything passes, 1 otherwise.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import Ajv2020 from "ajv/dist/2020.js";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const read = (relativePath) => readFileSync(resolve(root, relativePath), "utf8");
const readJson = (relativePath) => JSON.parse(read(relativePath));

const CATALOG_PATH = "spec/operators.json";
const CATALOG_SCHEMA_PATH = "spec/operator-catalog.schema.json";
const MACHINE_SCHEMA_PATH = "spec/machine-semantic-model.schema.json";
const MARKDOWN_PATH = "docs/operators.md";

/** Rule kinds every operator must carry at least once. */
const LIFECYCLE_KINDS = ["subscription", "state", "event", "completion", "error", "unsubscription", "cancellation"];

/** All rule kinds in the order they must appear within an operator. */
const KIND_ORDER = [
  "subscription",
  "state",
  "event",
  "timer",
  "notifier",
  "inner",
  "concurrency",
  "completion",
  "error",
  "unsubscription",
  "cancellation",
];

/** Markdown section headings (singular form) and the rule kind they carry. */
const HEADING_KINDS = new Map([
  ["Subscription rule", "subscription"],
  ["State-conditioned rule", "state"],
  ["Event-triggered rule", "event"],
  ["Timer rule", "timer"],
  ["Notifier rule", "notifier"],
  ["Inner rule", "inner"],
  ["Concurrency rule", "concurrency"],
  ["Completion rule", "completion"],
  ["Error rule", "error"],
  ["Unsubscription rule", "unsubscription"],
  ["Cancellation rule", "cancellation"],
]);

const problems = [];
const fail = (message) => problems.push(message);

// ---------------------------------------------------------------------------
// 1. JSON Schema validation
// ---------------------------------------------------------------------------
const catalog = readJson(CATALOG_PATH);
const ajv = new Ajv2020({ allErrors: true, strict: true });

const validateCatalog = ajv.compile(readJson(CATALOG_SCHEMA_PATH));
if (!validateCatalog(catalog)) {
  for (const error of validateCatalog.errors ?? []) {
    fail(`schema: ${error.instancePath || "/"} ${error.message}`);
  }
}

try {
  ajv.compile(readJson(MACHINE_SCHEMA_PATH));
} catch (error) {
  fail(`schema: ${MACHINE_SCHEMA_PATH} does not compile: ${error.message}`);
}

// ---------------------------------------------------------------------------
// 2. Catalog invariants
// ---------------------------------------------------------------------------
const operators = Array.isArray(catalog.operators) ? catalog.operators : [];
const names = operators.map((operator) => operator.operator);

for (let i = 1; i < names.length; i++) {
  if (names[i] === names[i - 1]) fail(`invariant: duplicate operator "${names[i]}"`);
  else if (names[i] < names[i - 1]) fail(`invariant: "${names[i]}" is out of alphabetical order (after "${names[i - 1]}")`);
}

for (const operator of operators) {
  const kinds = (operator.rules ?? []).map((rule) => rule.kind);
  for (const kind of LIFECYCLE_KINDS) {
    if (!kinds.includes(kind)) fail(`invariant: ${operator.operator} has no "${kind}" rule`);
  }
  for (let i = 1; i < kinds.length; i++) {
    if (KIND_ORDER.indexOf(kinds[i]) < KIND_ORDER.indexOf(kinds[i - 1])) {
      fail(`invariant: ${operator.operator} has a "${kinds[i]}" rule after a "${kinds[i - 1]}" rule`);
      break;
    }
  }
}

// ---------------------------------------------------------------------------
// 3. Markdown mirror
// ---------------------------------------------------------------------------
function parseMarkdown(text) {
  const lines = text.split(/\r?\n/);
  const parsed = new Map();
  let current = null;
  let kind = null;
  let inBlock = false;
  let block = [];
  let footerCount = null;

  const flushBlock = () => {
    if (!current || !kind) return;
    const groups = block.join("\n").split(/\n\s*\n/).filter((group) => group.trim() !== "");
    for (const group of groups) {
      const ruleLines = group.split("\n");
      const given = /^Given (.+)$/.exec(ruleLines[0] ?? "");
      const when = /^When (.+)$/.exec(ruleLines[1] ?? "");
      const then = /^Then (.+)$/.exec(ruleLines[2] ?? "");
      if (!given || !when || !then) {
        fail(`markdown: malformed rule under ${current.operator} / ${kind}:\n${group}`);
        continue;
      }
      const steps = [then[1]];
      for (const continuation of ruleLines.slice(3)) {
        const step = /^ {5}(.+)$/.exec(continuation);
        if (!step) {
          fail(`markdown: bad continuation line under ${current.operator} / ${kind}: "${continuation}"`);
          continue;
        }
        steps.push(step[1]);
      }
      current.rules.push({ kind, given: given[1], when: when[1], then: steps });
    }
    block = [];
  };

  for (const line of lines) {
    const operatorHeading = /^## `([^`]+)`$/.exec(line);
    if (operatorHeading) {
      current = { operator: operatorHeading[1], rules: [], note: null };
      parsed.set(current.operator, current);
      kind = null;
      continue;
    }
    if (!current) {
      continue;
    }
    if (/^## /.test(line)) {
      current = null;
      kind = null;
      continue;
    }
    const sectionHeading = /^### (.+?)s?$/.exec(line);
    if (sectionHeading && HEADING_KINDS.has(sectionHeading[1])) {
      kind = HEADING_KINDS.get(sectionHeading[1]);
      continue;
    }
    if (line === "```text" && kind) {
      inBlock = true;
      block = [];
      continue;
    }
    if (line === "```" && inBlock) {
      inBlock = false;
      flushBlock();
      kind = null;
      continue;
    }
    if (inBlock) {
      block.push(line);
      continue;
    }
    const note = /^\*Note:\* (.+)$/.exec(line);
    if (note) current.note = note[1];
  }

  const footer = /This document contains \*\*(\d+) operator modules\*\*/.exec(text);
  if (footer) footerCount = Number(footer[1]);
  return { parsed, footerCount };
}

const { parsed: markdownOperators, footerCount } = parseMarkdown(read(MARKDOWN_PATH));

const markdownNames = [...markdownOperators.keys()];
if (JSON.stringify(markdownNames) !== JSON.stringify(names)) {
  const missingInMd = names.filter((name) => !markdownOperators.has(name));
  const missingInJson = markdownNames.filter((name) => !names.includes(name));
  if (missingInMd.length) fail(`markdown: operators missing from ${MARKDOWN_PATH}: ${missingInMd.join(", ")}`);
  if (missingInJson.length) fail(`markdown: operators missing from ${CATALOG_PATH}: ${missingInJson.join(", ")}`);
  if (!missingInMd.length && !missingInJson.length) fail("markdown: operator order differs between the Markdown and the JSON");
}

for (const operator of operators) {
  const mirrored = markdownOperators.get(operator.operator);
  if (!mirrored) continue;
  const jsonRules = JSON.stringify(operator.rules);
  const mdRules = JSON.stringify(mirrored.rules);
  if (jsonRules !== mdRules) {
    const count = Math.min(operator.rules.length, mirrored.rules.length);
    let detail = `JSON has ${operator.rules.length} rules, Markdown has ${mirrored.rules.length}`;
    for (let i = 0; i < count; i++) {
      if (JSON.stringify(operator.rules[i]) !== JSON.stringify(mirrored.rules[i])) {
        detail = `rule ${i + 1} differs\n    JSON:     ${JSON.stringify(operator.rules[i])}\n    Markdown: ${JSON.stringify(mirrored.rules[i])}`;
        break;
      }
    }
    fail(`markdown: ${operator.operator} rules differ: ${detail}`);
  }
  const jsonNote = operator.note ?? null;
  if (jsonNote !== mirrored.note) {
    fail(`markdown: ${operator.operator} note differs\n    JSON:     ${JSON.stringify(jsonNote)}\n    Markdown: ${JSON.stringify(mirrored.note)}`);
  }
}

if (footerCount === null) fail(`markdown: no operator count found in the ${MARKDOWN_PATH} footer`);
else if (footerCount !== operators.length) fail(`markdown: footer says ${footerCount} operators, JSON has ${operators.length}`);

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------
const counts = {};
for (const operator of operators) for (const rule of operator.rules ?? []) counts[rule.kind] = (counts[rule.kind] ?? 0) + 1;
const totalRules = Object.values(counts).reduce((sum, n) => sum + n, 0);

console.log(`${CATALOG_PATH} v${catalog.version}: ${operators.length} operators, ${totalRules} rules`);
for (const kind of KIND_ORDER) {
  if (counts[kind]) console.log(`  ${kind.padEnd(14)} ${String(counts[kind]).padStart(4)}`);
}

if (problems.length) {
  console.error(`\n${problems.length} problem${problems.length === 1 ? "" : "s"}:`);
  for (const problem of problems) console.error(`- ${problem}`);
  process.exit(1);
}
console.log("\nOK: schema, catalog invariants, and Markdown mirror all pass.");
