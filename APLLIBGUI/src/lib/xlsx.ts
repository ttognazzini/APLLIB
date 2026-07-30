/**
 * Minimal .xlsx writer — single sheet, string cells — enough for list
 * exports without pulling in a full spreadsheet library (RULES.md S9).
 * An .xlsx file is a zip of XML parts; fflate provides the zip.
 */
import { strToU8, zipSync } from 'fflate'

function esc(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

/** 0 → A, 1 → B, … 26 → AA */
function colRef(index: number): string {
  let ref = ''
  let n = index + 1
  while (n > 0) {
    ref = String.fromCharCode(65 + ((n - 1) % 26)) + ref
    n = Math.floor((n - 1) / 26)
  }
  return ref
}

export function makeXlsx(
  sheetName: string,
  headers: string[],
  rows: string[][],
): Uint8Array<ArrayBuffer> {
  // Sheet names: max 31 chars, no \ / ? * [ ] :
  const name = esc(sheetName.replace(/[\\/?*[\]:]/g, ' ').trim().slice(0, 31)) || 'Export'

  const rowXml = [headers, ...rows]
    .map((cells, r) => {
      const cols = cells
        .map(
          (cell, c) =>
            `<c r="${colRef(c)}${r + 1}" t="inlineStr"><is><t xml:space="preserve">${esc(cell)}</t></is></c>`,
        )
        .join('')
      return `<row r="${r + 1}">${cols}</row>`
    })
    .join('')

  const contentTypes =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' +
    '<Default Extension="xml" ContentType="application/xml"/>' +
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>' +
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>' +
    '</Types>'

  const rootRels =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' +
    '</Relationships>'

  const workbook =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' +
    `<sheets><sheet name="${name}" sheetId="1" r:id="rId1"/></sheets>` +
    '</workbook>'

  const workbookRels =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>' +
    '</Relationships>'

  const sheet =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' +
    `<sheetData>${rowXml}</sheetData>` +
    '</worksheet>'

  // zipSync allocates a fresh, non-shared buffer; the cast just tells
  // TypeScript so, since fflate types it as ArrayBufferLike.
  return zipSync({
    '[Content_Types].xml': strToU8(contentTypes),
    '_rels/.rels': strToU8(rootRels),
    'xl/workbook.xml': strToU8(workbook),
    'xl/_rels/workbook.xml.rels': strToU8(workbookRels),
    'xl/worksheets/sheet1.xml': strToU8(sheet),
  }) as Uint8Array<ArrayBuffer>
}
