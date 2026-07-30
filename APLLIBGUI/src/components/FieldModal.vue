<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { addField, updateField, type DictionaryField, type FieldType } from '@/api/dictionaries'
import AppIcon from './AppIcon.vue'
import AuditInfo from './AuditInfo.vue'
import LookupField from './LookupField.vue'

// Detail form for one dictionary field — the web version of DCTFLDD2.
// The Type lookup (LookupField = the F4 pattern, RULES.md U6) drives the
// rest of the form: FLDTYP rules enable/require/limit Length, Scale and
// Allocation live.
const props = defineProps<{
  mode: 'add' | 'update' | 'copy' | 'view'
  dictionary: string
  types: FieldType[]
  field?: DictionaryField
}>()

const emit = defineEmits<{ close: []; saved: [field: DictionaryField] }>()

const titles = {
  add: 'Add field',
  update: 'Update field',
  copy: 'Copy field',
  view: 'View field',
} as const

const readonly = props.mode === 'view'
const keyLocked = props.mode === 'update' || props.mode === 'view'

const form = reactive<DictionaryField>({
  field: props.mode === 'copy' ? '' : (props.field?.field ?? ''),
  fieldSql: props.field?.fieldSql ?? '',
  description: props.field?.description ?? '',
  columnText: props.field?.columnText ?? '',
  heading1: props.field?.heading1 ?? '',
  heading2: props.field?.heading2 ?? '',
  heading3: props.field?.heading3 ?? '',
  type: props.field?.type ?? '',
  length: props.field?.length ?? 0,
  scale: props.field?.scale ?? 0,
  allocation: props.field?.allocation ?? 0,
  projectNumber: props.field?.projectNumber ?? '',
  promptText: props.field?.promptText ?? '',
  allowNull: props.field?.allowNull ?? false,
  defaultValue: props.field?.defaultValue ?? '',
  enumerated: props.field?.enumerated ?? false,
  active: props.field?.active ?? true,
  created: props.field?.created ?? '',
  maintained: props.field?.maintained ?? '',
})

const error = ref('')
const busy = ref(false)

const typeOptions = computed(() =>
  props.types.map((t) => ({ value: t.fieldType, label: t.description })),
)

/** Rules for the currently selected type (undefined until it's valid) */
const rules = computed(() =>
  props.types.find((t) => t.fieldType === form.type.trim().toUpperCase()),
)

const forcedLengths = computed(() =>
  (rules.value?.forceLengths ?? []).filter((n) => n > 0),
)

// When the type changes, drop whatever the new type doesn't allow.
function onTypeSelected() {
  const r = rules.value
  if (!r) {
    return
  }
  if (!r.allowLength) {
    form.length = 0
  }
  if (!r.allowDecimals) {
    form.scale = 0
  }
  if (!r.allowAllocation) {
    form.allocation = 0
  }
  if (r.forceLength && !forcedLengths.value.includes(form.length)) {
    form.length = forcedLengths.value[0] ?? 0
  }
}

function validate(): string {
  form.field = form.field.trim().toUpperCase()
  if (!/^[A-Z][A-Z0-9]{0,9}$/.test(form.field)) {
    return 'Field name must be 1 to 10 characters, starting with a letter'
  }
  form.columnText = form.columnText.trim()
  if (form.columnText === '') {
    return 'Column text is required'
  }
  form.type = form.type.trim().toUpperCase()
  const r = rules.value
  if (!r) {
    return 'Select a valid field type'
  }
  if (r.requireLength && !(form.length > 0)) {
    return `Length is required for type ${r.fieldType}`
  }
  if (!r.allowLength) {
    form.length = 0
  }
  if (r.forceLength && !forcedLengths.value.includes(form.length)) {
    return `Length for ${r.fieldType} must be one of: ${forcedLengths.value.join(', ')}`
  }
  if (r.maxLength > 0 && form.length > r.maxLength) {
    return `Length exceeds the maximum of ${r.maxLength} for type ${r.fieldType}`
  }
  if (!r.allowDecimals) {
    form.scale = 0
  } else if (form.scale > form.length) {
    return 'Decimal positions cannot exceed the length'
  }
  if (!r.allowAllocation) {
    form.allocation = 0
  }
  if (r.requireAllocation && !(form.allocation > 0)) {
    return `Allocation is required for type ${r.fieldType}`
  }
  return ''
}

