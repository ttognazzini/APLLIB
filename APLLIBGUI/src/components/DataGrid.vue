<script lang="ts">
/** Column definition for DataGrid (RULES.md U4). */
export interface GridColumn<T> {
  /** Row property name; also the id used for filters and sorting */
  key: string
  label: string
  /** Text used for display, search, filter, sort, and export.
   *  Defaults to String(row[key]). */
  text?: (row: T) => string
  width?: string
  /** Data type driving the condition filters in the column's filter menu
   *  (default 'text'): number offers =, >, <, between…; date offers
   *  on/before/after/between with date pickers. */
  type?: 'text' | 'number' | 'date'
}
</script>

<script setup lang="ts" generic="T">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import AppIcon from './AppIcon.vue'
import { saveFile } from '@/lib/download'
import { makeXlsx } from '@/lib/xlsx'

// The standard list component (RULES.md U4): generic search, click-to-sort
// headers (toggling asc/desc), Excel-style column filters (a funnel on
// each header opens a checklist of that column's values), pagination
// (15/25/50/All), and Excel/CSV export of the full filtered view
// (search + filters + sort — all pages, not just the visible one).
const props = defineProps<{
  columns: GridColumn<T>[]
  rows: T[]
  rowKey: (row: T) => string
  /** Base filename for exports, e.g. "segments" */
  exportName: string
  hasActions?: boolean
  rowClass?: (row: T) => string
  /** Size of the full dataset BEFORE page-level pre-filters (e.g. a
   *  "Show inactive" toggle), for the "…from N rows available" counter.
   *  Defaults to rows.length. */
  totalRows?: number
}>()

defineSlots<
  {
    /** Page-specific controls, right end of the toolbar */
    toolbar?: () => unknown
    /** Action links per row (not searched, sorted, or exported) */
    actions?: (props: { row: T }) => unknown
  } & Record<`cell-${string}`, (props: { row: T }) => unknown>
>()

const search = ref('')
const sortKey = ref('')
const sortAsc = ref(true)
const exportOpen = ref(false)

function cellText(col: GridColumn<T>, row: T): string {
  if (col.text) {
    return col.text(row)
  }
  const value = (row as Record<string, unknown>)[col.key]
  return value == null ? '' : String(value)
}

// --- Excel-style column filters --------------------------------------
// A column's filter is EITHER a checked-values Set OR a typed condition
// (equals / begins with / between / …) — applying one replaces the
// other, like Excel. No entry = unfiltered.
interface Cond {
  op: string
  a: string
  b: string
}
type ColumnFilter = { kind: 'values'; set: Set<string> } | ({ kind: 'cond' } & Cond)

const filters = reactive<Record<string, ColumnFilter>>({})
/** The open filter dropdown: which column, and where to place the menu */
const filterMenu = ref<{ key: string; top: number; left: number } | null>(null)
const menuSearch = ref('')

const activeFilterCount = computed(() => Object.keys(filters).length)

const CONDITION_OPS: Record<'text' | 'number' | 'date', { op: string; label: string }[]> = {
  text: [
    { op: 'contains', label: 'Contains' },
    { op: 'ncontains', label: 'Does not contain' },
    { op: 'starts', label: 'Begins with' },
    { op: 'ends', label: 'Ends with' },
    { op: 'eq', label: 'Equals' },
    { op: 'neq', label: 'Does not equal' },
  ],
  number: [
    { op: 'eq', label: '=  Equals' },
    { op: 'neq', label: '<> Does not equal' },
    { op: 'gt', label: '>  Greater than' },
    { op: 'ge', label: '>= Greater or equal' },
    { op: 'lt', label: '<  Less than' },
    { op: 'le', label: '<= Less or equal' },
    { op: 'between', label: 'Between' },
  ],
  date: [
    { op: 'eq', label: 'On' },
    { op: 'before', label: 'Before' },
    { op: 'after', label: 'After' },
    { op: 'between', label: 'Between' },
  ],
}

function dayNum(y: number, m: number, d: number): number {
  return y * 10000 + m * 100 + d
}

/** Cell text -> comparable day number (null if not a date) */
function cellDayNum(text: string): number | null {
  const t = Date.parse(text)
  if (Number.isNaN(t)) {
    return null
  }
  const d = new Date(t)
  return dayNum(d.getFullYear(), d.getMonth() + 1, d.getDate())
}

