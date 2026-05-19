<template>
  <header class="flex items-center justify-between border-b border-slate-200 bg-white px-6 py-4">
    <div>
      <h1 class="text-xl font-semibold text-slate-900">{{ title }}</h1>
      <p v-if="subtitle" class="text-sm text-slate-500">{{ subtitle }}</p>
    </div>
    <slot />
  </header>
</template>

<script setup lang="ts">
defineProps<{ title: string; subtitle?: string }>()
</script>
