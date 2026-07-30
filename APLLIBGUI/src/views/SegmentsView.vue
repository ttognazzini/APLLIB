<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { listSegments, setSegmentStatus, type Segment } from '@/api/segments'
import ToggleSwitch from '@/components/ToggleSwitch.vue'
import SegmentModal from '@/components/SegmentModal.vue'
import DataGrid, { type GridColumn } from '@/components/DataGrid.vue'

// Web version of DCTSEGD1 — Dictionary Segment Master. Segments are never
// deleted, only deactivated; "Show inactive" replaces the F11 toggle.
// Search/sort/filter/export come from the standard DataGrid (RULES.md U4).
const segments = ref<Segment[]>([])
const loading = ref(true)
const error = ref('')

const showInactive = ref(false)

const modal = ref<{ mode: 'add' | 'update' | 'copy' | 'view'; segment?: Segment } | null>(null)

const columns: GridColumn<Segment>[] = [
  { key: 'segment', label: 'Segment', width: '110px' },
  { key: 'description', label: 'Description' },
  { key: 'status', label: 'Status', width: '120px', text: (s) => (s.active ? 'Active' : 'Inactive') },
  { key: 'conflict', label: 'Conflict', width: '110px', text: (s) => (s.conflict ? 'Yes' : 'No') },
]

const rows = computed(() =>
  showInactive.value ? segments.value : segments.value.filter((s) => s.active),
)

async function load() {
  loading.value = true
  error.value = ''
  try {
    segments.value = await listSegments()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load segments'
  } finally {
    loading.value = false
  }
}

async function setStatus(seg: Segment, active: boolean) {
  error.value = ''
  try {
    await setSegmentStatus(seg.segment, active)
    await load()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Status change failed'
  }
}

function onSaved() {
  modal.value = null
  load()
}

onMounted(load)
</script>

<template>
  <div>
    <div v-if="error" class="error">{{ error }}</div>

    <p v-if="loading" class="loading">Loading segments…</p>

    <DataGrid
      v-else
      :columns="columns"
      :rows="rows"
      :total-rows="segments.length"
      :row-key="(s) => s.segment"
      export-name="segments"
      has-actions
      :row-class="(s) => (s.active ? '' : 'dim')"
    >
      <template #toolbar>
        <ToggleSwitch v-model="showInactive" label="Show inactive" />
        <button class="add" @click="modal = { mode: 'add' }">Add segment</button>
      </template>

      <template #cell-segment="{ row }">
        <span class="code">{{ row.segment }}</span>
      </template>

      <template #cell-status="{ row }">
        <span class="badge" :class="row.active ? 'badge-active' : 'badge-inactive'">
          {{ row.active ? 'Active' : 'Inactive' }}
        </span>
      </template>

      <template #actions="{ row }">
        <button class="link" @click="modal = { mode: 'view', segment: row }">View</button>
        <button class="link" @click="modal = { mode: 'update', segment: row }">Update</button>
        <button class="link" @click="modal = { mode: 'copy', segment: row }">Copy</button>
        <button v-if="row.active" class="link danger" @click="setStatus(row, false)">
          Deactivate
        </button>
        <button v-else class="link" @click="setStatus(row, true)">Reactivate</button>
      </template>
    </DataGrid>

    <SegmentModal
      v-if="modal"
      :mode="modal.mode"
      :segment="modal.segment"
      @close="modal = null"
      @saved="onSaved"
    />
  </div>
</template>

<style scoped>
.error {
  margin-bottom: 14px;
  padding: 10px 12px;
  border-radius: 6px;
  background: var(--color-error-bg);
  color: var(--color-error);
}

.loading {
  color: var(--color-text-muted);
}

.add {
  padding: 9px 16px;
  border: none;
  border-radius: 6px;
  background: var(--color-primary);
  color: #fff;
  font-weight: 600;
  cursor: pointer;
}

.add:hover {
  background: var(--color-primary-hover);
}

.code {
  font-family: ui-monospace, Consolas, monospace;
  font-weight: 600;
  letter-spacing: 0.1em;
}

.badge {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 10px;
  font-size: 0.8rem;
  font-weight: 600;
}

.badge-active {
  background: var(--color-success-bg);
  color: var(--color-success-fg);
}

.badge-inactive {
  background: var(--color-border);
  color: var(--color-text-muted);
}

.link {
  border: none;
  background: none;
  padding: 2px 6px;
  color: var(--color-primary);
  cursor: pointer;
  font-size: 0.9rem;
}

.link:hover {
  text-decoration: underline;
}

.link.danger {
  color: var(--color-error);
}
</style>
