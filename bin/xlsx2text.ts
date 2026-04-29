import * as XLSX from "xlsx";
import { readFileSync } from "fs";

const filePath = process.argv[2];
if (!filePath) {
  console.error("Usage: xlsx2text <file>");
  process.exit(1);
}

const buffer = readFileSync(filePath);
const workbook = XLSX.read(buffer, { type: "buffer" });
for (const sheetName of workbook.SheetNames) {
  console.log(`=== Sheet: ${sheetName} ===`);
  const sheet = workbook.Sheets[sheetName];
  console.log(XLSX.utils.sheet_to_csv(sheet));
}
