<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import SideBar from '@/components/SideBar.vue'
import AppHeader from '@/components/AppHeader.vue'

const route = useRoute()

// Wait for the first navigation to resolve so the shell doesn't flash
// before the sign-on redirect happens.
const ready = computed(() => route.matched.length > 0)

// Public routes (sign-on) render bare, without the sidebar/header shell.
const bare = computed(() => route.meta.public === true)
</script>

<template>
  <template v-if="ready">
    <RouterView v-if="bare" />
    <div v-else class="shell">
      <SideBar />
      <div class="main-col">
        <AppHeader />
        <main class="content">
          <RouterView />
        </main>
      </div>
    </div>
  </template>
</template>

<style scoped>
.shell {
  display: flex;
  height: 100%;
}

.main-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.content {
  flex: 1;
  overflow: auto;
  padding: 24px 32px;
}
</style>