/** yyyy-mm-dd (from <input type=date>) -> day number */
function inputDayNum(value: string): number | null {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value)
  return m ? dayNum(Number(m[1]), Number(m[2]), Number(m[3])) : null
}

function passesCondition(type: 'text' | 'number' | 'date', text: string, cond: Cond): boolean {
  if (type === 'number') {
    const n = parseFloat(text.replace(/,/g, ''))
    const a = parseFloat(cond.a)
    const b = parseFloat(cond.b)
    if (Number.isNaN(n) || Number.isNaN(a)) {
      return false
    }
    switch (cond.op) {
      case 'eq':
        return n === a
      case 'neq':
        return n !== a
      case 'gt':
        return n > a
      case 'ge':
        return n >= a
      case 'lt':
        return n < a
      case 'le':
        return n <= a
      case 'between':
        return !Number.isNaN(b) && n >= Math.min(a, b) && n <= Math.max(a, b)
    }
    return true
  }
  if (type === 'date') {
    const n = cellDayNum(text)
    const a = inputDayNum(cond.a)
    const b = inputDayNum(cond.b)
    if (n === null || a === null) {
      return false
    }
    switch (cond.op) {
      case 'eq':
        return n === a
      case 'before':
        return n < a
      case 'after':
        return n > a
      case 'between':
        return b !== null && n >= Math.min(a, b) && n <= Math.max(a, b)
    }
    return true
  }
  const t = text.toLowerCase()
  const a = cond.a.toLowerCase()
  switch (cond.op) {
    case 'eq':
      return t === a
    case 'neq':
      return t !== a
    case 'starts':
      return t.startsWith(a)
    case 'ends':
      return t.endsWith(a)
    case 'contains':
      return t.includes(a)
    case 'ncontains':
      return !t.includes(a)
  }
  return true
}

function passesFilters(row: T, excludeKey?: string): boolean {
  return props.columns.every((c) => {
    if (c.key === excludeKey) {
      return true
    }
    const f = filters[c.key]
    if (!f) {
      return true
    }
    const text = cellText(c, row)
    return f.kind === 'values' ? f.set.has(text) : passesCondition(c.type ?? 'text', text, f)
  })
}

function passesSearch(row: T): boolean {
  const term = search.value.trim().toLowerCase()
  return term === '' || props.columns.some((c) => cellText(c, row).toLowerCase().includes(term))
}

const visible = computed(() => {
  let result = props.rows.filter((row) => passesSearch(row) && passesFilters(row))
  const col = props.columns.find((c) => c.key === sortKey.value)
  if (col) {
    result = [...result].sort((a, b) =>
      cellText(col, a).localeCompare(cellText(col, b), undefined, {
        numeric: true,
        sensitivity: 'base',
      }),
    )
    if (!sortAsc.value) {
      result.reverse()
    }
  }
  return result
})

// Values offered in the open dropdown: distinct cell texts of that
// column, cascaded like Excel — respecting the search box and every
// OTHER column's filter, but not this column's own.
const distinctValues = computed(() => {
  const menu = filterMenu.value
  if (!menu) {
    return []
  }
  const col = props.columns.find((c) => c.key === menu.key)
  if (!col) {
    return []
  }
  const seen = new Set<string>()
  for (const row of props.rows) {
    if (passesSearch(row) && passesFilters(row, col.key)) {
      seen.add(cellText(col, row))
    }
  }
  return [...seen].sort((a, b) =>
    a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }),
  )
})

/** The checklist as narrowed by the dropdown's own search box */
const listedValues = computed(() => {
  const t = menuSearch.value.trim().toLowerCase()
  return t === ''
    ? distinctValues.value
    : distinctValues.value.filter((v) => v.toLowerCase().includes(t))
})

function isSelected(value: string): boolean {
  const f = filterMenu.value ? filters[filterMenu.value.key] : undefined
  return !f || f.kind !== 'values' || f.set.has(value)
}

const allListedSelected = computed(() => listedValues.value.every((v) => isSelected(v)))
const someListedSelected = computed(
  () => !allListedSelected.value && listedValues.value.some((v) => isSelected(v)),
)

/** Current selection as a concrete Set (no entry or a condition filter
 *  means "all selected" — toggling a value then replaces the condition) */
function materialize(key: string): Set<string> {
  const existing = filters[key]
  return existing && existing.kind === 'values'
    ? new Set(existing.set)
    : new Set(distinctValues.value)
}

/** Store the set — or drop the filter entirely when it covers all values.
 *  A values-filter replaces any condition, so the condition row resets. */
