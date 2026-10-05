import { watch } from "node:fs";
import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import tailwindcss from "@tailwindcss/postcss";
import postcss from "postcss";

const root = process.cwd();
const inputPath = resolve(root, "sass/tailwind.css");
const outputPath = resolve(root, "static/tailwind.css");
const watchMode = process.argv.includes("--watch");

async function build() {
	const input = await readFile(inputPath, "utf8");
	const result = await postcss([tailwindcss({ optimize: !watchMode })]).process(
		input,
		{
			from: inputPath,
			to: outputPath,
		},
	);
	await writeFile(outputPath, result.css);
}

await build();

if (watchMode) {
	const watchPaths = ["sass", "templates", "content", "themes"];
	let timer;
	let buildQueue = Promise.resolve();

	for (const path of watchPaths) {
		watch(resolve(root, path), { recursive: true }, () => {
			clearTimeout(timer);
			timer = setTimeout(() => {
				buildQueue = buildQueue.then(async () => {
					try {
						await build();
						process.exitCode = 0;
					} catch (error) {
						console.error(error);
						process.exitCode = 1;
					}
				});
			}, 100);
		});
	}
}
