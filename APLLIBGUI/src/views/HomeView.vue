<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { navItems } from '@/navigation'

const auth = useAuthStore()
const sections = navItems.filter((item) => item.to !== '/')
</script>

<template>
  <div>
    <h1>Welcome, {{ auth.user }}</h1>
    <p class="intro">
      APLLIB is the application-development toolset on the IBM i. This site is its browser front
      end — starting with the data dictionary system.
    </p>

    <div class="cards">
      <RouterLink v-for="section in sections" :key="section.to" :to="section.to" class="card">
        <span class="card-title">{{ section.label }}</span>
        <span class="card-hint">Open {{ section.label.toLowerCase() }}</span>
      </RouterLink>
    </div>
  </div>
</template>

<style scoped>
.intro {
  max-width: 640px;
  color: var(--color-text-muted);
  margin: 0 0 24px;
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  max-width: 760px;
}

.card {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 20px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 10px;
  text-decoration: none;
  color: var(--color-text);
}

.card:hover {
  border-color: var(--color-primary);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.card-title {
  font-weight: 600;
  font-size: 1.05rem;
}

.card-hint {
  font-size: 0.85rem;
  color: var(--color-text-muted);
}
</style>
