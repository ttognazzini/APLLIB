<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { cycleTheme, themePref } from '@/theme'
import AppIcon from './AppIcon.vue'

// Standard header on every signed-on page: page title, signed-on user
// profile, and the sign-off button (RULES.md U1). If the route provides
// meta.help, an ⓘ icon left of the title opens an explainer modal.
const route = useRoute()
const auth = useAuthStore()
const router = useRouter()

const help = computed(() => route.meta.help)
const showHelp = ref(false)

function signOff() {
  auth.signOff()
  router.push({ name: 'signon' })
}

const themeIcon = computed(() =>
  themePref.value === 'auto' ? 'monitor' : themePref.value === 'light' ? 'sun' : 'moon',
)
const themeTitle = computed(() =>
  themePref.value === 'auto'
    ? 'Theme: Auto (follows your system) — click for Light'
    : themePref.value === 'light'
      ? 'Theme: Light — click for Dark'
      : 'Theme: Dark — click for Auto',
)

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    showHelp.value = false
  }
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <header class="header">
    <div class="left">
      <button
        v-if="help"
        class="info"
        :title="`About ${route.meta.title}`"
        @click="showHelp = true"
      >
        <AppIcon name="info" />
      </button>
      <h2 class="page-title">{{ route.meta.title }}</h2>
    </div>
    <div class="right">
      <button class="theme" :title="themeTitle" @click="cycleTheme">
        <AppIcon :name="themeIcon" />
      </button>
      <span class="user" title="Signed-on user profile">
        <AppIcon name="user" />
        {{ auth.user }}
      </span>
      <button class="signoff" @click="signOff">
        <AppIcon name="signoff" />
        <span>Sign off</span>
      </button>
    </div>
  </header>

  <Teleport to="body">
    <div v-if="showHelp && help" class="overlay" @click.self="showHelp = false">
      <div class="modal" role="dialog" aria-modal="true" :aria-label="help.title">
        <div class="modal-head">
          <h3 class="modal-title">{{ help.title }}</h3>
          <button class="close" title="Close" @click="showHelp = false">
            <AppIcon name="close" />
          </button>
        </div>
        <p v-for="(paragraph, i) in help.paragraphs" :key="i" class="modal-text">
          {{ paragraph }}
        </p>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
  padding: 0 24px;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}

.left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.info {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  border: none;
  border-radius: 50%;
  background: none;
  color: var(--color-text-muted);
  cursor: pointer;
}

.info:hover {
  color: var(--color-primary);
  background: var(--color-bg);
}

.page-title {
  margin: 0;
  font-size: 1.05rem;
  font-weight: 600;
}

.right {
  display: flex;
  align-items: center;
  gap: 18px;
}

.theme {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 6px;
  border: none;
  border-radius: 6px;
  background: none;
  color: var(--color-text-muted);
  cursor: pointer;
}

.theme:hover {
  background: var(--color-bg);
  color: var(--color-text);
}

.user {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.signoff {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 7px 14px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: none;
  color: var(--color-text);
  cursor: pointer;
}

.signoff:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

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
  width: min(560px, calc(100vw - 40px));
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
  margin-bottom: 12px;
}

.modal-title {
  margin: 0;
  font-size: 1.15rem;
}

.close {
  display: flex;
  align-items: center;
  justify-content: center;
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

.modal-text {
  margin: 0 0 12px;
  line-height: 1.55;
}
</style>