function applySet(key: string, set: Set<string>) {
  if (distinctValues.value.every((v) => set.has(v))) {
    delete filters[key]
  } else {
    filters[key] = { kind: 'values', set }
  }
  condOp.value = ''
  condA.value = ''
  condB.value = ''
  page.value = 1
}

function toggleValue(value: string) {
  if (!filterMenu.value) {
    return
  }
  const key = filterMenu.value.key
  const set = materialize(key)
  if (set.has(value)) {
    set.delete(value)
  } else {
    set.add(value)
  }
  applySet(key, set)
}

function toggleAllListed() {
  if (!filterMenu.value) {
    return
  }
  const key = filterMenu.value.key
  const set = materialize(key)
  if (allListedSelected.value) {
    for (const v of listedValues.value) {
      set.delete(v)
    }
  } else {
    for (const v of listedValues.value) {
      set.add(v)
    }
  }
  applySet(key, set)
}

function clearFilter(key: string) {
  delete filters[key]
  condOp.value = ''
  condA.value = ''
  condB.value = ''
  page.value = 1
}

// Enter in the dropdown's search box: the filter becomes exactly the
// matching values (Excel's search-then-OK behavior), then the menu closes.
function applySearchMatches() {
  if (!filterMenu.value || listedValues.value.length === 0) {
    return
  }
  applySet(filterMenu.value.key, new Set(listedValues.value))
  filterMenu.value = null
  menuSearch.value = ''
}

// Excel's Sort A to Z / Z to A entries at the top of the filter menu.
function sortFromMenu(ascending: boolean) {
  if (!filterMenu.value) {
    return
  }
  sortKey.value = filterMenu.value.key
  sortAsc.value = ascending
  filterMenu.value = null
}

function clearAllFilters() {
  for (const key of Object.keys(filters)) {
    delete filters[key]
  }
  page.value = 1
}

// --- Condition filters (the Text/Number/Date Filters tier) -----------
const condOp = ref('')
const condA = ref('')
const condB = ref('')

const menuColType = computed<'text' | 'number' | 'date'>(() => {
  const col = props.columns.find((c) => c.key === filterMenu.value?.key)
  return col?.type ?? 'text'
})
const condOps = computed(() => CONDITION_OPS[menuColType.value])
const condInputType = computed(() =>
  menuColType.value === 'number' ? 'number' : menuColType.value === 'date' ? 'date' : 'text',
)

function applyCondition() {
  if (!filterMenu.value || condOp.value === '' || condA.value.trim() === '') {
    return
  }
  filters[filterMenu.value.key] = {
    kind: 'cond',
    op: condOp.value,
    a: condA.value.trim(),
    b: condB.value.trim(),
  }
  page.value = 1
  filterMenu.value = null
}

function openFilterMenu(col: GridColumn<T>, event: MouseEvent) {
  const rect = (event.currentTarget as HTMLElement).getBoundingClientRect()
  menuSearch.value = ''
  // Prefill the condition row when this column already has one
  const existing = filters[col.key]
  if (existing && existing.kind === 'cond') {
    condOp.value = existing.op
    condA.value = existing.a
    condB.value = existing.b
  } else {
    condOp.value = ''
    condA.value = ''
    condB.value = ''
  }
  filterMenu.value = {
    key: col.key,
    top: rect.bottom + 4,
    left: Math.min(rect.left, window.innerWidth - 270),
  }
}

// Close the dropdown on outside click or Escape (the menu itself stops
// mousedown propagation).
function onWindowMousedown() {
  filterMenu.value = null
  exportOpen.value = false
}
function onWindowKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    filterMenu.value = null
    exportOpen.value = false
  }
}
onMounted(() => {
  window.addEventListener('mousedown', onWindowMousedown)
  window.addEventListener('keydown', onWindowKeydown)
})
onBeforeUnmount(() => {
  window.removeEventListener('mousedown', onWindowMousedown)
  window.removeEventListener('keydown', onWindowKeydown)
})

// --- Pagination (RULES.md U4): 15 per page default; 0 means All -----
const pageSize = ref(15)
const page = ref(1)

const pageCount = computed(() =>
  pageSize.value === 0 ? 1 : Math.max(1, Math.ceil(visible.value.length / pageSize.value)),
)

const paged = computed(() => {
  if (pageSize.value === 0) {
    return visible.value
  }
  const start = (page.value - 1) * pageSize.value
  return visible.value.slice(start, start + pageSize.value)
})

