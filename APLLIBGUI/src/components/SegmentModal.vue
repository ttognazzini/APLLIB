<script setup lang="ts">
import { reactive, ref } from 'vue'
import { addSegment, updateSegment, type Segment } from '@/api/segments'
import AppIcon from './AppIcon.vue'

// Detail form for one segment — the web version of green screen DCTSEGD2.
// Modes mirror the DCTSEGD1 options: add (1/F6), update (2), copy (3),
// view (5). Copy prefills from an existing segment but saves as a new one.
const props = defineProps<{
  mode: 'add' | 'update' | 'copy' | 'view'
  segment?: Segment
}>()

const emit = defineEmits<{ close: []; saved: [] }>()

const titles = {
  add: 'Add segment',
  update: 'Update segment',
  copy: 'Copy segment',
  view: 'View segment',
} as const

const readonly = props.mode === 'view'
// The 3-char key is only enterable when creating a new record.
const keyLocked = props.mode === 'update' || props.mode === 'view'

const form = reactive<Segment>({
  segment: props.mode === 'copy' ? '' : (props.segment?.segment ?? ''),
  description: props.segment?.description ?? '',
  columnText: props.segment?.columnText ?? '',
  columnHeading: props.segment?.columnHeading ?? '',
  conflict: props.segment?.conflict ?? false,
  note: props.segment?.note ?? '',
  active: props.segment?.active ?? true,
})

const error = ref('')
const busy = ref(false)

async function save() {
  error.value = ''
  form.segment = form.segment.trim().toUpperCase()
  if (!/^[A-Z0-9]{1,3}$/.test(form.segment)) {
    error.value = 'Segment must be 1 to 3 characters, letters and numbers only'
    return
  }
  form.description = form.description.trim()
  if (form.description === '') {
    error.value = 'Description is required'
    return
  }
  // Blank column text / heading default to the description (heading is
  // CHAR(20), so it takes the first 20 characters).
  if (form.columnText.trim() === '') {
    form.columnText = form.description
  }
  if (form.columnHeading.trim() === '') {
    form.columnHeading = form.description.slice(0, 20)
  }
  busy.value = true
  try {
    if (props.mode === 'update') {
      await updateSegment({ ...form })
    } else {
      await addSegment({ ...form })
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
          <span>Data segment</span>
          <input
            v-model="form.segment"
            type="text"
            maxlength="3"
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
          <span>Column text</span>
          <input
            v-model="form.columnText"
            type="text"
            maxlength="50"
            :disabled="readonly"
            :placeholder="readonly ? '' : 'Defaults to description'"
          />
        </label>

        <label class="field">
          <span>Column heading</span>
          <input
            v-model="form.columnHeading"
            type="text"
            maxlength="20"
            :disabled="readonly"
            :placeholder="readonly ? '' : 'Defaults to description'"
          />
        </label>

        <label class="check">
          <input v-model="form.conflict" type="checkbox" :disabled="readonly" />
          <span>Conflicts exist</span>
        </label>

        <label class="field">
          <span>Note</span>
          <input v-model="form.note" type="text" maxlength="60" :disabled="readonly" />
        </label>

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
  width: 90px !important;
  font-family: ui-monospace, Consolas, monospace;
  letter-spacing: 0.15em;
}

.check {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
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
