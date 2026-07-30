/**
 * Dictionaries — data access for the dictionary system:
 *   DCTMST  dictionaries            (green screens DCTMSTD1/D2)
 *   DCTFLD  fields per dictionary   (DCTFLDD1/D2)
 *   FLDTYP  field types + rules     (FLDTYPD1 — drives form validation)
 *   DCTVAL  enumerated values       (DCTVALD1/D2)
 *
 * Stored-procedure contracts (implemented in QSRC members apidct…,
 * apifld…, apityp… and apival…, routed by the CGI dispatcher; see
 * BACKEND.md and RULES.md S5).
 * Booleans cross the wire as JSON true/false. `created`/`maintained` are
 * preformatted audit strings (timestamp, job, program) for detail views
 * (RULES.md U7).
 *
 * While MOCK is true these functions run against in-memory sample data
 * seeded from the green-screen captures.
 */
import { callProcedure, MOCK } from './client'

export interface Dictionary {
  /** Dictionary name — the key; 1 to 10 characters, uppercase */
  dictionary: string
  description: string
  note: string
  active: boolean
  created: string
  maintained: string
}

export interface FieldType {
  /** Type code, e.g. CHAR, DECIMAL — the key */
  fieldType: string
  description: string
  isNumeric: boolean
  allowDecimals: boolean
  allowLength: boolean
  requireLength: boolean
  allowAllocation: boolean
  requireAllocation: boolean
  /** 0 = no maximum */
  maxLength: number
  /** When true, length must be one of forceLengths */
  forceLength: boolean
  /** Allowed lengths when forceLength (zeros are unused slots) */
  forceLengths: number[]
  typeDefault: string
}

export interface DictionaryField {
  /** Field name — key within the dictionary; 1 to 10 characters */
  field: string
  fieldSql: string
  description: string
  columnText: string
  heading1: string
  heading2: string
  heading3: string
  type: string
  length: number
  scale: number
  allocation: number
  projectNumber: string
  promptText: string
  allowNull: boolean
  defaultValue: string
  enumerated: boolean
  active: boolean
  created: string
  maintained: string
}

export interface EnumValue {
  /** Stored value — key within dictionary+field; up to 10 characters */
  value: string
  description: string
  active: boolean
}

/** "CHAR(15)", "DECIMAL(5,0)", "VARCHAR(100) ALLOCATE(50)", "BIGINT" —
 *  matches the green screen's type rendering. */
export function formatFieldType(
  f: Pick<DictionaryField, 'type' | 'length' | 'scale' | 'allocation'>,
  types: Map<string, FieldType>,
): string {
  const rules = types.get(f.type)
  let text = f.type
  if (f.length > 0) {
    text += rules?.allowDecimals ? `(${f.length},${f.scale})` : `(${f.length})`
  }
  if (f.allocation > 0) {
    text += ` ALLOCATE(${f.allocation})`
  }
  return text
}

// ---------------------------------------------------------------------------
// Mock data (RULES.md C4) — seeded from the DCTMSTD1/DCTFLDD1/FLDTYPD1 shots
// ---------------------------------------------------------------------------

const MOCK_AUDIT = '2025-05-20 14:36:41  012919/TTOGNAZZIN/SPP00098A0  FLEFLDB7'

const mockDictionaries: Dictionary[] = [
  {
    dictionary: 'APLDCT',
    description: 'Application Development Dictionary',
    note: 'Application Development Dictionary',
    active: true,
    created: MOCK_AUDIT,
    maintained: MOCK_AUDIT,
  },
  {
    dictionary: 'ERPDCT',
    description: 'ERP Dictionary, all new tables',
    note: '',
    active: true,
    created: MOCK_AUDIT,
    maintained: MOCK_AUDIT,
  },
  {
    dictionary: 'MRPDCT',
    description: 'Dictionary file for MRPS38S files',
    note: '',
    active: true,
    created: MOCK_AUDIT,
    maintained: MOCK_AUDIT,
  },
]