// New search/page-size (or a changed dataset) restarts at page 1; filter
// changes reset it in applySet/clearFilter. Also clamp if the current
// page falls off the end.
watch([search, pageSize, () => props.rows], () => {
  page.value = 1
})
watch(pageCount, () => {
  if (page.value > pageCount.value) {
    page.value = pageCount.value
  }
})

const statusText = computed(() => {
  const available = props.totalRows ?? props.rows.length
  return (
    `Page ${page.value} of ${pageCount.value}. ` +
    `Filtered ${visible.value.length} rows from ${available} rows available.`
  )
})

function toggleSort(key: string) {
  if (sortKey.value === key) {
    sortAsc.value = !sortAsc.value
  } else {
    sortKey.value = key
    sortAsc.value = true
  }
}

async function exportData(kind: 'xlsx' | 'csv') {
  exportOpen.value = false
  const headers = props.columns.map((c) => c.label)
  const data = visible.value.map((row) => props.columns.map((c) => cellText(c, row)))
  if (kind === 'csv') {
    const line = (cells: string[]) => cells.map((v) => '"' + v.replace(/"/g, '""') + '"').join(',')
    // BOM so Excel opens the CSV as UTF-8
    const csv = '﻿' + [line(headers), ...data.map(line)].join('\r\n')
    await saveFile(new Blob([csv], { type: 'text/csv' }), `${props.exportName}.csv`, 'CSV file')
  } else {
    const bytes = makeXlsx(props.exportName, headers, data)
    await saveFile(
      new Blob([bytes], {
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      }),
      `${props.exportName}.xlsx`,
      'Excel workbook',
    )
  }
}
</script>

<template>
  <div>
    <div class="toolbar">
      <input v-model="search" type="search" class="search" placeholder="Search…" spellcheck="false" />
      <button
        v-if="activeFilterCount > 0"
        class="tool"
        title="Remove all column filters"
        @click="clearAllFilters"
      >
        <AppIcon name="filter" />
        Clear filters
        <span class="badge-count">{{ activeFilterCount }}</span>
      </button>
      <div class="export-wrap" @mousedown.stop>
        <button class="tool" @click="exportOpen = !exportOpen">
          <AppIcon name="download" />
          Export
        </button>
        <div v-if="exportOpen" class="menu">
          <button class="menu-item" @click="exportData('xlsx')">Excel (.xlsx)</button>
          <button class="menu-item" @click="exportData('csv')">CSV</button>
        </div>
      </div>
      <span class="spacer" />
      <slot name="toolbar" />
    </div>

    <div class="table-wrap">
      <table class="grid">
        <thead>
          <tr>
            <th
              v-for="col in columns"
              :key="col.key"
              :style="col.width ? { width: col.width } : undefined"
            >
              <div class="th-inner">
                <button class="sort" @click="toggleSort(col.key)">
                  {{ col.label }}
                  <span class="arrow">{{ sortKey === col.key ? (sortAsc ? '▲' : '▼') : '' }}</span>
                </button>
                <button
                  class="funnel"
                  :class="{ 'funnel-active': !!filters[col.key] }"
                  :title="filters[col.key] ? `${col.label}: filtered` : `Filter ${col.label}`"
                  @mousedown.stop
                  @click.stop="openFilterMenu(col, $event)"
                >
                  <AppIcon name="filter" />
                </button>
              </div>
            </th>
            <th v-if="hasActions">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in paged" :key="rowKey(row)" :class="rowClass?.(row)">
            <td v-for="col in columns" :key="col.key">
              <slot :name="`cell-${col.key}`" :row="row">{{ cellText(col, row) }}</slot>
            </td>
            <td v-if="hasActions" class="actions">
              <slot name="actions" :row="row" />
            </td>
          </tr>
          <tr v-if="visible.length === 0">
            <td :colspan="columns.length + (hasActions ? 1 : 0)" class="empty">No rows match.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="pagination">
      <label class="page-size">
        Rows per page
        <select v-model.number="pageSize">
          <option :value="15">15</option>
          <option :value="25">25</option>
          <option :value="50">50</option>
          <option :value="0">All</option>
        </select>
      </label>
      <p class="status-line">{{ statusText }}</p>
      <span class="spacer" />
      <div class="pager">
        <button class="page-btn" :disabled="page <= 1" title="First page" @click="page = 1">
          <AppIcon name="minimize" />
        </button>
        <button class="page-btn" :disabled="page <= 1" title="Previous page" @click="page--">
          <AppIcon name="prev" />
        </button>
        <span class="page-num">Page {{ page }} of {{ pageCount }}</span>
        <button class="page-btn" :disabled="page >= pageCount" title="Next page" @click="page++">
          <AppIcon name="next" />
        </button>
        <button
          class="page-btn"
          :disabled="page >= pageCount"
          title="Last page"
          @click="page = pageCount"
        >
          <AppIcon name="expand" />
        </button>
      </div>
    </div>

    <!-- Excel-style column filter dropdown (teleported so the table's
         horizontal-scroll container can't clip it) -->
    <Teleport to="body">
      <div
        v-if="filterMenu"
        class="filter-menu"
        :style="{ top: filterMenu.top + 'px', left: filterMenu.left + 'px' }"
        @mousedown.stop
      >
        <button class="menu-sort" @click="sortFromMenu(true)">
          <span class="sort-glyph">A↓Z</span> Sort A to Z
        </button>
        <button class="menu-sort" @click="sortFromMenu(false)">
          <span class="sort-glyph">Z↓A</span> Sort Z to A
        </button>
        <div class="menu-sep" />
        <!-- Condition filter (text/number/date ops per column type) -->
        <div class="cond">
          <select v-model="condOp" class="cond-op">
            <option value="">(No condition)</option>
            <option v-for="o in condOps" :key="o.op" :value="o.op">{{ o.label }}</option>
          </select>
          <template v-if="condOp !== ''">
            <div class="cond-vals">
              <input
                v-model="condA"
                :type="condInputType"
                class="cond-val"
                :placeholder="condOp === 'between' ? 'From' : 'Value'"
                @keydown.enter.prevent="applyCondition"
              />
              <input
                v-if="condOp === 'between'"
                v-model="condB"
                :type="condInputType"
                class="cond-val"
                placeholder="To"
                @keydown.enter.prevent="applyCondition"
              />
              <button class="cond-apply" @click="applyCondition">Apply</button>
            </div>
          </template>
        </div>
        <div class="menu-sep" />
        <input
          v-model="menuSearch"
          type="search"
          class="menu-search"
          placeholder="Search values… (Enter applies)"
          spellcheck="false"
          @keydown.enter.prevent="applySearchMatches"
        />
        <label class="val select-all">
          <input
            type="checkbox"
            :checked="allListedSelected"
            :indeterminate="someListedSelected"
            @change="toggleAllListed"
          />
          <span>(Select all)</span>
        </label>
        <div class="vals">
          <label v-for="v in listedValues" :key="v" class="val">
            <input type="checkbox" :checked="isSelected(v)" @change="toggleValue(v)" />
            <span>{{ v === '' ? '(Blanks)' : v }}</span>
          </label>
          <p v-if="listedValues.length === 0" class="no-vals">No values match</p>
        </div>
        <div class="menu-foot">
          <button
            class="foot-link"
            :disabled="!filters[filterMenu.key]"
            @click="clearFilter(filterMenu.key)"
          >
            Clear filter
          </button>
          <button class="foot-link" @click="filterMenu = null">Close</button>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 14px;
}

.search {
  width: 300px;
  padding: 8px 12px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
}

.search:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}

.tool {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: var(--color-surface);
  color: var(--color-text);
  cursor: pointer;
}

.tool:hover,
.tool.active {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.badge-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 18px;
  height: 18px;
  padding: 0 5px;
  border-radius: 9px;
  background: var(--color-primary);
  color: #fff;
  font-size: 0.75rem;
  font-weight: 700;
}

.export-wrap {
  position: relative;
}

.menu {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  z-index: 50;
  min-width: 150px;
  padding: 4px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.12);
}

