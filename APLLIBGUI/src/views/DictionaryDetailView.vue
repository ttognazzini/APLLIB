<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import {
  formatFieldType,
  listDictionaries,
  listFields,
  listFieldTypes,
  setFieldStatus,
  type Dictionary,
  type DictionaryField,
  type FieldType,
} from '@/api/dictionaries'
import ToggleSwitch from '@/components/ToggleSwitch.vue'
import DataGrid, { type GridColumn } from '@/components/DataGrid.vue'
import DictionaryModal from '@/components/DictionaryModal.vue'
import FieldModal from '@/components/FieldModal.vue'
import ValuesModal from '@/components/ValuesModal.vue'

// Web version of DCTFLDD1 — the fields of one dictionary, on a routed
// page (green screen option 6=Fields). One grid replaces the F6 view
// toggle; the field form is a modal; enumerated values open in their own
// modal — automatically after saving a field marked enumerated.
const route = useRoute()
const name = computed(() => String(route.params.name ?? '').toUpperCase())

const dictionary = ref<Dictionary | null>(null)
const fields = ref<DictionaryField[]>([])
const types = ref<FieldType[]>([])
const loading = ref(true)
const error = ref('')
const showInactive = ref(false)

const dictModal = ref(false)
const fieldModal = ref<{ mode: 'add' | 'update' | 'copy' | 'view'; field?: DictionaryField } | null>(
  null,
)
const valuesFor = ref<DictionaryField | null>(null)

const typesMap = computed(() => new Map(types.value.map((t) => [t.fieldType, t])))

const columns = computed<GridColumn<DictionaryField>[]>(() => [
  { key: 'field', label: 'Field', width: '120px' },
  { key: 'columnText', label: 'Column Text' },
  { key: 'type', label: 'Type', text: (f) => formatFieldType(f, typesMap.value) },
  { key: 'enumerated', label: 'Enum', width: '80px', text: (f) => (f.enumerated ? 'Yes' : 'No') },
  { key: 'allowNull', label: 'Null', width: '80px', text: (f) => (f.allowNull ? 'Yes' : 'No') },
  { key: 'defaultValue', label: 'Default', width: '120px' },
  { key: 'status', label: 'Status', width: '110px', text: (f) => (f.active ? 'Active' : 'Inactive') },
])

const rows = computed(() =>
  showInactive.value ? fields.value : fields.value.filter((f) => f.active),
)

async function load() {
  loading.value = true
  error.value = ''
  try {
    const [dictionaries, fieldRows, typeRows] = await Promise.all([
      listDictionaries(),
      listFields(name.value),
      listFieldTypes(),
    ])
    dictionary.value = dictionaries.find((d) => d.dictionary === name.value) ?? null
    fields.value = fieldRows
    types.value = typeRows
    if (!dictionary.value) {
      error.value = `Dictionary ${name.value} not found`
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load dictionary'
  } finally {
    loading.value = false
  }
}

async function reloadFields() {
  try {
    fields.value = await listFields(name.value)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to reload fields'
  }
}

async function setStatus(f: DictionaryField, active: boolean) {
  error.value = ''
  try {
    await setFieldStatus(name.value, f.field, active)
    await reloadFields()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Status change failed'
  }
}

// After saving a field marked enumerated, open its values automatically
// (replaces the green screen's separate option 9 trip).
async function onFieldSaved(saved: DictionaryField) {
  const wasAddOrUpdate = fieldModal.value?.mode !== 'view'
  fieldModal.value = null
  await reloadFields()
  if (wasAddOrUpdate && saved.enumerated) {
    const row = fields.value.find((f) => f.field === saved.field)
    valuesFor.value = row ?? saved
  }
}

async function onDictSaved() {
  dictModal.value = false
  await load()
}

onMounted(load)
</script>

<template>
  <div>
    <RouterLink class="back" :to="{ name: 'dictionaries' }">‹ Dictionaries</RouterLink>

    <div v-if="error" class="error">{{ error }}</div>
    <p v-if="loading" class="loading">Loading dictionary…</p>

    <template v-else-if="dictionary">
      <div class="head-card">
        <div class="head-main">
          <h1 class="dict-name">
            <span class="code">{{ dictionary.dictionary }}</span>
            {{ dictionary.description }}
          </h1>
          <p v-if="dictionary.note" class="note">{{ dictionary.note }}</p>
        </div>
        <span class="badge" :class="dictionary.active ? 'badge-active' : 'badge-inactive'">
          {{ dictionary.active ? 'Active' : 'Inactive' }}
        </span>
        <button class="link" @click="dictModal = true">Update</button>
      </div>

      <DataGrid
        :columns="columns"
        :rows="rows"
        :total-rows="fields.length"
        :row-key="(f) => f.field"
        :export-name="`fields-${dictionary.dictionary}`"
        has-actions
        :row-class="(f) => (f.active ? '' : 'dim')"
      >
        <template #toolbar>
          <ToggleSwitch v-model="showInactive" label="Show inactive" />
          <button class="add" @click="fieldModal = { mode: 'add' }">Add field</button>
        </template>

        <template #cell-field="{ row }">
          <span class="code">{{ row.field }}</span>
        </template>

        <template #cell-status="{ row }">
          <span class="badge" :class="row.active ? 'badge-active' : 'badge-inactive'">
            {{ row.active ? 'Active' : 'Inactive' }}
          </span>
        </template>

        <template #actions="{ row }">
          <button class="link" @click="fieldModal = { mode: 'view', field: row }">View</button>
          <button class="link" @click="fieldModal = { mode: 'update', field: row }">Update</button>
          <button class="link" @click="fieldModal = { mode: 'copy', field: row }">Copy</button>
          <button v-if="row.enumerated" class="link" @click="valuesFor = row">Values</button>
          <button v-if="row.active" class="link danger" @click="setStatus(row, false)">
            Deactivate
          </button>
          <button v-else class="link" @click="setStatus(row, true)">Reactivate</button>
        </template>
      </DataGrid>

      <DictionaryModal
        v-if="dictModal"
        mode="update"
        :dictionary="dictionary"
        @close="dictModal = false"
        @saved="onDictSaved"
      />

      <FieldModal
        v-if="fieldModal"
        :mode="fieldModal.mode"
        :dictionary="dictionary.dictionary"
        :types="types"
        :field="fieldModal.field"
        @close="fieldModal = null"
        @saved="onFieldSaved"
      />

      <ValuesModal
        v-if="valuesFor"
        :dictionary="dictionary.dictionary"
        :field="valuesFor"
        @close="valuesFor = null"
      />
    </template>
  </div>
</template>

<style scoped>
.back {
  display: inline-block;
  margin-bottom: 12px;
  color: var(--color-primary);
  text-decoration: none;
  font-size: 0.9rem;
}

.back:hover {
  text-decoration: underline;
}

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

.head-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 18px;
  margin-bottom: 16px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 10px;
}

.head-main {
  flex: 1;
  min-width: 0;
}

.dict-name {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 600;
}

.dict-name .code {
  margin-right: 10px;
  color: var(--color-primary);
}

.note {
  margin: 4px 0 0;
  font-size: 0.9rem;
  color: var(--color-text-muted);
}

.code {
  font-family: ui-monospace, Consolas, monospace;
  font-weight: 600;
  letter-spacing: 0.06em;
}

.badge {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 10px;
  font-size: 0.8rem;
  font-weight: 600;
  white-space: nowrap;
}

.badge-active {
  background: var(--color-success-bg);
  color: var(--color-success-fg);
}

.badge-inactive {
  background: var(--color-border);
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
