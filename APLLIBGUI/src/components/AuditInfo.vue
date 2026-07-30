<script setup lang="ts">
// Standard audit footer for single-record detail views (RULES.md U7):
// trigger-populated create/maintenance info, mirroring the green screens'
// "Created / Last" lines.
defineProps<{ created?: string; maintained?: string }>()
</script>

<template>
  <div v-if="created || maintained" class="audit">
    <p v-if="created"><span class="tag">Created</span>{{ created }}</p>
    <p v-if="maintained"><span class="tag">Last</span>{{ maintained }}</p>
  </div>
</template>

<style scoped>
.audit {
  margin-top: 16px;
  padding-top: 10px;
  border-top: 1px solid var(--color-border);
}

.audit p {
  margin: 2px 0;
  font-family: ui-monospace, Consolas, monospace;
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.tag {
  display: inline-block;
  width: 64px;
  font-weight: 600;
}
</style>
