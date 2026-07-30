/**
 * Segments — data access for the Dictionary Segment Master (green screens
 * DCTSEGD1/DCTSEGD2).
 *
 * Backing table: APLLIB.DCTSEG (SQL name dictionary_segments). Mapping from
 * this module's JSON fields to the table:
 *
 *   segment        DTASEG    data_segment                   CHAR(3)  primary key —
 *                            1 to 3 characters, stored uppercase, letters
 *                            and digits allowed
 *   description    DES       description                    CHAR(40)
 *   columnText     COLTXT    column_text                    CHAR(50)
 *   columnHeading  COLHDGSEG column_heading_for_a_segment   CHAR(20)
 *   conflict       CNFEXS    conflicts_exist                CHAR(1) '1'=Yes/'0'=No —
 *                            the segment code stands for more than one
 *                            word/phrase (e.g. CNF = Conflict/Config)
 *   note           NTE       note_                          CHAR(60)
 *   active         ACVROW    active_row                     CHAR(1) '1'=Active/'0'=Inactive
 *                            (every table in the system has acvRow)
 *
 * DCTSEGIDN (identity; every table gets <file>IDN) and the create_* /
 * maintenance_* audit columns are populated automatically by the file
 * system's trigger program — the UI never sends or shows them.
 *
 * Stored-procedure contracts (implemented in QSRC members apiseg* +
 * apisignon, routed by the CGI dispatcher; see BACKEND.md and RULES.md
 * S5). Booleans cross the wire as JSON true/false;
 * the procedures translate to/from the CHAR(1) flags and TRIM the
 * space-padded CHAR columns. Segments are never deleted — only deactivated
 * (ACVROW = '0'):
 *
 *   segments/list        APLLIB.API_SEG_LIST
 *                        IN:  (none)  OUT: JSON array — one entry per
 *                        segment, ALL rows including inactive
 *   segments/add         APLLIB.API_SEG_ADD
 *                        IN:  all fields above except active
 *                        (fails if DTASEG already exists; the UI defaults
 *                        blank columnText/columnHeading to the description
 *                        before sending, and the procedure enforces the
 *                        same rule)
 *   segments/update      APLLIB.API_SEG_UPDATE — same body; DTASEG is the key
 *   segments/set-status  APLLIB.API_SEG_SET_STATUS — { segment, active }
 *                        (covers Deactivate and Reactivate)
 *
 * Copy is a client-side flow: prefill the add form from an existing row,
 * then call segments/add.
 *
 * While MOCK is true these functions run against the in-memory sample data
 * below (seeded from the real DCTSEGD1 screen) so the page is fully usable
 * without an IBM i connection.
 */
import { callProcedure, MOCK } from './client'

export interface Segment {
  /** Segment code — the key; 1 to 3 characters, uppercase letters/digits */
  segment: string
  description: string
  columnText: string
  columnHeading: string
  conflict: boolean
  note: string
  active: boolean
}

// ---------------------------------------------------------------------------
// Mock data (RULES.md C4: mutations must behave realistically or fail loudly)
// ---------------------------------------------------------------------------

function mockSeg(
  segment: string,
  description: string,
  overrides: Partial<Segment> = {},
): Segment {
  return {
    segment,
    description,
    columnText: description,
    columnHeading: description,
    conflict: false,
    note: '',
    active: true,
    ...overrides,
  }
}

const mockStore: Segment[] = [
  mockSeg('AAR', 'Auto Archive'),
  mockSeg('ABC', 'ABC - Inventory Classification Code'),
  mockSeg('ABR', 'Abbreviated'),
  mockSeg('ACC', 'Account'),
  mockSeg('ACG', 'Accounting'),
  mockSeg('ACL', 'Auto Close'),
  mockSeg('ACT', 'Action/Account'),
  mockSeg('ACV', 'Active'),
  mockSeg('ADD', 'Address'),
  mockSeg('AFT', 'After'),
  mockSeg('AGC', 'Accounting Group Code'),
  mockSeg('ALC', 'Allocation'),
  mockSeg('ALW', 'Allow'),
  mockSeg('APL', 'Application'),
  mockSeg('APR', 'Approval'),
  mockSeg('ARA', 'Area'),
  mockSeg('CNF', 'Conflict/Config', { conflict: true }),
  mockSeg('COL', 'Column/ Collection', { conflict: true }),
  mockSeg('COM', 'Component/Communications', { conflict: true }),
  mockSeg('CPN', 'Component'),
  mockSeg('ITM', 'Item'),
  mockSeg('NBR', 'Number'),
  mockSeg('OLD', 'Old (do not use)', { active: false, conflict: true }),
]

function mockDelay(): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, 300))
}

// ---------------------------------------------------------------------------
// API
// ---------------------------------------------------------------------------

/** All segments, active and inactive; filtering/search happens client-side. */
export async function listSegments(): Promise<Segment[]> {
  if (MOCK) {
    await mockDelay()
    return mockStore.map((s) => ({ ...s }))
  }
  return callProcedure<Segment[]>('segments/list')
}

export async function addSegment(seg: Segment): Promise<void> {
  if (MOCK) {
    await mockDelay()
    if (mockStore.some((s) => s.segment === seg.segment)) {
      throw new Error(`Segment ${seg.segment} already exists`)
    }
    mockStore.push({ ...seg, active: true })
    mockStore.sort((a, b) => a.segment.localeCompare(b.segment))
    return
  }
  await callProcedure('segments/add', { ...seg })
}

export async function updateSegment(seg: Segment): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = mockStore.find((s) => s.segment === seg.segment)
    if (!existing) {
      throw new Error(`Segment ${seg.segment} not found`)
    }
    Object.assign(existing, seg)
    return
  }
  await callProcedure('segments/update', { ...seg })
}

export async function setSegmentStatus(segment: string, active: boolean): Promise<void> {
  if (MOCK) {
    await mockDelay()
    const existing = mockStore.find((s) => s.segment === segment)
    if (!existing) {
      throw new Error(`Segment ${segment} not found`)
    }
    existing.active = active
    return
  }
  await callProcedure('segments/set-status', { segment, active })
}