.menu-item {
  display: block;
  width: 100%;
  padding: 8px 12px;
  border: none;
  border-radius: 5px;
  background: none;
  text-align: left;
  color: var(--color-text);
  cursor: pointer;
}

.menu-item:hover {
  background: var(--color-bg);
}

.spacer {
  flex: 1;
}

.table-wrap {
  overflow-x: auto;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 10px;
}

.grid {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.95rem;
}

.grid th {
  padding: 0;
  border-bottom: 2px solid var(--color-border);
  text-align: left;
  white-space: nowrap;
}

.th-inner {
  display: flex;
  align-items: center;
}

.sort {
  display: flex;
  align-items: center;
  gap: 6px;
  flex: 1;
  min-width: 0;
  padding: 10px 4px 10px 14px;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: var(--color-text-muted);
}

.sort:hover {
  color: var(--color-primary);
}

.arrow {
  font-size: 0.7rem;
}

.funnel {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  margin-right: 6px;
  border: none;
  border-radius: 5px;
  background: none;
  color: var(--color-text-muted);
  opacity: 0.55;
  cursor: pointer;
}

.funnel:hover {
  opacity: 1;
  color: var(--color-primary);
  background: var(--color-bg);
}

.funnel-active {
  opacity: 1;
  color: var(--color-primary);
}