async function save() {
  error.value = validate()
  if (error.value !== '') {
    return
  }
  busy.value = true
  try {
    if (props.mode === 'update') {
      await updateField(props.dictionary, { ...form })
    } else {
      await addField(props.dictionary, { ...form })
    }
    emit('saved', { ...form })
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Save failed'
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <div class="overlay" @click.self="emit('close')">
      <form class="modal" role="dialog" aria-modal="true" @submit.prevent="save">
        <div class="modal-head">
          <h3 class="modal-title">{{ titles[mode] }} — {{ dictionary }}</h3>
          <button type="button" class="close" title="Close" @click="emit('close')">
            <AppIcon name="close" />
          </button>
        </div>

        <div v-if="error" class="error">{{ error }}</div>

        <div class="grid2">
          <label class="field">
            <span>Field</span>
            <input
              v-model="form.field"
              type="text"
              maxlength="10"
              class="upper code"
              :disabled="keyLocked"
              spellcheck="false"
              required
            />
          </label>
          <label class="field">
            <span>Field-SQL (long name)</span>
            <input v-model="form.fieldSql" type="text" maxlength="30" :disabled="readonly" spellcheck="false" />
          </label>
        </div>

        <label class="field">
          <span>Description</span>
          <input v-model="form.description" type="text" maxlength="40" :disabled="readonly" />
        </label>

        <label class="field">
          <span>Column text</span>
          <input v-model="form.columnText" type="text" maxlength="50" :disabled="readonly" required />
        </label>

        <div class="field">
          <span class="lbl">Column headings</span>
          <div class="grid3">
            <input v-model="form.heading1" type="text" maxlength="20" :disabled="readonly" />
            <input v-model="form.heading2" type="text" maxlength="20" :disabled="readonly" />
            <input v-model="form.heading3" type="text" maxlength="20" :disabled="readonly" />
          </div>
        </div>

        <div class="field">
          <span class="lbl">Type</span>
          <LookupField
            v-model="form.type"
            :options="typeOptions"
            :disabled="readonly"
            placeholder="Type to filter, F4 for list…"
            @select="onTypeSelected"
          />
          <p v-if="rules" class="hint">{{ rules.description }}</p>
        </div>

        <div class="grid3">
          <label class="field">
            <span>Length</span>
            <select
              v-if="rules?.forceLength"
              v-model.number="form.length"
              :disabled="readonly"
            >
              <option v-for="n in forcedLengths" :key="n" :value="n">{{ n }}</option>
            </select>
            <input
              v-else
              v-model.number="form.length"
              type="number"
              min="0"
              :max="rules && rules.maxLength > 0 ? rules.maxLength : undefined"
              :disabled="readonly || !rules?.allowLength"
              :required="rules?.requireLength"
            />
          </label>
          <label class="field">
            <span>Scale (dec pos)</span>
            <input
              v-model.number="form.scale"
              type="number"
              min="0"
              :disabled="readonly || !rules?.allowDecimals"
            />
          </label>
          <label class="field">
            <span>Allocation</span>
            <input
              v-model.number="form.allocation"
              type="number"
              min="0"
              :disabled="readonly || !rules?.allowAllocation"
              :required="rules?.requireAllocation"
            />
          </label>
        </div>

        <div class="grid2">
          <label class="field">
            <span>Project number</span>
            <input v-model="form.projectNumber" type="text" maxlength="10" class="upper" :disabled="readonly" />
          </label>
          <label class="field">
            <span>Prompt text</span>
            <input v-model="form.promptText" type="text" maxlength="20" :disabled="readonly" />
          </label>
        </div>

        <label class="field">
          <span>Default value</span>
          <input v-model="form.defaultValue" type="text" maxlength="60" :disabled="readonly" />
        </label>

        <div class="checks">
          <label class="check">
            <input v-model="form.allowNull" type="checkbox" :disabled="readonly" />
            <span>Allow null</span>
          </label>
          <label class="check">
            <input v-model="form.enumerated" type="checkbox" :disabled="readonly" />
            <span>Enumerated</span>
          </label>
        </div>

        <AuditInfo
          v-if="mode === 'update' || mode === 'view'"
          :created="props.field?.created"
          :maintained="props.field?.maintained"
        />

        <div class="actions">
          <button type="button" class="secondary" @click="emit('close')">
            {{ readonly ? 'Close' : 'Cancel' }}
          </button>
          <button v-if="!readonly" type="submit" class="primary" :disabled="busy">
            {{ busy ? 'Saving…' : 'Save' }}
          </button>
        </div>
      </form>
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
  width: min(640px, calc(100vw - 40px));
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
  font-size: 1.15rem;
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

.grid2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0 14px;
}

.grid3 {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 0 14px;
}

.field {
  display: block;
  margin-bottom: 12px;
  min-width: 0;
}

.field > span,
.lbl {
  display: block;
  margin-bottom: 4px;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-muted);
}

.field input,
.field select {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: var(--color-surface);
  color: var(--color-text);
}

.field input:disabled,
.field select:disabled {
  background: var(--color-bg);
  color: var(--color-text-muted);
}

.field input:focus,
.field select:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}

.grid3 input {
  margin-bottom: 12px;
}

.upper {
  text-transform: uppercase;
}

.code {
  font-family: ui-monospace, Consolas, monospace;
  letter-spacing: 0.08em;
}

.hint {
  margin: 4px 2px 0;
  font-size: 0.8rem;
  color: var(--color-text-muted);
}

.checks {
  display: flex;
  gap: 26px;
  margin-bottom: 4px;
}

.check {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.95rem;
}

.actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 18px;
}

.primary {
  padding: 9px 18px;
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
  padding: 9px 18px;
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
</style>
