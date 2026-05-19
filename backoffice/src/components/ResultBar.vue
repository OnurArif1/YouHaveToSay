<template>
  <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
    <div class="mb-2 flex items-center justify-between text-sm">
      <span class="font-medium text-slate-800">{{ label }}</span>
      <span class="text-slate-500">{{ voteCount }} oy · %{{ percentage }}</span>
    </div>
    <div class="h-3 overflow-hidden rounded-full bg-slate-100">
      <div
        class="h-full rounded-full transition-all"
        :class="highlight ? 'bg-indigo-600' : 'bg-slate-400'"
        :style="{ width: `${percentage}%` }"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  label: string
  voteCount: number
  percentage: number
  highlight?: boolean
}>()
</script>
