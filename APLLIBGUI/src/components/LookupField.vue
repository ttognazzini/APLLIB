<script lang="ts">
/** An option for LookupField: the stored value + the description shown. */
export interface LookupOption {
  value: string
  label: string
}
</script>

<script setup lang="ts">
import { computed, ref } from 'vue'

// The standard prompting control (RULES.md U6) — the web version of a
// green-screen promptable field: type to filter (the old "partial value
// + Enter"), ▾ or the F4 key to open the full list, arrow keys + Enter
// to select.
const model = defineModel<string>({ required: true })

const props = defineProps<{
  options: LookupOption[]
  placeholder?: string
  disabled?: boolean
}>()

const emit = defineEmits<{ select: [option: LookupOption] }>()

const open = ref(false)
// null = not typing (show every option when opened via button/F4)
const term = ref<string | null>(null)
const highlight = ref(0)
const inputEl = ref<HTMLInputElement | null>(null)

const shown = computed(() => (term.value !== null ? term.value : model.value))

const filtered = computed(() => {
  const t = (term.value ?? '').trim().toLowerCase()
  if (t === '') {
    return props.options
  }
  return props.options.filter(
    (o) => o.value.toLowerCase().includes(t) || o.label.toLowerCase().includes(t),
  )
})

function onInput(event: Event) {
  term.value = (event.target as HTMLInputElement).value
  model.value = term.value
  highlight.value = 0
  open.value = true
}

function choose(option: LookupOption) {
  model.value = option.value
  term.value = null
  open.value = false
  emit('select', option)
  inputEl.value?.focus()
}

function openFullList() {
  term.value = null
  highlight.value = 0
  open.value = true
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'F4') {
    event.preventDefault()
    openFullList()
    return
  }
  if (event.key === 'Escape') {
    open.value = false
    term.value = null
    return
  }
  if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
    event.preventDefault()
    if (!open.value) {
      openFullList()
      return
    }
    const max = filtered.value.length - 1
    highlight.value =
      event.key === 'ArrowDown'
        ? Math.min(highlight.value + 1, max)
        : Math.max(highlight.value - 1, 0)
    return
  }
  if (event.key === 'Enter' && open.value) {
    event.preventDefault()
    const option = filtered.value[highlight.value]
    if (option) {
      choose(option)
    }
  }
}

function onBlur() {
  // Delay so a mousedown on an option can complete first
  setTimeout(() => {
    open.value = false
    term.value = null
  }, 150)
}
</script>

<template>
  <div class="lookup">
    <input
      ref="inputEl"
      :value="shown"
      type="text"
      :placeholder="placeholder"
      :disabled="disabled"
      spellcheck="false"
      class="lookup-input"
      @input="onInput"
      @keydown="onKeydown"
      @blur="onBlur"
    />
    <button
      type="button"
      class="lookup-btn"
      title="Show list (F4)"
      :disabled="disabled"
      tabindex="-1"
      @mousedown.prevent="open ? (open = false) : openFullList()"
    >
      ▾
    </button>
    <ul v-if="open" class="menu">
      <li
        v-for="(option, i) in filtered"
        :key="option.value"
        class="option"
        :class="{ highlight: i === highlight }"
        @mousedown.prevent="choose(option)"
        @mousemove="highlight = i"
      >
        <span class="value">{{ option.value }}</span>
        <span class="label">{{ option.label }}</span>
      </li>
      <li v-if="filtered.length === 0" class="none">No matches</li>
    </ul>
  </div>
</template>

<style scoped>
.lookup {
  position: relative;
  display: flex;
}

.lookup-input {
  flex: 1;
  min-width: 0;
  padding: 8px 10px;
  border: 1px solid var(--color-border);
  border-radius: 6px 0 0 6px;
  border-right: none;
}

.lookup-input:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}

.lookup-input:disabled {
  background: var(--color-bg);
  color: var(--color-text-muted);
}

.lookup-btn {
  padding: 0 10px;
  border: 1px solid var(--color-border);
  border-radius: 0 6px 6px 0;
  background: var(--color-surface);
  color: var(--color-text-muted);
  cursor: pointer;
}

.lookup-btn:hover:enabled {
  color: var(--color-primary);
}

.menu {
  position: absolute;
  top: calc(100% + 2px);
  left: 0;
  right: 0;
  z-index: 120;
  max-height: 230px;
  overflow-y: auto;
  margin: 0;
  padding: 4px;
  list-style: none;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  box-shadow: 0 8px 22px rgba(0, 0, 0, 0.18);
}

.option {
  display: flex;
  gap: 10px;
  align-items: baseline;
  padding: 7px 10px;
  border-radius: 5px;
  cursor: pointer;
}

.option.highlight {
  background: var(--color-primary);
  color: #fff;
}

.option.highlight .value,
.option.highlight .label {
  color: #fff;
}

.value {
  font-family: ui-monospace, Consolas, monospace;
  font-weight: 600;
  white-space: nowrap;
}

.label {
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.none {
  padding: 8px 10px;
  color: var(--color-text-muted);
  font-size: 0.9rem;
}
</style>
