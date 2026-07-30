<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { listDictionaries, setDictionaryStatus, type Dictionary } from '@/api/dictionaries'
import ToggleSwitch from '@/components/ToggleSwitch.vue'
import DictionaryModal from '@/components/DictionaryModal.vue'
import DataGrid, { type GridColumn } from '@/components/DataGrid.vue'

// Web version of DCTMSTD1 — Dictionary Master List. The green screen's
// 6=Fields option is the Fields action (and clicking the name), which
// routes to the dictionary detail page.
const router = useRouter()

const dictionaries = ref<Dictionary[]>([])
const loading = ref(true)
const error = ref('')
const showInactive = ref(false)

const modal = ref<{ mode: 'add' | 'update' | 'copy' | 'view'; dictionary?: Dictionary } | null>(
  null,
)

const columns: GridColumn<Dictionary>[] = [
  { key: 'dictionary', label: 'Dictionary', width: '140px' },
  { key: 'description', label: 'Description' },
  { key: 'note', label: 'Note' },
  { key: 'status', label: 'Status', width: '120px', text: (d) => (d.active ? 'Active' : 'Inactive') },
]

const rows = computed(() =>
  showInactive.value ? dictionaries.value : dictionaries.value.filter((d) => d.active),
)

async function load() {
  loading.value = true
  error.value = ''
  try {
    dictionaries.value = await listDictionaries()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load dictionaries'
  } finally {
    loading.value = false
  }
}

async function setStatus(d: Dictionary, active: boolean) {
  error.value = ''
  try {
    await setDictionaryStatus(d.dictionary, active)
    await load()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Status change failed'
  }
}

function openFields(d: Dictionary) {
  router.push({ name: 'dictionary-detail', params: { name: d.dictionary } })
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

    <p v-if="loading" class="loading">Loading dictionaries…</p>

    <DataGrid
      v-else
      :columns="columns"
      :rows="rows"
      :total-rows="dictionaries.length"
      :row-key="(d) => d.dictionary"
      export-name="dictionaries"
      has-actions
      :row-class="(d) => (d.active ? '' : 'dim')"
    >
      <template #toolbar>
        <ToggleSwitch v-model="showInactive" label="Show inactive" />
        <button class="add" @click="modal = { mode: 'add' }">Add dictionary</button>
      </template>

      <template #cell-dictionary="{ row }">
        <button class="code link-code" title="Open fields" @click="openFields(row)">
          {{ row.dictionary }}
        </button>
      </template>

      <template #actions="{ row }">
        <button class="link strong" @click="openFields(row)">Fields</button>
        <button class="link" @click="modal = { mode: 'view', dictionary: row }">View</button>
        <button class="link" @click="modal = { mode: 'update', dictionary: row }">Update</button>
        <button class="link" @click="modal = { mode: 'copy', dictionary: row }">Copy</button>
        <button v-if="row.active" class="link danger" @click="setStatus(row, false)">
          Deactivate
        </button>
        <button v-else class="link" @click="setStatus(row, true)">Reactivate</button>
      </template>
    </DataGrid>

    <DictionaryModal
      v-if="modal"
      :mode="modal.mode"
      :dictionary="modal.dictionary"
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

.link-code {
  border: none;
  background: none;
  padding: 0;
  color: var(--color-primary);
  cursor: pointer;
}

.link-code:hover {
  text-decoration: underline;
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

.link.strong {
  font-weight: 700;
}

.link.danger {
  color: var(--color-error);
}
</style>
