<script setup lang="ts">
import { reactive, ref } from 'vue'
import { addDictionary, updateDictionary, type Dictionary } from '@/api/dictionaries'
import AppIcon from './AppIcon.vue'
import AuditInfo from './AuditInfo.vue'

// Detail form for one dictionary — the web version of DCTMSTD2.
const props = defineProps<{
  mode: 'add' | 'update' | 'copy' | 'view'
  dictionary?: Dictionary
}>()

const emit = defineEmits<{ close: []; saved: [] }>()

const titles = {
  add: 'Add dictionary',
  update: 'Update dictionary',
  copy: 'Copy dictionary',
  view: 'View dictionary',
} as const

const readonly = props.mode === 'view'
const keyLocked = props.mode === 'update' || props.mode === 'view'

const form = reactive<Dictionary>({
  dictionary: props.mode === 'copy' ? '' : (props.dictionary?.dictionary ?? ''),
  description: props.dictionary?.description ?? '',
  note: props.dictionary?.note ?? '',
  active: props.dictionary?.active ?? true,
  created: '',
  maintained: '',
})

const error = ref('')
const busy = ref(false)

async function save() {
  error.value = ''
  form.dictionary = form.dictionary.trim().toUpperCase()
  if (!/^[A-Z][A-Z0-9]{0,9}$/.test(form.dictionary)) {
    error.value = 'Dictionary name must be 1 to 10 characters, starting with a letter'
    return
  }
  form.description = form.description.trim()
  if (form.description === '') {
    error.value = 'Description is required'
    return
  }
  busy.value = true
  try {
    if (props.mode === 'update') {
      await updateDictionary({ ...form })
    } else {
      await addDictionary({ ...form })
    }
    emit('saved')
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
          <h3 class="modal-title">{{ titles[mode] }}</h3>
          <button type="button" class="close" title="Close" @click="emit('close')">
            <AppIcon name="close" />
          </button>
        </div>

        <div v-if="error" class="error">{{ error }}</div>

        <label class="field">
          <span>Dictionary</span>
          <input
            v-model="form.dictionary"
            type="text"
            maxlength="10"
            class="upper code"
            :disabled="keyLocked"
            spellcheck="false"
            required
          />
        </label>

        <label class="field">
          <span>Description</span>
          <input v-model="form.description" type="text" maxlength="40" :disabled="readonly" required />
        </label>

        <label class="field">
          <span>Note</span>
          <input v-model="form.note" type="text" maxlength="60" :disabled="readonly" />
        </label>

        <AuditInfo
          v-if="mode === 'update' || mode === 'view'"
          :created="props.dictionary?.created"
          :maintained="props.dictionary?.maintained"
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
  width: min(520px, calc(100vw - 40px));
  max-height: calc(100vh - 80px);
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

.field {
  display: block;
  margin-bottom: 12px;
}

.field span {
  display: block;
  margin-bottom: 4px;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-muted);
}

.field input {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
}

.field input:disabled {
  background: var(--color-bg);
  color: var(--color-text-muted);
}

.field input:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}

.upper {
  text-transform: uppercase;
}

.code {
  width: 160px !important;
  font-family: ui-monospace, Consolas, monospace;
  letter-spacing: 0.08em;
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
