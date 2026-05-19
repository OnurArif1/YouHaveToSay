<template>
  <aside class="flex w-64 shrink-0 flex-col border-r border-slate-200 bg-white">
    <div class="border-b border-slate-200 px-6 py-5">
      <p class="text-lg font-semibold text-indigo-700">YouHaveToSay</p>
      <p class="text-xs text-slate-500">Backoffice</p>
    </div>
    <nav class="flex-1 space-y-1 p-4">
      <RouterLink
        v-for="item in items"
        :key="item.to"
        :to="item.to"
        class="block rounded-lg px-3 py-2 text-sm font-medium transition"
        :class="isActive(item.to)
          ? 'bg-indigo-50 text-indigo-700'
          : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'"
      >
        {{ item.label }}
      </RouterLink>
    </nav>
    <div class="border-t border-slate-200 p-4">
      <button
        type="button"
        class="w-full rounded-lg px-3 py-2 text-left text-sm font-medium text-slate-600 hover:bg-slate-50"
        @click="auth.logout(); $router.push({ name: 'login' })"
      >
        Çıkış
      </button>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

const auth = useAuthStore()
const route = useRoute()

const items = [
  { to: '/dashboard', label: 'Dashboard' },
  { to: '/comparisons', label: 'Karşılaştırmalar' },
  { to: '/comparisons/create', label: 'Yeni Karşılaştırma' },
  { to: '/users', label: 'Kullanıcılar' },
  { to: '/settings', label: 'Ayarlar' },
]

function isActive(path: string) {
  return route.path === path || route.path.startsWith(path + '/')
}
</script>
