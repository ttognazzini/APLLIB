<script setup lang="ts">
import { useRoute } from 'vue-router'

// Stand-in for screens that haven't been built yet. When a real screen is
// ready, create its view in src/views/ and point the route at it instead.
const route = useRoute()
</script>

<template>
  <div>
    <h1>{{ route.meta.title }}</h1>
    <p class="placeholder">This screen hasn't been built yet.</p>
  </div>
</template>

<style scoped>
.placeholder {
  padding: 40px;
  text-align: center;
  color: var(--color-text-muted);
  background: var(--color-surface);
  border: 1px dashed var(--color-border);
  border-radius: 10px;
  max-width: 760px;
}
</style>