const mockTypes: FieldType[] = [
  mockType('BIGINT', 'Big Integer', { isNumeric: true }),
  mockType('CHAR', 'Character Field', {
    allowLength: true,
    requireLength: true,
    maxLength: 32766,
  }),
  mockType('DATE', 'Date', {}),
  mockType('DECFLOAT', 'Decimal Floating Point', {
    isNumeric: true,
    allowLength: true,
    requireLength: true,
    forceLength: true,
    forceLengths: [16, 34, 0, 0, 0],
  }),
  mockType('DECIMAL', 'Packed Decimal', {
    isNumeric: true,
    allowDecimals: true,
    allowLength: true,
    requireLength: true,
    maxLength: 63,
  }),
  mockType('IDENTITY', 'Auto Generated Identity Column', { isNumeric: true }),
  mockType('INTEGER', 'Integer', { isNumeric: true }),
  mockType('NUMERIC', 'Zoned Numeric', {
    isNumeric: true,
    allowDecimals: true,
    allowLength: true,
    requireLength: true,
    maxLength: 63,
  }),
  mockType('TIMESTAMP', 'Time Stamp', {}),
  mockType('VARCHAR', 'Variable Character Field', {
    allowLength: true,
    requireLength: true,
    allowAllocation: true,
    maxLength: 32740,
  }),
]

function mockType(code: string, description: string, o: Partial<FieldType>): FieldType {
  return {
    fieldType: code,
    description,
    isNumeric: false,
    allowDecimals: false,
    allowLength: false,
    requireLength: false,
    allowAllocation: false,
    requireAllocation: false,
    maxLength: 0,
    forceLength: false,
    forceLengths: [0, 0, 0, 0, 0],
    typeDefault: '',
    ...o,
  }
}

function mockField(
  field: string,
  columnText: string,
  type: string,
  length: number,
  o: Partial<DictionaryField> = {},
): DictionaryField {
  return {
    field,
    fieldSql: columnText.toLowerCase().replace(/[^a-z0-9]+/g, '_'),
    description: columnText,
    columnText,
    heading1: columnText.slice(0, 20),
    heading2: '',
    heading3: '',
    type,
    length,
    scale: 0,
    allocation: 0,
    projectNumber: '',
    promptText: '',
    allowNull: false,
    defaultValue: '',
    enumerated: false,
    active: true,
    created: MOCK_AUDIT,
    maintained: MOCK_AUDIT,
    ...o,
  }
}

const mockFields: Record<string, DictionaryField[]> = {
  APLDCT: [
    mockField('AARFLR', 'Auto Archive Folder', 'CHAR', 128),
    mockField('ABCFLEIDN', 'Test file Id', 'BIGINT', 0),
    mockField('ACGCDE', 'Accounting Code', 'CHAR', 15),
    mockField('ACTCDE', 'Action Code', 'CHAR', 2),
    mockField('ACVDES', 'Active Description', 'CHAR', 8),
    mockField('ACVROW', 'Active Row', 'CHAR', 1, {
      enumerated: true,
      defaultValue: "'1'",
    }),
    mockField('AFTVAL', 'After Value', 'VARCHAR', 100, { allocation: 50 }),
    mockField('ALWDEC', 'Allow Decimal Positions', 'CHAR', 1, { enumerated: true }),
    mockField('AMT', 'Amount', 'DECIMAL', 15, { scale: 2 }),
    mockField('CRTDTM', 'Create Date/Time', 'TIMESTAMP', 0),
  ],
  ERPDCT: [
    mockField('ACVROW', 'Active Row', 'CHAR', 1, { enumerated: true, defaultValue: "'1'" }),
    mockField('ITMNBR', 'Item Number', 'CHAR', 15),
  ],
  MRPDCT: [mockField('ITEM', 'Item Number', 'CHAR', 15)],
}

const mockValues: Record<string, EnumValue[]> = {
  'APLDCT|ACVROW': [
    { value: '0', description: 'Inactive', active: true },
    { value: '1', description: 'Active', active: true },
  ],
  'ERPDCT|ACVROW': [
    { value: '0', description: 'Inactive', active: true },
    { value: '1', description: 'Active', active: true },
  ],
}

function mockDelay(): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, 300))
}

// ---------------------------------------------------------------------------
// Dictionaries
// ---------------------------------------------------------------------------

export async function listDictionaries(): Promise<Dictionary[]> {
  if (MOCK) {
    await mockDelay()
    return mockDictionaries.map((d) => ({ ...d }))
  }
  return callProcedure<Dictionary[]>('dictionaries/list')
}

export async function addDictionary(d: Dictionary): Promise<void> {
  if (MOCK) {
    await mockDelay()
    if (mockDictionaries.some((x) => x.dictionary === d.dictionary)) {
      throw new Error('Dictionary already exists')
    }
    mockDictionaries.push({ ...d, active: true, created: MOCK_AUDIT, maintained: MOCK_AUDIT })
    mockDictionaries.sort((a, b) => a.dictionary.localeCompare(b.dictionary))
    mockFields[d.dictionary] = []
    return
  }
  await callProcedure('dictionaries/add', { ...d })
}

