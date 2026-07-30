<script setup lang="ts">
// Slider-style on/off switch (the web equivalent of a green-screen F-key
// toggle like F11=Show Inactive).
const model = defineModel<boolean>({ required: true })

defineProps<{ label: string }>()
</script>

<template>
  <label class="switch">
    <input v-model="model" type="checkbox" class="input" />
    <span class="track" aria-hidden="true">
      <span class="thumb" />
    </span>
    <span class="label">{{ label }}</span>
  </label>
</template>

<style scoped>
.switch {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}

.input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.track {
  position: relative;
  width: 38px;
  height: 21px;
  border-radius: 11px;
  background: var(--color-border);
  transition: background 0.15s ease;
  flex-shrink: 0;
}

.input:checked + .track {
  background: var(--color-primary);
}

.input:focus-visible + .track {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

.thumb {
  position: absolute;
  top: 2px;
  left: 2px;
  width: 17px;
  height: 17px;
  border-radius: 50%;
  background: #fff;
  transition: left 0.15s ease;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.25);
}

.input:checked + .track .thumb {
  left: 19px;
}

.label {
  font-size: 0.9rem;
}
</style>
