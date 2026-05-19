<template>
  <span
    class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-medium"
    :class="active ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-200 text-slate-600'"
  >
    {{ active ? 'Aktif' : 'Pasif' }}
  </span>
</template>

<script setup lang="ts">
defineProps<{ active: boolean }>()
</script>