.funnel :deep(.icon) {
  width: 14px;
  height: 14px;
}

.filter-menu {
  position: fixed;
  z-index: 200;
  width: 250px;
  padding: 8px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  box-shadow: 0 8px 22px rgba(0, 0, 0, 0.22);
}

.menu-sort {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  padding: 6px 8px;
  border: none;
  border-radius: 5px;
  background: none;
  color: var(--color-text);
  font-size: 0.9rem;
  text-align: left;
  cursor: pointer;
}

.menu-sort:hover {
  background: var(--color-bg);
}

.sort-glyph {
  font-family: ui-monospace, Consolas, monospace;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--color-text-muted);
}

.menu-sep {
  margin: 6px 0;
  border-top: 1px solid var(--color-border);
}

.cond {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.cond-op {
  width: 100%;
  padding: 5px 8px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: var(--color-surface);
  color: var(--color-text);
  font-size: 0.85rem;
}

.cond-vals {
  display: flex;
  gap: 6px;
}

.cond-val {
  flex: 1;
  min-width: 0;
  padding: 5px 8px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  font-size: 0.85rem;
}

.cond-val:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}

.cond-apply {
  padding: 5px 10px;
  border: none;
  border-radius: 6px;
  background: var(--color-primary);
  color: #fff;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
}

.cond-apply:hover {
  background: var(--color-primary-hover);
}

.menu-search {
  width: 100%;
  margin-bottom: 6px;
  padding: 6px 9px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  font-size: 0.85rem;
}

.menu-search:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}

.val {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 6px;
  border-radius: 4px;
  font-size: 0.9rem;
  cursor: pointer;
}

.val:hover {
  background: var(--color-bg);
}

.select-all {
  font-weight: 600;
  border-bottom: 1px solid var(--color-border);
  border-radius: 0;
  margin-bottom: 2px;
  padding-bottom: 6px;
}

.vals {
  max-height: 220px;
  overflow-y: auto;
}

.no-vals {
  margin: 6px;
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

.menu-foot {
  display: flex;
  justify-content: space-between;
  margin-top: 6px;
  padding-top: 6px;
  border-top: 1px solid var(--color-border);
}

.foot-link {
  border: none;
  background: none;
  padding: 3px 6px;
  color: var(--color-primary);
  font-size: 0.85rem;
  cursor: pointer;
}

.foot-link:hover:enabled {
  text-decoration: underline;
}

.foot-link:disabled {
  color: var(--color-text-muted);
  cursor: default;
}

.grid th:last-child:not(:first-child) {
  padding: 10px 14px;
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: var(--color-text-muted);
}

.grid td {
  padding: 9px 14px;
  border-bottom: 1px solid var(--color-border);
}

.grid tbody tr:last-child td {
  border-bottom: none;
}

.grid tbody tr:hover {
  background: var(--color-bg);
}

/* Rows the caller marks as dimmed (e.g. inactive records) */
.grid tbody tr.dim td {
  color: var(--color-text-muted);
}

.actions {
  white-space: nowrap;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  padding: 24px;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 18px;
  margin: 10px 2px;
}

.page-size {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: var(--color-text-muted);
  white-space: nowrap;
}

.page-size select {
  padding: 4px 6px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: var(--color-surface);
  font-size: 0.85rem;
}

.status-line {
  margin: 0;
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

.pager {
  display: flex;
  align-items: center;
  gap: 4px;
}

.page-num {
  padding: 0 8px;
  font-size: 0.85rem;
  color: var(--color-text);
  white-space: nowrap;
}

.page-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 5px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: var(--color-surface);
  color: var(--color-text);
  cursor: pointer;
}

.page-btn:hover:enabled {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.page-btn:disabled {
  opacity: 0.45;
  cursor: default;
}
</style>
