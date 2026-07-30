<script setup lang="ts">
import { ref } from 'vue'
import { navItems } from '@/navigation'
import AppIcon from './AppIcon.vue'

const collapsed = ref(false)
</script>

<template>
  <aside class="sidebar" :class="{ collapsed }">
    <!-- Fixed at the standard header height (56px) so the top edge
         lines up with the page header across the whole app. -->
    <div class="brand">
      <template v-if="!collapsed">
        <img
          src="/apllib-logo.svg"
          alt="APLLIB — Application Development Library"
          class="brand-logo-full logo-light"
        />
        <img
          src="/apllib-logo-dark.svg"
          alt="APLLIB — Application Development Library"
          class="brand-logo-full logo-dark"
        />
        <button class="toggle" title="Minimize menu" @click="collapsed = true">
          <AppIcon name="minimize" />
        </button>
      </template>
      <img v-else src="/android-chrome-192x192.png" alt="APLLIB" title="APLLIB" class="brand-logo" />
    </div>

    <nav class="nav">
      <!-- Collapsed: the expand control lives in the nav list so the
           brand band keeps the standard header height. -->
      <button
        v-if="collapsed"
        class="nav-item expand-btn"
        title="Expand menu"
        @click="collapsed = false"
      >
        <AppIcon name="expand" />
      </button>
      <RouterLink
        v-for="item in navItems"
        :key="item.to"
        :to="item.to"
        class="nav-item"
        :title="collapsed ? item.label : undefined"
      >
        <AppIcon :name="item.icon" />
        <span v-if="!collapsed" class="nav-label">{{ item.label }}</span>
      </RouterLink>
    </nav>
  </aside>
</template>

<style scoped>
.sidebar {
  display: flex;
  flex-direction: column;
  width: 230px;
  background: var(--color-sidebar);
  color: var(--color-sidebar-text);
  transition: width 0.15s ease;
}

.sidebar.collapsed {
  width: 60px;
}

.brand {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
  height: 56px; /* matches AppHeader so the top edges align */
  padding: 0 12px;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}

.collapsed .brand {
  justify-content: center;
  padding: 0;
}

.brand-logo-full {
  display: block;
  min-width: 0;
  height: 40px;
  width: auto;
}

/* Theme-matched logo variants (RULES.md U5) */
.logo-dark {
  display: none;
}

:root[data-theme='dark'] .logo-light {
  display: none;
}

:root[data-theme='dark'] .logo-dark {
  display: block;
}

.brand-logo {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  flex-shrink: 0;
}

.toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 6px;
  background: none;
  border: none;
  border-radius: 6px;
  color: var(--color-text-muted);
  cursor: pointer;
}

.toggle:hover {
  background: var(--color-bg);
  color: var(--color-text);
}

.nav {
  flex: 1;
  padding: 10px 8px;
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow-y: auto;
}

.expand-btn {
  margin-bottom: 8px;
  border-bottom: 1px solid var(--color-sidebar-hover);
  border-radius: 6px 6px 0 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 10px 12px;
  border: none;
  border-radius: 6px;
  background: none;
  color: var(--color-sidebar-text);
  text-decoration: none;
  cursor: pointer;
  white-space: nowrap;
}

.collapsed .nav-item {
  justify-content: center;
  gap: 0;
}

.nav-item:hover {
  background: var(--color-sidebar-hover);
  color: #fff;
}

.nav-item.router-link-exact-active {
  background: var(--color-sidebar-active);
  color: #fff;
}

.nav-label {
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
