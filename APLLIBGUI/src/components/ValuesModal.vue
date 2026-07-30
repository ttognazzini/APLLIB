<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import {
  addValue,
  listValues,
  setValueStatus,
  updateValue,
  type DictionaryField,
  type EnumValue,
} from '@/api/dictionaries'
import AppIcon from './AppIcon.vue'
import ToggleSwitch from './ToggleSwitch.vue'
import DataGrid, { type GridColumn } from './DataGrid.vue'

// Enumerated values for one field — the web version of DCTVALD1/D2
// (green screen option 9). Add/update is inline at the top so no second
// modal layer is ever needed.
const props = defineProps<{
  dictionary: string
  field: DictionaryField
}>()

const emit = defineEmits<{ close: [] }>()

const values = ref<EnumValue[]>([])
const loading = ref(true)
const error = ref('')
const showInactive = ref(false)
const busy = ref(false)
/** null = adding; otherwise the key of the value being updated */
const editing = ref<string | null>(null)

const form = reactive<EnumValue>({ value: '', description: '', active: true })

const columns: GridColumn<EnumValue>[] = [
  { key: 'value', label: 'Value', width: '130px' },
  { key: 'description', label: 'Description' },
  { key: 'status', label: 'Status', width: '110px', text: (v) => (v.active ? 'Active' : 'Inactive') },
]

const rows = computed(() =>
  showInactive.value ? values.value : values.value.filter((v) => v.active),
)

async function load() {
  loading.value = true
  error.value = ''
  try {
    values.value = await listValues(props.dictionary, props.field.field)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load values'
  } finally {
    loading.value = false
  }
}

function startAdd() {
  editing.value = null
  form.value = ''
  form.description = ''
}

function startEdit(v: EnumValue) {
  editing.value = v.value
  form.value = v.value
  form.description = v.description
}

async function save() {
  error.value = ''
  form.value = form.value.trim()
  form.description = form.description.trim()
  if (form.value === '') {
    error.value = 'Value is required'
    return
  }
  if (form.description === '') {
    error.value = 'Description is required'
    return
  }
  busy.value = true
  try {
    if (editing.value !== null) {
      await updateValue(props.dictionary, props.field.field, { ...form })
    } else {
      await addValue(props.dictionary, props.field.field, { ...form })
    }
    startAdd()
    await load()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Save failed'
  } finally {
    busy.value = false
  }
}

async function setStatus(v: EnumValue, active: boolean) {
  error.value = ''
  try {
    await setValueStatus(props.dictionary, props.field.field, v.value, active)
    await load()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Status change failed'
  }
}

onMounted(load)
</script>

<template>
  <Teleport to="body">
    <div class="overlay" @click.self="emit('close')">
      <div class="modal" role="dialog" aria-modal="true">
        <div class="modal-head">
          <h3 class="modal-title">
            Enumerated values — <span class="code">{{ field.field }}</span>
            <span class="sub">{{ field.columnText }}</span>
          </h3>
          <button type="button" class="close" title="Close" @click="emit('close')">
            <AppIcon name="close" />
          </button>
        </div>

        <div v-if="error" class="error">{{ error }}</div>

        <!-- Inline add/update — the DCTVALD2 detail, without a second modal -->
        <form class="entry" @submit.prevent="save">
          <label class="field">
            <span>Value</span>
            <input
              v-model="form.value"
              type="text"
              maxlength="10"
              class="code"
              :disabled="editing !== null"
              spellcheck="false"
            />
          </label>
          <label class="field grow">
            <span>Description</span>
            <input v-model="form.description" type="text" maxlength="40" />
          </label>
          <button type="submit" class="primary" :disabled="busy">
            {{ busy ? 'Saving…' : editing !== null ? 'Save' : 'Add' }}
          </button>
          <button v-if="editing !== null" type="button" class="secondary" @click="startAdd">
            Cancel
          </button>
        </form>

        <p v-if="loading" class="loading">Loading values…</p>

        <DataGrid
          v-else
          :columns="columns"
          :rows="rows"
          :total-rows="values.length"
          :row-key="(v) => v.value"
          :export-name="`values-${dictionary}-${field.field}`"
          has-actions
          :row-class="(v) => (v.active ? '' : 'dim')"
        >
          <template #toolbar>
            <ToggleSwitch v-model="showInactive" label="Show inactive" />
          </template>
          <template #cell-value="{ row }">
            <span class="code">{{ row.value }}</span>
          </template>
          <template #actions="{ row }">
            <button class="link" @click="startEdit(row)">Update</button>
            <button v-if="row.active" class="link danger" @click="setStatus(row, false)">
              Deactivate
            </button>
            <button v-else class="link" @click="setStatus(row, true)">Reactivate</button>
          </template>
        </DataGrid>

        <div class="actions">
          <button type="button" class="secondary" @click="emit('close')">Close</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.45);
  z-index: 100;
}

.modal {
  width: min(760px, calc(100vw - 40px));
  max-height: calc(100vh - 60px);
  overflow-y: auto;
  padding: 24px 28px;
  background: var(--color-surface);
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
}

.modal-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.modal-title {
  margin: 0;
  font-size: 1.1rem;
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.sub {
  font-size: 0.85rem;
  font-weight: 400;
  color: var(--color-text-muted);
}

.close {
  display: flex;
  padding: 4px;
  border: none;
  border-radius: 6px;
  background: none;
  color: var(--color-text-muted);
  cursor: pointer;
}

.close:hover {
  color: var(--color-text);
  background: var(--color-bg);
}

.error {
  margin-bottom: 14px;
  padding: 10px 12px;
  border-radius: 6px;
  background: var(--color-error-bg);
  color: var(--color-error);
  font-size: 0.9rem;
}

.entry {
  display: flex;
  align-items: flex-end;
  gap: 12px;
  padding: 12px 14px;
  margin-bottom: 16px;
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: 8px;
}

.field {
  display: block;
}

.field.grow {
  flex: 1;
}

.field span {
  display: block;
  margin-bottom: 4px;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text-muted);
}

.field input {
  width: 100%;
  padding: 7px 10px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: var(--color-surface);
  color: var(--color-text);
}

.field input:disabled {
  color: var(--color-text-muted);
}

.field input:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}

.code {
  font-family: ui-monospace, Consolas, monospace;
  font-weight: 600;
}

.loading {
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

.primary {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  background: var(--color-primary);
  color: #fff;
  font-weight: 600;
  cursor: pointer;
}

.primary:hover:enabled {
  background: var(--color-primary-hover);
}

.primary:disabled {
  opacity: 0.7;
  cursor: default;
}

.secondary {
  padding: 8px 16px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: none;
  color: var(--color-text);
  cursor: pointer;
}

.secondary:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
</style>