export async function updateDictionary(d: Dictionary): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = mockDictionaries.find((x) => x.dictionary === d.dictionary)
    if (!existing) {
      throw new Error('Dictionary not found')
    }
    Object.assign(existing, { description: d.description, note: d.note })
    return
  }
  await callProcedure('dictionaries/update', { ...d })
}

export async function setDictionaryStatus(dictionary: string, active: boolean): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = mockDictionaries.find((x) => x.dictionary === dictionary)
    if (!existing) {
      throw new Error('Dictionary not found')
    }
    existing.active = active
    return
  }
  await callProcedure('dictionaries/set-status', { dictionary, active })
}

// ---------------------------------------------------------------------------
// Field types
// ---------------------------------------------------------------------------

export async function listFieldTypes(): Promise<FieldType[]> {
  if (MOCK) {
    await mockDelay()
    return mockTypes.map((t) => ({ ...t, forceLengths: [...t.forceLengths] }))
  }
  return callProcedure<FieldType[]>('field-types/list')
}

// ---------------------------------------------------------------------------
// Fields
// ---------------------------------------------------------------------------

export async function listFields(dictionary: string): Promise<DictionaryField[]> {
  if (MOCK) {
    await mockDelay()
    return (mockFields[dictionary] ?? []).map((f) => ({ ...f }))
  }
  return callProcedure<DictionaryField[]>('dictionaries/fields/list', { dictionary })
}

export async function addField(dictionary: string, f: DictionaryField): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const fields = (mockFields[dictionary] ??= [])
    if (fields.some((x) => x.field === f.field)) {
      throw new Error('Field already exists in this dictionary')
    }
    fields.push({ ...f, active: true, created: MOCK_AUDIT, maintained: MOCK_AUDIT })
    fields.sort((a, b) => a.field.localeCompare(b.field))
    return
  }
  await callProcedure('dictionaries/fields/add', { dictionary, ...f })
}

export async function updateField(dictionary: string, f: DictionaryField): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = (mockFields[dictionary] ?? []).find((x) => x.field === f.field)
    if (!existing) {
      throw new Error('Field not found')
    }
    Object.assign(existing, f)
    return
  }
  await callProcedure('dictionaries/fields/update', { dictionary, ...f })
}

export async function setFieldStatus(
  dictionary: string,
  field: string,
  active: boolean,
): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = (mockFields[dictionary] ?? []).find((x) => x.field === field)
    if (!existing) {
      throw new Error('Field not found')
    }
    existing.active = active
    return
  }
  await callProcedure('dictionaries/fields/set-status', { dictionary, field, active })
}

// ---------------------------------------------------------------------------
// Enumerated values
// ---------------------------------------------------------------------------

export async function listValues(dictionary: string, field: string): Promise<EnumValue[]> {
  if (MOCK) {
    await mockDelay()
    return (mockValues[`${dictionary}|${field}`] ?? []).map((v) => ({ ...v }))
  }
  return callProcedure<EnumValue[]>('dictionaries/values/list', { dictionary, field })
}

export async function addValue(
  dictionary: string,
  field: string,
  value: EnumValue,
): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const values = (mockValues[`${dictionary}|${field}`] ??= [])
    if (values.some((v) => v.value === value.value)) {
      throw new Error('Value already exists for this field')
    }
    values.push({ ...value, active: true })
    values.sort((a, b) => a.value.localeCompare(b.value))
    return
  }
  await callProcedure('dictionaries/values/add', { dictionary, field, ...value })
}

export async function updateValue(
  dictionary: string,
  field: string,
  value: EnumValue,
): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = (mockValues[`${dictionary}|${field}`] ?? []).find(
      (v) => v.value === value.value,
    )
    if (!existing) {
      throw new Error('Value not found')
    }
    existing.description = value.description
    return
  }
  await callProcedure('dictionaries/values/update', { dictionary, field, ...value })
}

export async function setValueStatus(
  dictionary: string,
  field: string,
  value: string,
  active: boolean,
): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = (mockValues[`${dictionary}|${field}`] ?? []).find((v) => v.value === value)
    if (!existing) {
      throw new Error('Value not found')
    }
    existing.active = active
    return
  }
  await callProcedure('dictionaries/values/set-status', { dictionary, field, value, active })
}
