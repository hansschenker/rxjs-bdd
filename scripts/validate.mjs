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
//   3. operators/<operator>.md is an exact mirror of the JSON: one file per operator, same rules
//      in the same order, same summary paragraph and note; and docs/operators.md indexes every
//      operator in order with that summary and a matching operator count in its footer.
//   4. Every spec/convertible/<operator>.feature parses under spec/convertible-bdd.ebnf, passes the
//      declaration-free semantic checks, and spec/convertible/trace.json maps every scenario to
//      catalog rules such that every rule of every operator is realised by at least one scenario.
//
// Exit code 0 when everything passes, 1 otherwise.

import { readFileSync, readdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import Ajv2020 from "ajv/dist/2020.js";
import { parseFeature, checkFeature, vocabulary } from "./convertible-bdd.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const read = (relativePath) => readFileSync(resolve(root, relativePath), "utf8");
const readJson = (relativePath) => JSON.parse(read(relativePath));

const CATALOG_PATH = "spec/operators.json";
const CATALOG_SCHEMA_PATH = "spec/operator-catalog.schema.json";
const MACHINE_SCHEMA_PATH = "spec/machine-semantic-model.schema.json";
const OPERATORS_DIR = "operators";
const INDEX_PATH = "docs/operators.md";

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
// 3. Markdown mirror: operators/<operator>.md files and the docs/operators.md index
// ---------------------------------------------------------------------------
/**
 * Parses one operators/<operator>.md file. The file starts with a "# `operator`" title, then a
 * summary paragraph (and an optional "*Note:*" line), then one "## <Kind> rule(s)" section per
 * rule kind, each holding a ```text block of Given / When / Then rules.
 */
function parseOperatorFile(name, text) {
  const path = `${OPERATORS_DIR}/${name}.md`;
  const lines = text.split(/\r?\n/);
  const parsed = { operator: name, summary: "", rules: [], note: null };
  const summaryLines = [];
  let kind = null;
  let inBlock = false;
  let block = [];
  let seenSection = false;

  const title = /^# `([^`]+)`$/.exec(lines[0] ?? "");
  if (!title) fail(`markdown: ${path} must start with the title "# \`${name}\`"`);
  else if (title[1] !== name) fail(`markdown: ${path} is titled "${title[1]}", expected "${name}"`);

  const flushBlock = () => {
    if (!kind) return;
    const groups = block.join("\n").split(/\n\s*\n/).filter((group) => group.trim() !== "");
    for (const group of groups) {
      const ruleLines = group.split("\n");
      const given = /^Given (.+)$/.exec(ruleLines[0] ?? "");
      const when = /^When (.+)$/.exec(ruleLines[1] ?? "");
      const then = /^Then (.+)$/.exec(ruleLines[2] ?? "");
      if (!given || !when || !then) {
        fail(`markdown: malformed rule under ${name} / ${kind}:\n${group}`);
        continue;
      }
      const steps = [then[1]];
      for (const continuation of ruleLines.slice(3)) {
        const step = /^ {5}(.+)$/.exec(continuation);
        if (!step) {
          fail(`markdown: bad continuation line under ${name} / ${kind}: "${continuation}"`);
          continue;
        }
        steps.push(step[1]);
      }
      parsed.rules.push({ kind, given: given[1], when: when[1], then: steps });
    }
    block = [];
  };

  for (const line of lines.slice(1)) {
    if (inBlock) {
      if (line === "```") {
        inBlock = false;
        flushBlock();
        kind = null;
      } else {
        block.push(line);
      }
      continue;
    }
    if (line === "```text" && kind) {
      inBlock = true;
      block = [];
      continue;
    }
    const sectionHeading = /^## (.+?)s?$/.exec(line);
    if (sectionHeading) {
      seenSection = true;
      kind = HEADING_KINDS.get(sectionHeading[1]) ?? null;
      if (kind === null) fail(`markdown: ${path} has an unknown section heading "${line}"`);
      continue;
    }
    if (/^#/.test(line)) {
      fail(`markdown: ${path} has an unexpected heading "${line}"`);
      continue;
    }
    const note = /^\*Note:\* (.+)$/.exec(line);
    if (note) {
      parsed.note = note[1];
      continue;
    }
    if (!seenSection && line.trim() !== "") summaryLines.push(line.trim());
  }

  parsed.summary = summaryLines.join(" ");
  if (!parsed.summary) fail(`markdown: ${path} has no summary paragraph between its title and its first rule section`);
  return parsed;
}

/** Parses the docs/operators.md index: one table row per operator linking to its file. */
function parseIndex(text) {
  const rows = [];
  for (const line of text.split(/\r?\n/)) {
    const row = /^\| \[`([^`]+)`\]\(\.\.\/operators\/([^)]+)\.md\) \| (.+) \|$/.exec(line);
    if (row) rows.push({ operator: row[1], file: row[2], summary: row[3] });
  }
  const footer = /\*\*(\d+) operator modules\*\*/.exec(text);
  return { rows, footerCount: footer ? Number(footer[1]) : null };
}

const operatorFiles = readdirSync(resolve(root, OPERATORS_DIR))
  .filter((file) => file.endsWith(".md"))
  .map((file) => file.slice(0, -".md".length))
  .sort();

const missingFiles = names.filter((name) => !operatorFiles.includes(name));
const extraFiles = operatorFiles.filter((name) => !names.includes(name));
if (missingFiles.length) fail(`markdown: no ${OPERATORS_DIR}/<operator>.md file for ${missingFiles.join(", ")}`);
if (extraFiles.length) fail(`markdown: ${OPERATORS_DIR}/ has files without a catalog operator: ${extraFiles.join(", ")}`);

const markdownOperators = new Map();
for (const name of names) {
  if (operatorFiles.includes(name)) markdownOperators.set(name, parseOperatorFile(name, read(`${OPERATORS_DIR}/${name}.md`)));
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
  const jsonSummary = operator.summary ?? null;
  if (jsonSummary !== mirrored.summary) {
    fail(`markdown: ${operator.operator} summary differs\n    JSON:     ${JSON.stringify(jsonSummary)}\n    Markdown: ${JSON.stringify(mirrored.summary)}`);
  }
}

const { rows: indexRows, footerCount } = parseIndex(read(INDEX_PATH));
const indexNames = indexRows.map((row) => row.operator);
if (JSON.stringify(indexNames) !== JSON.stringify(names)) {
  const missingInIndex = names.filter((name) => !indexNames.includes(name));
  const missingInJson = indexNames.filter((name) => !names.includes(name));
  if (missingInIndex.length) fail(`markdown: operators missing from the ${INDEX_PATH} table: ${missingInIndex.join(", ")}`);
  if (missingInJson.length) fail(`markdown: ${INDEX_PATH} lists operators missing from ${CATALOG_PATH}: ${missingInJson.join(", ")}`);
  if (!missingInIndex.length && !missingInJson.length) fail(`markdown: operator order differs between ${INDEX_PATH} and the JSON`);
}

for (const row of indexRows) {
  if (row.file !== row.operator) fail(`markdown: ${INDEX_PATH} links ${row.operator} to ${OPERATORS_DIR}/${row.file}.md`);
  const mirrored = markdownOperators.get(row.operator);
  if (mirrored && mirrored.summary !== row.summary) {
    fail(`markdown: ${INDEX_PATH} summary for ${row.operator} differs from ${OPERATORS_DIR}/${row.operator}.md\n    index: ${row.summary}\n    file:  ${mirrored.summary}`);
  }
}

if (footerCount === null) fail(`markdown: no operator count found in the ${INDEX_PATH} footer`);
else if (footerCount !== operators.length) fail(`markdown: ${INDEX_PATH} footer says ${footerCount} operators, JSON has ${operators.length}`);

// ---------------------------------------------------------------------------
// 4. Convertible BDD features and trace
// ---------------------------------------------------------------------------
const CONVERTIBLE_DIR = "spec/convertible";
const TRACE_PATH = `${CONVERTIBLE_DIR}/trace.json`;

const featureFiles = readdirSync(resolve(root, CONVERTIBLE_DIR))
  .filter((file) => file.endsWith(".feature"))
  .map((file) => file.slice(0, -".feature".length))
  .sort();
const trace = readJson(TRACE_PATH);
const traceOperators = trace.operators ?? {};

if (trace.version !== catalog.version) fail(`convertible: trace.json is for catalog ${trace.version}, catalog is ${catalog.version}`);

const missingFeatures = names.filter((name) => !featureFiles.includes(name));
const extraFeatures = featureFiles.filter((name) => !names.includes(name));
if (missingFeatures.length) fail(`convertible: no feature file for ${missingFeatures.join(", ")}`);
if (extraFeatures.length) fail(`convertible: feature file without catalog operator: ${extraFeatures.join(", ")}`);
for (const name of names) if (!traceOperators[name]) fail(`convertible: ${name} missing from ${TRACE_PATH}`);
for (const name of Object.keys(traceOperators)) if (!names.includes(name)) fail(`convertible: ${TRACE_PATH} lists unknown operator ${name}`);

let scenarioTotal = 0;
const inputSymbols = new Set();
const actionSymbols = new Set();
for (const operator of operators) {
  if (!featureFiles.includes(operator.operator)) continue;
  const path = `${CONVERTIBLE_DIR}/${operator.operator}.feature`;
  let feature;
  try {
    feature = parseFeature(read(path));
  } catch (error) {
    fail(`convertible: ${path}: ${error.message}`);
    continue;
  }
  if (feature.name !== operator.operator) fail(`convertible: ${path} declares Feature ${feature.name}`);
  for (const problem of checkFeature(feature)) fail(`convertible: ${problem}`);
  scenarioTotal += feature.scenarios.length;
  const words = vocabulary(feature);
  for (const name of words.inputs.keys()) inputSymbols.add(name);
  for (const name of words.actions.keys()) actionSymbols.add(name);

  const traced = traceOperators[operator.operator] ?? {};
  const scenarioNames = new Set(feature.scenarios.map((scenario) => scenario.name));
  const covered = new Set();
  for (const [scenarioName, indices] of Object.entries(traced)) {
    if (!scenarioNames.has(scenarioName)) fail(`convertible: trace for ${operator.operator} names unknown scenario ${scenarioName}`);
    if (!Array.isArray(indices) || indices.length === 0) fail(`convertible: ${operator.operator}/${scenarioName} traces no catalog rule`);
    for (const index of indices ?? []) {
      if (!Number.isInteger(index) || index < 1 || index > operator.rules.length) {
        fail(`convertible: ${operator.operator}/${scenarioName} traces rule ${index}, catalog has ${operator.rules.length}`);
      } else {
        covered.add(index);
      }
    }
  }
  for (const scenarioName of scenarioNames) {
    if (!traced[scenarioName]) fail(`convertible: ${operator.operator}/${scenarioName} has no trace entry`);
  }
  for (let index = 1; index <= operator.rules.length; index++) {
    if (!covered.has(index)) fail(`convertible: ${operator.operator} rule ${index} [${operator.rules[index - 1].kind}] is not realised by any scenario`);
  }
}

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
console.log(`${CONVERTIBLE_DIR}: ${featureFiles.length} features, ${scenarioTotal} scenarios, ${inputSymbols.size} input symbols, ${actionSymbols.size} action symbols`);

if (problems.length) {
  console.error(`\n${problems.length} problem${problems.length === 1 ? "" : "s"}:`);
  for (const problem of problems) console.error(`- ${problem}`);
  process.exit(1);
}
console.log("\nOK: schema, catalog invariants, Markdown mirror, and Convertible BDD features all pass.");
