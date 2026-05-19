<template>
  <div class="flex items-center justify-center py-16 text-slate-500">
    <div class="h-8 w-8 animate-spin rounded-full border-2 border-slate-300 border-t-indigo-600" />
    <span class="ml-3 text-sm">{{ message }}</span>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ message?: string }>(), { message: 'Yükleniyor...' })
</script>
